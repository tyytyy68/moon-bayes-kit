///|
/// An observation that can be replayed by a conjugate model ledger.
pub(all) enum Observation {
  Binary(successes~ : Int, trials~ : Int)
  Counts(sum~ : Int, observations~ : Int)
  Continuous(mean~ : Double, observations~ : Int)
  Categorical(index~ : Int)
} derive(Debug, Eq, ToJson, FromJson)

///|
/// A deterministic audit trail for online updates. It keeps immutable snapshots
/// so callers can compare revisions or replay a production data window.
pub struct UpdateLedger {
  observations : Array[Observation]
  binary : BetaBinomial
  counts : GammaPoisson
  continuous : NormalNormal
  categorical : DirichletMultinomial
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn UpdateLedger::new(
  binary : BetaBinomial,
  counts : GammaPoisson,
  continuous : NormalNormal,
  categorical : DirichletMultinomial,
) -> UpdateLedger {
  { observations: [], binary, counts, continuous, categorical }
}

///|
pub fn UpdateLedger::push(
  self : UpdateLedger,
  observation : Observation,
) -> UpdateLedger {
  let next = match observation {
    Binary(successes~, trials~) =>
      { ..self, binary: self.binary.update(successes, trials) }
    Counts(sum~, observations~) =>
      { ..self, counts: self.counts.update(sum, observations) }
    Continuous(mean~, observations~) =>
      { ..self, continuous: self.continuous.update(mean, observations) }
    Categorical(index~) =>
      { ..self, categorical: self.categorical.update_one(index) }
  }
  let observations = self.observations.copy()
  observations.push(observation)
  { ..next, observations, }
}

///|
pub fn UpdateLedger::push_all(
  self : UpdateLedger,
  observations : Array[Observation],
) -> UpdateLedger {
  observations.fold(init=self, (ledger, observation) => ledger.push(observation))
}

///|
pub fn UpdateLedger::len(self : UpdateLedger) -> Int {
  self.observations.length()
}

///|
pub fn UpdateLedger::observations(self : UpdateLedger) -> Array[Observation] {
  self.observations.copy()
}

///|
pub fn UpdateLedger::binary(self : UpdateLedger) -> BetaBinomial {
  self.binary
}

///|
pub fn UpdateLedger::counts(self : UpdateLedger) -> GammaPoisson {
  self.counts
}

///|
pub fn UpdateLedger::continuous(self : UpdateLedger) -> NormalNormal {
  self.continuous
}

///|
pub fn UpdateLedger::categorical(self : UpdateLedger) -> DirichletMultinomial {
  self.categorical
}

///|
pub struct BinaryBatch {
  successes : Int
  trials : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn BinaryBatch::new(successes : Int, trials : Int) -> BinaryBatch {
  if successes < 0 || trials < 0 || successes > trials {
    abort("BinaryBatch: invalid counts")
  }
  { successes, trials }
}

///|
pub fn BinaryBatch::success_rate(self : BinaryBatch) -> Double {
  if self.trials == 0 {
    0.0
  } else {
    self.successes.to_double() / self.trials.to_double()
  }
}

///|
pub fn BinaryBatch::combine(
  self : BinaryBatch,
  other : BinaryBatch,
) -> BinaryBatch {
  BinaryBatch::new(self.successes + other.successes, self.trials + other.trials)
}

///|
pub struct CountBatch {
  total : Int
  observations : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn CountBatch::new(total : Int, observations : Int) -> CountBatch {
  if total < 0 || observations < 0 {
    abort("CountBatch: values must be non-negative")
  }
  { total, observations }
}

///|
pub fn CountBatch::rate(self : CountBatch) -> Double {
  if self.observations == 0 {
    0.0
  } else {
    self.total.to_double() / self.observations.to_double()
  }
}

///|
pub fn CountBatch::combine(self : CountBatch, other : CountBatch) -> CountBatch {
  CountBatch::new(
    self.total + other.total,
    self.observations + other.observations,
  )
}

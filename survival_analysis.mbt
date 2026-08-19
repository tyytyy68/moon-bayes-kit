///|
/// Survival-analysis utilities for reliability, retention, and time-to-event
/// applications. Censoring is represented explicitly rather than inferred.
pub enum EventStatus {
  Event
  Censored
} derive(Debug, Eq, ToJson, FromJson)

///|
pub struct SurvivalObservation {
  duration : Double
  status : EventStatus
  weight : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn SurvivalObservation::new(
  duration : Double,
  status : EventStatus,
) -> SurvivalObservation {
  if duration < 0.0 {
    abort("SurvivalObservation: duration must be non-negative")
  }
  { duration, status, weight: 1.0 }
}

///|
pub fn SurvivalObservation::weighted(
  duration : Double,
  status : EventStatus,
  weight : Double,
) -> SurvivalObservation {
  if duration < 0.0 || weight < 0.0 {
    abort("SurvivalObservation: invalid duration or weight")
  }
  { duration, status, weight }
}

///|
pub fn SurvivalObservation::duration(self : SurvivalObservation) -> Double {
  self.duration
}

///|
pub fn SurvivalObservation::status(self : SurvivalObservation) -> EventStatus {
  self.status
}

///|
pub fn SurvivalObservation::weight(self : SurvivalObservation) -> Double {
  self.weight
}

///|
pub struct SurvivalStep {
  time : Double
  at_risk : Double
  events : Double
  censored : Double
  survival : Double
  hazard : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn SurvivalStep::time(self : SurvivalStep) -> Double {
  self.time
}

///|
pub fn SurvivalStep::at_risk(self : SurvivalStep) -> Double {
  self.at_risk
}

///|
pub fn SurvivalStep::events(self : SurvivalStep) -> Double {
  self.events
}

///|
pub fn SurvivalStep::censored(self : SurvivalStep) -> Double {
  self.censored
}

///|
pub fn SurvivalStep::survival(self : SurvivalStep) -> Double {
  self.survival
}

///|
pub fn SurvivalStep::hazard(self : SurvivalStep) -> Double {
  self.hazard
}

///|
pub struct KaplanMeier {
  steps : Array[SurvivalStep]
  observations : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn KaplanMeier::fit(
  observations : Array[SurvivalObservation],
) -> KaplanMeier {
  if observations.length() == 0 {
    abort("KaplanMeier::fit: observations must not be empty")
  }
  let times = []
  for observation in observations {
    if !times.contains(observation.duration()) {
      times.push(observation.duration())
    }
  }
  times.sort()
  let steps = []
  let mut at_risk = observations.fold(init=0.0, (total, observation) => {
    total + observation.weight()
  })
  let mut survival = 1.0
  for time in times {
    let mut events = 0.0
    let mut censored = 0.0
    for observation in observations {
      if observation.duration() == time {
        match observation.status() {
          Event => events = events + observation.weight()
          Censored => censored = censored + observation.weight()
        }
      }
    }
    let hazard = if at_risk == 0.0 { 0.0 } else { events / at_risk }
    survival = survival * (1.0 - hazard)
    steps.push({ time, at_risk, events, censored, survival, hazard })
    at_risk = at_risk - events - censored
  }
  { steps, observations: observations.length() }
}

///|
pub fn KaplanMeier::steps(self : KaplanMeier) -> Array[SurvivalStep] {
  self.steps.copy()
}

///|
pub fn KaplanMeier::observations(self : KaplanMeier) -> Int {
  self.observations
}

///|
pub fn KaplanMeier::survival_at(self : KaplanMeier, time : Double) -> Double {
  let mut result = 1.0
  for step in self.steps {
    if step.time() <= time {
      result = step.survival()
    }
  }
  result
}

///|
pub fn KaplanMeier::failure_at(self : KaplanMeier, time : Double) -> Double {
  1.0 - self.survival_at(time)
}

///|
pub fn KaplanMeier::hazard_at(self : KaplanMeier, time : Double) -> Double {
  let mut result = 0.0
  for step in self.steps {
    if step.time() <= time {
      result = step.hazard()
    }
  }
  result
}

///|
pub fn KaplanMeier::median_survival(self : KaplanMeier) -> Double {
  for step in self.steps {
    if step.survival() <= 0.5 {
      return step.time()
    }
  }
  if self.steps.length() == 0 {
    0.0
  } else {
    self.steps[self.steps.length() - 1].time()
  }
}

///|
pub fn KaplanMeier::restricted_mean(
  self : KaplanMeier,
  horizon : Double,
) -> Double {
  if horizon < 0.0 {
    abort("KaplanMeier::restricted_mean: horizon must be non-negative")
  }
  let mut area = 0.0
  let mut previous = 0.0
  let mut level = 1.0
  for step in self.steps {
    if step.time() >= horizon {
      break
    }
    area = area + (step.time() - previous) * level
    previous = step.time()
    level = step.survival()
  }
  area + (horizon - previous).max(0.0) * level
}

///|
pub fn KaplanMeier::quantile(
  self : KaplanMeier,
  probability : Double,
) -> Double {
  if probability < 0.0 || probability > 1.0 {
    abort("KaplanMeier::quantile: probability out of range")
  }
  for step in self.steps {
    if self.failure_at(step.time()) >= probability {
      return step.time()
    }
  }
  if self.steps.length() == 0 {
    0.0
  } else {
    self.steps[self.steps.length() - 1].time()
  }
}

///|
pub fn KaplanMeier::confidence_width(
  self : KaplanMeier,
  time : Double,
) -> Double {
  let survival = self.survival_at(time)
  let mut variance = 0.0
  for step in self.steps {
    if step.time() <= time && step.at_risk() > step.events() {
      variance = variance +
        step.events() / (step.at_risk() * (step.at_risk() - step.events()))
    }
  }
  (1.96 * survival * variance.sqrt()).min(1.0)
}

///|
pub struct HazardEstimate {
  time : Double
  hazard : Double
  lower : Double
  upper : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn HazardEstimate::from_step(step : SurvivalStep) -> HazardEstimate {
  let standard_error = if step.at_risk() == 0.0 {
    0.0
  } else {
    (step.events() / (step.at_risk() * step.at_risk())).sqrt()
  }
  {
    time: step.time(),
    hazard: step.hazard(),
    lower: (step.hazard() - 1.96 * standard_error).max(0.0),
    upper: step.hazard() + 1.96 * standard_error,
  }
}

///|
pub fn HazardEstimate::time(self : HazardEstimate) -> Double {
  self.time
}

///|
pub fn HazardEstimate::hazard(self : HazardEstimate) -> Double {
  self.hazard
}

///|
pub fn HazardEstimate::lower(self : HazardEstimate) -> Double {
  self.lower
}

///|
pub fn HazardEstimate::upper(self : HazardEstimate) -> Double {
  self.upper
}

///|
pub fn hazard_table(model : KaplanMeier) -> Array[HazardEstimate] {
  model.steps().map(HazardEstimate::from_step)
}

///|
pub struct ExponentialSurvival {
  rate : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn ExponentialSurvival::fit(
  observations : Array[SurvivalObservation],
) -> ExponentialSurvival {
  if observations.length() == 0 {
    abort("ExponentialSurvival::fit: observations required")
  }
  let mut exposure = 0.0
  let mut events = 0.0
  for observation in observations {
    exposure = exposure + observation.duration() * observation.weight()
    match observation.status() {
      Event => events = events + observation.weight()
      Censored => ()
    }
  }
  if exposure == 0.0 || events == 0.0 {
    { rate: 0.0 }
  } else {
    { rate: events / exposure }
  }
}

///|
pub fn ExponentialSurvival::new(rate : Double) -> ExponentialSurvival {
  if rate < 0.0 {
    abort("ExponentialSurvival: rate must be non-negative")
  }
  { rate, }
}

///|
pub fn ExponentialSurvival::rate(self : ExponentialSurvival) -> Double {
  self.rate
}

///|
pub fn ExponentialSurvival::survival(
  self : ExponentialSurvival,
  time : Double,
) -> Double {
  if time < 0.0 {
    abort("ExponentialSurvival::survival: time must be non-negative")
  }
  @math.pow(2.718281828459045, 0.0 - self.rate * time)
}

///|
pub fn ExponentialSurvival::hazard(self : ExponentialSurvival) -> Double {
  self.rate
}

///|
pub fn ExponentialSurvival::cdf(
  self : ExponentialSurvival,
  time : Double,
) -> Double {
  1.0 - self.survival(time)
}

///|
pub fn ExponentialSurvival::mean(self : ExponentialSurvival) -> Double {
  if self.rate == 0.0 {
    0.0
  } else {
    1.0 / self.rate
  }
}

///|
pub fn ExponentialSurvival::median(self : ExponentialSurvival) -> Double {
  if self.rate == 0.0 {
    0.0
  } else {
    0.6931471805599453 / self.rate
  }
}

///|
pub fn ExponentialSurvival::quantile(
  self : ExponentialSurvival,
  probability : Double,
) -> Double {
  if probability <= 0.0 || probability >= 1.0 || self.rate == 0.0 {
    abort("ExponentialSurvival::quantile: invalid probability")
  }
  0.6931471805599453 * probability / self.rate
}

///|
pub struct WeibullSurvival {
  shape : Double
  scale : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn WeibullSurvival::new(shape : Double, scale : Double) -> WeibullSurvival {
  if shape <= 0.0 || scale <= 0.0 {
    abort("WeibullSurvival: parameters must be positive")
  }
  { shape, scale }
}

///|
pub fn WeibullSurvival::shape(self : WeibullSurvival) -> Double {
  self.shape
}

///|
pub fn WeibullSurvival::scale(self : WeibullSurvival) -> Double {
  self.scale
}

///|
pub fn WeibullSurvival::survival(
  self : WeibullSurvival,
  time : Double,
) -> Double {
  if time < 0.0 {
    abort("WeibullSurvival::survival: time must be non-negative")
  }
  @math.pow(2.718281828459045, 0.0 - @math.pow(time / self.scale, self.shape))
}

///|
pub fn WeibullSurvival::cdf(self : WeibullSurvival, time : Double) -> Double {
  1.0 - self.survival(time)
}

///|
pub fn WeibullSurvival::hazard(self : WeibullSurvival, time : Double) -> Double {
  if time <= 0.0 {
    0.0
  } else {
    self.shape / self.scale * @math.pow(time / self.scale, self.shape - 1.0)
  }
}

///|
pub fn WeibullSurvival::quantile(
  self : WeibullSurvival,
  probability : Double,
) -> Double {
  if probability <= 0.0 || probability >= 1.0 {
    abort("WeibullSurvival::quantile: invalid probability")
  }
  self.scale * @math.pow(0.0 - probability, 1.0 / self.shape)
}

///|
pub struct LifeTable {
  intervals : Array[Double]
  exposed : Array[Double]
  deaths : Array[Double]
  survival : Array[Double]
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn LifeTable::new(intervals : Array[Double]) -> LifeTable {
  if intervals.length() == 0 {
    abort("LifeTable: intervals required")
  }
  {
    intervals: intervals.copy(),
    exposed: Array::make(intervals.length(), 0.0),
    deaths: Array::make(intervals.length(), 0.0),
    survival: Array::make(intervals.length(), 1.0),
  }
}

///|
pub fn LifeTable::record(
  self : LifeTable,
  interval : Int,
  exposure : Double,
  deaths : Double,
) -> LifeTable {
  if interval < 0 ||
    interval >= self.intervals.length() ||
    exposure < 0.0 ||
    deaths < 0.0 ||
    deaths > exposure {
    abort("LifeTable::record: invalid interval data")
  }
  let exposed = self.exposed.copy()
  let observed_deaths = self.deaths.copy()
  exposed[interval] = exposed[interval] + exposure
  observed_deaths[interval] = observed_deaths[interval] + deaths
  let survival = Array::make(self.intervals.length(), 1.0)
  let mut level = 1.0
  for index in 0..<self.intervals.length() {
    if exposed[index] > 0.0 {
      level = level * (1.0 - observed_deaths[index] / exposed[index])
    }
    survival[index] = level
  }
  { ..self, exposed, deaths: observed_deaths, survival }
}

///|
pub fn LifeTable::survival_at(self : LifeTable, interval : Int) -> Double {
  if interval < 0 || interval >= self.survival.length() {
    abort("LifeTable::survival_at: interval out of range")
  }
  self.survival[interval]
}

///|
pub fn LifeTable::hazard_at(self : LifeTable, interval : Int) -> Double {
  if interval < 0 ||
    interval >= self.exposed.length() ||
    self.exposed[interval] == 0.0 {
    0.0
  } else {
    self.deaths[interval] / self.exposed[interval]
  }
}

///|
pub fn LifeTable::intervals(self : LifeTable) -> Array[Double] {
  self.intervals.copy()
}

///|
pub fn LifeTable::survival_curve(self : LifeTable) -> Array[Double] {
  self.survival.copy()
}

///|
pub fn LifeTable::total_exposure(self : LifeTable) -> Double {
  sum(self.exposed)
}

///|
pub fn LifeTable::total_deaths(self : LifeTable) -> Double {
  sum(self.deaths)
}

///|
pub fn concordance_index(
  actual : Array[Double],
  predicted : Array[Double],
  status : Array[Bool],
) -> Double {
  if actual.length() != predicted.length() ||
    actual.length() != status.length() ||
    actual.length() == 0 {
    abort("concordance_index: invalid inputs")
  }
  let mut comparable = 0
  let mut concordant = 0.0
  for left in 0..<actual.length() {
    for right in (left + 1)..<actual.length() {
      if status[left] && actual[left] < actual[right] {
        comparable = comparable + 1
        if predicted[left] > predicted[right] {
          concordant = concordant + 1.0
        } else if predicted[left] == predicted[right] {
          concordant = concordant + 0.5
        }
      } else if status[right] && actual[right] < actual[left] {
        comparable = comparable + 1
        if predicted[right] > predicted[left] {
          concordant = concordant + 1.0
        } else if predicted[right] == predicted[left] {
          concordant = concordant + 0.5
        }
      }
    }
  }
  if comparable == 0 {
    0.0
  } else {
    concordant / comparable.to_double()
  }
}

///|
pub fn brier_survival_score(
  actual : Array[Double],
  status : Array[Bool],
  predicted : Array[Double],
  horizon : Double,
) -> Double {
  if actual.length() != status.length() ||
    actual.length() != predicted.length() ||
    actual.length() == 0 ||
    horizon <= 0.0 {
    abort("brier_survival_score: invalid inputs")
  }
  let mut result = 0.0
  for index in 0..<actual.length() {
    let target = if status[index] && actual[index] <= horizon {
      0.0
    } else {
      1.0
    }
    let error = predicted[index] - target
    result = result + error * error
  }
  result / actual.length().to_double()
}

///|
pub fn integrated_brier_score(
  times : Array[Double],
  status : Array[Bool],
  curves : Array[Array[Double]],
  horizons : Array[Double],
) -> Double {
  if times.length() != status.length() ||
    times.length() != curves.length() ||
    horizons.length() == 0 {
    abort("integrated_brier_score: invalid inputs")
  }
  let mut total = 0.0
  for horizon_index, horizon in horizons {
    let predictions = curves.map(fn(curve) {
      if horizon_index >= curve.length() {
        0.0
      } else {
        curve[horizon_index]
      }
    })
    total = total + brier_survival_score(times, status, predictions, horizon)
  }
  total / horizons.length().to_double()
}

///|
pub fn competing_risk_cumulative_incidence(
  events : Array[Int],
  causes : Array[Int],
  target_cause : Int,
) -> Array[Double] {
  if events.length() != causes.length() {
    abort("competing_risk_cumulative_incidence: lengths must match")
  }
  let result = Array::make(events.length(), 0.0)
  let mut risk = events.length().to_double()
  let mut cumulative = 0.0
  for index in 0..<events.length() {
    let cause_events = if causes[index] == target_cause {
      events[index].to_double()
    } else {
      0.0
    }
    let hazard = if risk == 0.0 { 0.0 } else { cause_events / risk }
    cumulative = cumulative + hazard
    result[index] = cumulative
    risk = risk - events[index].to_double()
  }
  result
}

///|
pub fn rmst_difference(
  left : KaplanMeier,
  right : KaplanMeier,
  horizon : Double,
) -> Double {
  left.restricted_mean(horizon) - right.restricted_mean(horizon)
}

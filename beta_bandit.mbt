///|
/// A reproducible multi-armed Bernoulli bandit built from Beta posteriors.
pub struct BetaArm {
  name : String
  posterior : BetaBinomial
  pulls : Int
  reward_sum : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn BetaArm::new(name : String, alpha : Double, beta : Double) -> BetaArm {
  { name, posterior: BetaBinomial::new(alpha, beta), pulls: 0, reward_sum: 0 }
}

///|
pub fn BetaArm::name(self : BetaArm) -> String {
  self.name
}

///|
pub fn BetaArm::posterior(self : BetaArm) -> BetaBinomial {
  self.posterior
}

///|
pub fn BetaArm::pulls(self : BetaArm) -> Int {
  self.pulls
}

///|
pub fn BetaArm::reward_sum(self : BetaArm) -> Int {
  self.reward_sum
}

///|
pub fn BetaArm::empirical_rate(self : BetaArm) -> Double {
  if self.pulls == 0 {
    0.0
  } else {
    self.reward_sum.to_double() / self.pulls.to_double()
  }
}

///|
pub fn BetaArm::observe(self : BetaArm, reward : Bool) -> BetaArm {
  let success = if reward { 1 } else { 0 }
  {
    ..self,
    posterior: self.posterior.update(success, 1),
    pulls: self.pulls + 1,
    reward_sum: self.reward_sum + success,
  }
}

///|
pub fn BetaArm::optimistic_score(self : BetaArm, z : Double) -> Double {
  if z < 0.0 {
    abort("BetaArm::optimistic_score: z must be non-negative")
  }
  self.posterior.posterior_mean() +
  z * self.posterior.posterior_variance().sqrt()
}

///|
pub struct BanditPolicy {
  arms : Array[BetaArm]
  rounds : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn BanditPolicy::new(arms : Array[BetaArm]) -> BanditPolicy {
  if arms.length() == 0 {
    abort("BanditPolicy: at least one arm is required")
  }
  { arms: arms.copy(), rounds: 0 }
}

///|
pub fn BanditPolicy::arms(self : BanditPolicy) -> Array[BetaArm] {
  self.arms.copy()
}

///|
pub fn BanditPolicy::rounds(self : BanditPolicy) -> Int {
  self.rounds
}

///|
pub fn BanditPolicy::best_arm(self : BanditPolicy) -> Int {
  let mut best = 0
  for index in 1..<self.arms.length() {
    if self.arms[index].posterior().posterior_mean() >
      self.arms[best].posterior().posterior_mean() {
      best = index
    }
  }
  best
}

///|
pub fn BanditPolicy::select_upper_confidence(
  self : BanditPolicy,
  exploration : Double,
) -> Int {
  if exploration < 0.0 {
    abort("BanditPolicy: exploration must be non-negative")
  }
  let mut best = 0
  let mut score = self.arms[0].optimistic_score(exploration)
  for index in 1..<self.arms.length() {
    let candidate = self.arms[index].optimistic_score(exploration)
    if candidate > score {
      best = index
      score = candidate
    }
  }
  best
}

///|
pub fn BanditPolicy::observe(
  self : BanditPolicy,
  arm : Int,
  reward : Bool,
) -> BanditPolicy {
  if arm < 0 || arm >= self.arms.length() {
    abort("BanditPolicy: arm out of range")
  }
  let arms = self.arms.copy()
  arms[arm] = arms[arm].observe(reward)
  { arms, rounds: self.rounds + 1 }
}

///|
pub fn BanditPolicy::recommendation(self : BanditPolicy) -> String {
  self.arms[self.best_arm()].name()
}

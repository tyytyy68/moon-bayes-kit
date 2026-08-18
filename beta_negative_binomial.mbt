///|
/// Beta-Negative-Binomial conjugate model for repeated-trial event counts.
/// The model estimates the probability of success before a fixed number of
/// failures. It is useful for reliability, conversion funnels, and retry data.
pub struct BetaNegativeBinomial {
  alpha : Double
  beta : Double
  failures : Int
  successes : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn BetaNegativeBinomial::new(
  alpha : Double,
  beta : Double,
) -> BetaNegativeBinomial {
  if alpha <= 0.0 || beta <= 0.0 {
    abort("BetaNegativeBinomial: parameters must be positive")
  }
  { alpha, beta, failures: 0, successes: 0 }
}

///|
pub fn BetaNegativeBinomial::update(
  self : BetaNegativeBinomial,
  successes : Int,
  failures : Int,
) -> BetaNegativeBinomial {
  if successes < 0 || failures < 0 {
    abort("BetaNegativeBinomial: counts must be non-negative")
  }
  {
    alpha: self.alpha + successes.to_double(),
    beta: self.beta + failures.to_double(),
    successes: self.successes + successes,
    failures: self.failures + failures,
  }
}

///|
pub fn BetaNegativeBinomial::observe_failure(
  self : BetaNegativeBinomial,
) -> BetaNegativeBinomial {
  self.update(0, 1)
}

///|
pub fn BetaNegativeBinomial::observe_success(
  self : BetaNegativeBinomial,
) -> BetaNegativeBinomial {
  self.update(1, 0)
}

///|
pub fn BetaNegativeBinomial::posterior_mean(
  self : BetaNegativeBinomial,
) -> Double {
  self.alpha / (self.alpha + self.beta)
}

///|
pub fn BetaNegativeBinomial::posterior_variance(
  self : BetaNegativeBinomial,
) -> Double {
  let total = self.alpha + self.beta
  self.alpha * self.beta / (total * total * (total + 1.0))
}

///|
pub fn BetaNegativeBinomial::posterior_mode(
  self : BetaNegativeBinomial,
) -> Double {
  if self.alpha > 1.0 && self.beta > 1.0 {
    (self.alpha - 1.0) / (self.alpha + self.beta - 2.0)
  } else {
    self.posterior_mean()
  }
}

///|
pub fn BetaNegativeBinomial::expected_failures_before_success(
  self : BetaNegativeBinomial,
) -> Double {
  if self.alpha <= 1.0 {
    0.0
  } else {
    self.beta / (self.alpha - 1.0)
  }
}

///|
pub fn BetaNegativeBinomial::predictive_success_probability(
  self : BetaNegativeBinomial,
) -> Double {
  self.posterior_mean()
}

///|
pub fn BetaNegativeBinomial::predictive_failure_probability(
  self : BetaNegativeBinomial,
) -> Double {
  1.0 - self.posterior_mean()
}

///|
pub fn BetaNegativeBinomial::probability_of_failures(
  self : BetaNegativeBinomial,
  failures : Int,
) -> Double {
  if failures < 0 {
    abort("BetaNegativeBinomial: failures must be non-negative")
  }
  let mut result = self.alpha / (self.alpha + self.beta)
  for index in 0..<failures {
    result = result *
      (self.beta + index.to_double()) /
      (self.alpha + self.beta + index.to_double() + 1.0)
  }
  result
}

///|
pub fn BetaNegativeBinomial::failure_distribution(
  self : BetaNegativeBinomial,
  maximum : Int,
) -> Array[Double] {
  if maximum < 0 {
    abort("BetaNegativeBinomial: maximum must be non-negative")
  }
  let result = []
  for failures in 0..<=maximum {
    result.push(self.probability_of_failures(failures))
  }
  result
}

///|
pub fn BetaNegativeBinomial::credible_interval_95(
  self : BetaNegativeBinomial,
) -> (Double, Double) {
  let margin = 1.96 * self.posterior_variance().sqrt()
  (
    (self.posterior_mean() - margin).max(0.0),
    (self.posterior_mean() + margin).min(1.0),
  )
}

///|
pub fn BetaNegativeBinomial::total_observations(
  self : BetaNegativeBinomial,
) -> Int {
  self.successes + self.failures
}

///|
pub fn BetaNegativeBinomial::successes(self : BetaNegativeBinomial) -> Int {
  self.successes
}

///|
pub fn BetaNegativeBinomial::failures(self : BetaNegativeBinomial) -> Int {
  self.failures
}

///|
pub fn BetaNegativeBinomial::summary(
  self : BetaNegativeBinomial,
) -> PredictiveSummary {
  let mean = self.posterior_mean()
  let variance = self.posterior_variance()
  let margin = 1.96 * variance.sqrt()
  PredictiveSummary::new(
    mean,
    variance,
    (mean - margin).max(0.0),
    (mean + margin).min(1.0),
  )
}

///|
pub fn combine_beta_negative_binomial(
  left : BetaNegativeBinomial,
  right : BetaNegativeBinomial,
) -> BetaNegativeBinomial {
  {
    alpha: left.alpha + right.alpha - 1.0,
    beta: left.beta + right.beta - 1.0,
    failures: left.failures + right.failures,
    successes: left.successes + right.successes,
  }
}

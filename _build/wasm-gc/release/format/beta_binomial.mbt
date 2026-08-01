///|
/// Beta-Binomial conjugate model.
pub(all) struct BetaBinomial {
  alpha : Double
  beta : Double
} derive(ToJson, FromJson, Debug, Eq)

///|
/// Creates a new BetaBinomial model with given prior parameters.
pub fn BetaBinomial::new(alpha : Double, beta : Double) -> BetaBinomial {
  if alpha <= 0.0 || beta <= 0.0 {
    abort("BetaBinomial::new: alpha and beta must be positive")
  }
  { alpha, beta }
}

///|
/// Update the prior with data to compute the posterior.
/// `successes` is the number of successful trials.
/// `trials` is the total number of trials.
pub fn BetaBinomial::update(
  self : BetaBinomial,
  successes : Int,
  trials : Int,
) -> BetaBinomial {
  if successes < 0 || trials < 0 || successes > trials {
    abort(
      "BetaBinomial::update: successes and trials must be non-negative, and successes <= trials",
    )
  }
  let s = successes.to_double()
  let t = trials.to_double()
  { alpha: self.alpha + s, beta: self.beta + t - s }
}

///|
/// The mean of the posterior distribution.
pub fn BetaBinomial::posterior_mean(self : BetaBinomial) -> Double {
  self.alpha / (self.alpha + self.beta)
}

///|
/// The variance of the posterior distribution.
pub fn BetaBinomial::posterior_variance(self : BetaBinomial) -> Double {
  let sum = self.alpha + self.beta
  self.alpha * self.beta / (sum * sum * (sum + 1.0))
}

///|
/// Returns the posterior predictive mean for a given number of new trials.
pub fn BetaBinomial::posterior_predictive_mean(
  self : BetaBinomial,
  new_trials : Int,
) -> Double {
  let n = new_trials.to_double()
  n * self.alpha / (self.alpha + self.beta)
}

///|
/// Returns the posterior predictive variance for a given number of new trials.
pub fn BetaBinomial::posterior_predictive_variance(
  self : BetaBinomial,
  new_trials : Int,
) -> Double {
  let n = new_trials.to_double()
  let sum = self.alpha + self.beta
  let mean = self.alpha / sum
  n * mean * (1.0 - mean) * (sum + n) / (sum + 1.0)
}

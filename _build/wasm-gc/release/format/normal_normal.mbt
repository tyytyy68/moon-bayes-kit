///|
/// Normal-Normal conjugate model for the mean of a normal distribution with known data variance.
pub(all) struct NormalNormal {
  prior_mean : Double
  prior_variance : Double
  data_variance : Double
} derive(ToJson, FromJson, Debug, Eq)

///|
/// Creates a new NormalNormal model.
pub fn NormalNormal::new(
  prior_mean : Double,
  prior_variance : Double,
  data_variance : Double,
) -> NormalNormal {
  if prior_variance <= 0.0 || data_variance <= 0.0 {
    abort("NormalNormal::new: variances must be positive")
  }
  { prior_mean, prior_variance, data_variance }
}

///|
/// Update the prior with data to compute the posterior.
/// `sample_mean` is the mean of the observed data.
/// `n` is the number of observations.
pub fn NormalNormal::update(
  self : NormalNormal,
  sample_mean : Double,
  n : Int,
) -> NormalNormal {
  if n < 0 {
    abort("NormalNormal::update: n must be non-negative")
  }
  if n == 0 {
    return self
  }
  let n_f = n.to_double()
  let prior_prec = 1.0 / self.prior_variance
  let data_prec = n_f / self.data_variance
  let post_prec = prior_prec + data_prec
  let post_mean = (prior_prec * self.prior_mean + data_prec * sample_mean) /
    post_prec
  let post_var = 1.0 / post_prec

  {
    prior_mean: post_mean,
    prior_variance: post_var,
    data_variance: self.data_variance,
  }
}

///|
/// The mean of the posterior distribution.
pub fn NormalNormal::posterior_mean(self : NormalNormal) -> Double {
  self.prior_mean
}

///|
/// The variance of the posterior distribution.
pub fn NormalNormal::posterior_variance(self : NormalNormal) -> Double {
  self.prior_variance
}

///|
/// Returns the posterior predictive mean for a single new observation.
pub fn NormalNormal::posterior_predictive_mean(self : NormalNormal) -> Double {
  self.prior_mean
}

///|
/// Returns the posterior predictive variance for a single new observation.
pub fn NormalNormal::posterior_predictive_variance(
  self : NormalNormal,
) -> Double {
  self.prior_variance + self.data_variance
}

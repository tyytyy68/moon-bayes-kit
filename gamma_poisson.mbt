///|
/// Gamma-Poisson conjugate model.
pub(all) struct GammaPoisson {
  shape : Double
  rate : Double
} derive(ToJson, FromJson, Debug, Eq)

///|
/// Creates a new GammaPoisson model with given prior parameters.
pub fn GammaPoisson::new(shape : Double, rate : Double) -> GammaPoisson {
  if shape <= 0.0 || rate <= 0.0 {
    abort("GammaPoisson::new: shape and rate must be positive")
  }
  { shape, rate }
}

///|
/// Update the prior with data to compute the posterior.
/// `sum_x` is the sum of observed counts.
/// `n` is the number of observations.
pub fn GammaPoisson::update(self : GammaPoisson, sum_x : Int, n : Int) -> GammaPoisson {
  if sum_x < 0 || n < 0 {
    abort("GammaPoisson::update: sum_x and n must be non-negative")
  }
  let s = sum_x.to_double()
  let c = n.to_double()
  { shape: self.shape + s, rate: self.rate + c }
}

///|
/// The mean of the posterior distribution.
pub fn GammaPoisson::posterior_mean(self : GammaPoisson) -> Double {
  self.shape / self.rate
}

///|
/// The variance of the posterior distribution.
pub fn GammaPoisson::posterior_variance(self : GammaPoisson) -> Double {
  self.shape / (self.rate * self.rate)
}

///|
/// Returns the posterior predictive mean for a single new observation.
pub fn GammaPoisson::posterior_predictive_mean(self : GammaPoisson) -> Double {
  self.shape / self.rate
}

///|
/// Returns the posterior predictive variance for a single new observation.
pub fn GammaPoisson::posterior_predictive_variance(self : GammaPoisson) -> Double {
  self.shape * (self.rate + 1.0) / (self.rate * self.rate)
}

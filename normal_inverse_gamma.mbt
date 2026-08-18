///|
/// Normal-Inverse-Gamma posterior for an unknown mean and unknown variance.
pub struct NormalInverseGamma {
  mean : Double
  scale : Double
  shape : Double
  rate : Double
  observations : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn NormalInverseGamma::new(
  mean : Double,
  scale : Double,
  shape : Double,
  rate : Double,
) -> NormalInverseGamma {
  if scale <= 0.0 || shape <= 0.0 || rate <= 0.0 {
    abort("NormalInverseGamma: parameters must be positive")
  }
  { mean, scale, shape, rate, observations: 0 }
}

///|
pub fn NormalInverseGamma::update(
  self : NormalInverseGamma,
  sample_mean : Double,
  sample_variance : Double,
  count : Int,
) -> NormalInverseGamma {
  if count < 0 || sample_variance < 0.0 {
    abort("NormalInverseGamma: invalid sample statistics")
  }
  if count == 0 {
    return self
  }
  let count_f = count.to_double()
  let next_scale = self.scale + count_f
  let difference = sample_mean - self.mean
  let next_mean = (self.scale * self.mean + count_f * sample_mean) / next_scale
  let next_shape = self.shape + count_f / 2.0
  let correction = self.scale *
    count_f *
    difference *
    difference /
    (2.0 * next_scale)
  let next_rate = self.rate +
    (count_f - 1.0) * sample_variance / 2.0 +
    correction
  {
    mean: next_mean,
    scale: next_scale,
    shape: next_shape,
    rate: next_rate,
    observations: self.observations + count,
  }
}

///|
pub fn NormalInverseGamma::update_one(
  self : NormalInverseGamma,
  value : Double,
) -> NormalInverseGamma {
  self.update(value, 0.0, 1)
}

///|
pub fn NormalInverseGamma::posterior_mean(self : NormalInverseGamma) -> Double {
  self.mean
}

///|
pub fn NormalInverseGamma::variance_mean(self : NormalInverseGamma) -> Double {
  if self.shape <= 1.0 {
    0.0
  } else {
    self.rate / ((self.shape - 1.0) * self.scale)
  }
}

///|
pub fn NormalInverseGamma::variance_mode(self : NormalInverseGamma) -> Double {
  self.rate / (self.shape + 1.0)
}

///|
pub fn NormalInverseGamma::predictive_variance(
  self : NormalInverseGamma,
) -> Double {
  self.rate * (self.scale + 1.0) / (self.shape * self.scale)
}

///|
pub fn NormalInverseGamma::predictive_summary(
  self : NormalInverseGamma,
) -> PredictiveSummary {
  let variance = self.predictive_variance()
  let margin = 1.96 * variance.sqrt()
  PredictiveSummary::new(
    self.mean,
    variance,
    self.mean - margin,
    self.mean + margin,
  )
}

///|
pub fn NormalInverseGamma::credible_interval_95(
  self : NormalInverseGamma,
) -> (Double, Double) {
  self.predictive_summary().credible_interval()
}

///|
pub fn NormalInverseGamma::precision(self : NormalInverseGamma) -> Double {
  self.scale
}

///|
pub fn NormalInverseGamma::observations(self : NormalInverseGamma) -> Int {
  self.observations
}

///|
pub fn NormalInverseGamma::merge(
  self : NormalInverseGamma,
  other : NormalInverseGamma,
) -> NormalInverseGamma {
  if other.observations == 0 {
    return self
  }
  if self.observations == 0 {
    return other
  }
  let total = self.observations + other.observations
  let combined_mean = (
      self.observations.to_double() * self.mean +
      other.observations.to_double() * other.mean
    ) /
    total.to_double()
  let between = self.observations.to_double() *
    other.observations.to_double() *
    (self.mean - other.mean) *
    (self.mean - other.mean) /
    (2.0 * total.to_double())
  {
    mean: combined_mean,
    scale: self.scale + other.scale - 2.0,
    shape: self.shape + other.shape - 1.0,
    rate: self.rate + other.rate + between,
    observations: total,
  }
}

///|
pub fn NormalInverseGamma::standardized(
  self : NormalInverseGamma,
  value : Double,
) -> Double {
  (value - self.mean) / self.predictive_variance().sqrt()
}

///|
pub fn NormalInverseGamma::information_criterion(
  self : NormalInverseGamma,
  residual : Double,
) -> Double {
  if residual <= 0.0 {
    abort("NormalInverseGamma: residual must be positive")
  }
  self.observations.to_double() * residual + 4.0
}

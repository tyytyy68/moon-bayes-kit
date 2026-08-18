///|
/// Common summaries for distributions used by applications without requiring
/// callers to know the concrete conjugate model implementation.
pub enum DistributionKind {
  Bernoulli
  Count
  Continuous
  Categorical
} derive(Debug, Eq, ToJson, FromJson)

///|
pub struct DistributionSummary {
  kind : DistributionKind
  mean : Double
  variance : Double
  support_lower : Double
  support_upper : Double?
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn DistributionSummary::new(
  kind : DistributionKind,
  mean : Double,
  variance : Double,
  lower : Double,
  upper : Double?,
) -> DistributionSummary {
  if variance < 0.0 {
    abort("DistributionSummary: variance must be non-negative")
  }
  { kind, mean, variance, support_lower: lower, support_upper: upper }
}

///|
pub fn DistributionSummary::kind(
  self : DistributionSummary,
) -> DistributionKind {
  self.kind
}

///|
pub fn DistributionSummary::mean(self : DistributionSummary) -> Double {
  self.mean
}

///|
pub fn DistributionSummary::variance(self : DistributionSummary) -> Double {
  self.variance
}

///|
pub fn DistributionSummary::standard_deviation(
  self : DistributionSummary,
) -> Double {
  self.variance.sqrt()
}

///|
pub fn DistributionSummary::support_lower(self : DistributionSummary) -> Double {
  self.support_lower
}

///|
pub fn DistributionSummary::support_upper(
  self : DistributionSummary,
) -> Double? {
  self.support_upper
}

///|
pub fn BetaBinomial::summary(self : BetaBinomial) -> DistributionSummary {
  DistributionSummary::new(
    Bernoulli,
    self.posterior_mean(),
    self.posterior_variance(),
    0.0,
    Some(1.0),
  )
}

///|
pub fn GammaPoisson::summary(self : GammaPoisson) -> DistributionSummary {
  DistributionSummary::new(
    Count,
    self.posterior_mean(),
    self.posterior_variance(),
    0.0,
    None,
  )
}

///|
pub fn NormalNormal::summary(self : NormalNormal) -> DistributionSummary {
  DistributionSummary::new(
    Continuous,
    self.posterior_mean(),
    self.posterior_variance(),
    -1.0 / 0.0,
    None,
  )
}

///|
pub fn DirichletMultinomial::summary(
  self : DirichletMultinomial,
) -> Array[DistributionSummary] {
  self
  .posterior_mean()
  .mapi(fn(index, value) {
    DistributionSummary::new(
      Categorical,
      value,
      self.posterior_variance()[index],
      0.0,
      Some(1.0),
    )
  })
}

///|
pub fn bernoulli_summary(probability : Double) -> DistributionSummary {
  if probability < 0.0 || probability > 1.0 {
    abort("Bernoulli::to_summary: probability out of range")
  }
  DistributionSummary::new(
    Bernoulli,
    probability,
    probability * (1.0 - probability),
    0.0,
    Some(1.0),
  )
}

///|
pub fn poisson_summary(rate : Double) -> DistributionSummary {
  if rate < 0.0 {
    abort("poisson_summary: rate must be non-negative")
  }
  DistributionSummary::new(Count, rate, rate, 0.0, None)
}

///|
pub fn normal_summary(
  mean_value : Double,
  variance_value : Double,
) -> DistributionSummary {
  if variance_value < 0.0 {
    abort("normal_summary: variance must be non-negative")
  }
  DistributionSummary::new(
    Continuous,
    mean_value,
    variance_value,
    0.0 - 1.0 / 0.0,
    None,
  )
}

///|
pub fn categorical_summary(
  probabilities : Array[Double],
) -> Array[DistributionSummary] {
  let normalized = normalize_probabilities(probabilities)
  normalized.map(fn(probability) {
    DistributionSummary::new(
      Categorical,
      probability,
      probability * (1.0 - probability),
      0.0,
      Some(1.0),
    )
  })
}

///|
pub fn entropy_bernoulli(probability : Double) -> Double {
  if probability <= 0.0 || probability >= 1.0 {
    0.0
  } else {
    probability * (1.0 - probability)
  }
}

///|
pub fn gini_impurity(probabilities : Array[Double]) -> Double {
  let normalized = normalize_probabilities(probabilities)
  1.0 - normalized.fold(init=0.0, (total, value) => total + value * value)
}

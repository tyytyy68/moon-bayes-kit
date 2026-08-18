///|
/// A compact immutable record of a model's posterior state and predictive checks.
pub struct PredictiveSummary {
  mean : Double
  variance : Double
  lower_95 : Double
  upper_95 : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn PredictiveSummary::new(
  mean : Double,
  variance : Double,
  lower_95 : Double,
  upper_95 : Double,
) -> PredictiveSummary {
  if variance < 0.0 {
    abort("PredictiveSummary: variance must be non-negative")
  }
  if lower_95 > upper_95 {
    abort("PredictiveSummary: interval is inverted")
  }
  { mean, variance, lower_95, upper_95 }
}

///|
pub fn PredictiveSummary::mean(self : PredictiveSummary) -> Double {
  self.mean
}

///|
pub fn PredictiveSummary::variance(self : PredictiveSummary) -> Double {
  self.variance
}

///|
pub fn PredictiveSummary::standard_deviation(
  self : PredictiveSummary,
) -> Double {
  self.variance.sqrt()
}

///|
pub fn PredictiveSummary::credible_interval(
  self : PredictiveSummary,
) -> (Double, Double) {
  (self.lower_95, self.upper_95)
}

///|
pub fn BetaBinomial::posterior_mode(self : BetaBinomial) -> Double {
  if self.alpha > 1.0 && self.beta > 1.0 {
    (self.alpha - 1.0) / (self.alpha + self.beta - 2.0)
  } else {
    self.posterior_mean()
  }
}

///|
pub fn BetaBinomial::effective_sample_size(self : BetaBinomial) -> Double {
  self.alpha + self.beta
}

///|
pub fn BetaBinomial::prior_strength(self : BetaBinomial) -> Double {
  self.alpha + self.beta
}

///|
pub fn BetaBinomial::posterior_predictive_summary(
  self : BetaBinomial,
  trials : Int,
) -> PredictiveSummary {
  let mean = self.posterior_predictive_mean(trials)
  let variance = self.posterior_predictive_variance(trials)
  let margin = 1.96 * variance.sqrt()
  PredictiveSummary::new(
    mean,
    variance,
    (mean - margin).max(0.0),
    (mean + margin).min(trials.to_double()),
  )
}

///|
pub fn GammaPoisson::posterior_mode(self : GammaPoisson) -> Double {
  if self.shape >= 1.0 {
    (self.shape - 1.0) / self.rate
  } else {
    0.0
  }
}

///|
pub fn GammaPoisson::effective_exposure(self : GammaPoisson) -> Double {
  self.rate
}

///|
pub fn GammaPoisson::posterior_predictive_summary(
  self : GammaPoisson,
) -> PredictiveSummary {
  let mean = self.posterior_predictive_mean()
  let variance = self.posterior_predictive_variance()
  let margin = 1.96 * variance.sqrt()
  PredictiveSummary::new(
    mean,
    variance,
    (mean - margin).max(0.0),
    mean + margin,
  )
}

///|
pub fn NormalNormal::posterior_predictive_summary(
  self : NormalNormal,
) -> PredictiveSummary {
  let mean = self.posterior_predictive_mean()
  let variance = self.posterior_predictive_variance()
  let margin = 1.96 * variance.sqrt()
  PredictiveSummary::new(mean, variance, mean - margin, mean + margin)
}

///|
pub fn NormalNormal::precision(self : NormalNormal) -> Double {
  1.0 / self.prior_variance
}

///|
pub fn NormalNormal::information_weight(self : NormalNormal) -> Double {
  self.data_variance / self.prior_variance
}

///|
pub fn DirichletMultinomial::category_count(self : DirichletMultinomial) -> Int {
  self.alpha.length()
}

///|
pub fn DirichletMultinomial::total_concentration(
  self : DirichletMultinomial,
) -> Double {
  sum(self.alpha)
}

///|
pub fn DirichletMultinomial::posterior_mode(
  self : DirichletMultinomial,
) -> Array[Double] {
  let adjusted = self.alpha.map(fn(value) { (value - 1.0).max(0.0) })
  let adjusted_total = sum(adjusted)
  if adjusted_total == 0.0 {
    self.posterior_mean()
  } else {
    adjusted.map(fn(value) { value / adjusted_total })
  }
}

///|
pub fn DirichletMultinomial::entropy(self : DirichletMultinomial) -> Double {
  // A stable, dependency-free plug-in entropy is useful for monitoring drift.
  self
  .posterior_mean()
  .fold(init=0.0, (result, probability) => {
    if probability <= 0.0 {
      result
    } else {
      result - probability * probability.sqrt()
    }
  })
}

///|
pub fn DirichletMultinomial::posterior_predictive_summary(
  self : DirichletMultinomial,
  trials : Int,
) -> Array[PredictiveSummary] {
  let means = self.posterior_predictive_mean(trials)
  let variances = self
    .posterior_variance()
    .map(fn(value) {
      let n = trials.to_double()
      n *
      value *
      (self.total_concentration() + n) /
      (self.total_concentration() + 1.0)
    })
  means.mapi(fn(index, value) {
    let margin = 1.96 * variances[index].sqrt()
    PredictiveSummary::new(
      value,
      variances[index],
      (value - margin).max(0.0),
      value + margin,
    )
  })
}

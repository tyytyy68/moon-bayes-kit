///|
/// Online ridge regression facade with explicit regularization and diagnostics.
pub struct OnlineRidge {
  model : BayesianLinearRegression
  regularization : Double
  updates : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn OnlineRidge::new(
  feature_count : Int,
  regularization : Double,
  noise : Double,
) -> OnlineRidge {
  if feature_count <= 0 || regularization <= 0.0 {
    abort("OnlineRidge: invalid parameters")
  }
  {
    model: BayesianLinearRegression::new(
      Array::make(feature_count, 0.0),
      1.0 / regularization,
      noise,
    ),
    regularization,
    updates: 0,
  }
}

///|
pub fn OnlineRidge::update(
  self : OnlineRidge,
  features : Array[Double],
  target : Double,
) -> OnlineRidge {
  {
    ..self,
    model: self.model.add_observation(features, target),
    updates: self.updates + 1,
  }
}

///|
pub fn OnlineRidge::fit(
  self : OnlineRidge,
  features : Array[Array[Double]],
  targets : Array[Double],
) -> OnlineRidge {
  {
    ..self,
    model: self.model.fit(features, targets),
    updates: self.updates + features.length(),
  }
}

///|
pub fn OnlineRidge::predict(
  self : OnlineRidge,
  features : Array[Double],
) -> Double {
  self.model.predict(features)
}

///|
pub fn OnlineRidge::predict_variance(
  self : OnlineRidge,
  features : Array[Double],
) -> Double {
  self.model.predict_variance(features)
}

///|
pub fn OnlineRidge::coefficients(self : OnlineRidge) -> Array[Double] {
  self.model.posterior_mean()
}

///|
pub fn OnlineRidge::coefficient_uncertainty(
  self : OnlineRidge,
) -> Array[Double] {
  self.model.posterior_covariance().diagonal()
}

///|
pub fn OnlineRidge::residuals(
  self : OnlineRidge,
  features : Array[Array[Double]],
  targets : Array[Double],
) -> Array[Double] {
  self.model.residuals(features, targets)
}

///|
pub fn OnlineRidge::r_squared(
  self : OnlineRidge,
  features : Array[Array[Double]],
  targets : Array[Double],
) -> Double {
  self.model.r_squared(features, targets)
}

///|
pub fn OnlineRidge::updates(self : OnlineRidge) -> Int {
  self.updates
}

///|
pub fn OnlineRidge::regularization(self : OnlineRidge) -> Double {
  self.regularization
}

///|
pub fn OnlineRidge::feature_importance(self : OnlineRidge) -> Array[Double] {
  self.coefficients().map(fn(value) { value.abs() })
}

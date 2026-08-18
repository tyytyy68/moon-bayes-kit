///|
/// Bayesian linear regression with a diagonal Gaussian prior.
///
/// The implementation keeps the sufficient statistics `X'X` and `X'y`, so
/// repeated micro-batches do not retain the original data. A ridge term makes
/// the small-model API useful for sensor calibration and online forecasting.
pub struct BayesianLinearRegression {
  prior_mean : Array[Double]
  prior_precision : DenseMatrix
  precision : DenseMatrix
  information : Array[Double]
  noise_variance : Double
  observations : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn BayesianLinearRegression::new(
  prior_mean : Array[Double],
  prior_variance : Double,
  noise_variance : Double,
) -> BayesianLinearRegression {
  if prior_mean.length() == 0 {
    abort("BayesianLinearRegression: at least one feature is required")
  }
  if prior_variance <= 0.0 || noise_variance <= 0.0 {
    abort("BayesianLinearRegression: variances must be positive")
  }
  let size = prior_mean.length()
  let prior_precision = DenseMatrix::identity(size).scale(1.0 / prior_variance)
  {
    prior_mean: prior_mean.copy(),
    prior_precision,
    precision: prior_precision,
    information: prior_mean.map(fn(value) { value / prior_variance }),
    noise_variance,
    observations: 0,
  }
}

///|
pub fn BayesianLinearRegression::feature_count(
  self : BayesianLinearRegression,
) -> Int {
  self.prior_mean.length()
}

///|
pub fn BayesianLinearRegression::add_observation(
  self : BayesianLinearRegression,
  features : Array[Double],
  target : Double,
) -> BayesianLinearRegression {
  if features.length() != self.feature_count() {
    abort("BayesianLinearRegression: feature length mismatch")
  }
  let scale = 1.0 / self.noise_variance
  let mut precision = self.precision
  let information = self.information.copy()
  for row in 0..<features.length() {
    for column in 0..<features.length() {
      precision = precision.set(
        row,
        column,
        precision.at(row, column) + scale * features[row] * features[column],
      )
    }
    information[row] = information[row] + scale * features[row] * target
  }
  { ..self, precision, information, observations: self.observations + 1 }
}

///|
pub fn BayesianLinearRegression::fit(
  self : BayesianLinearRegression,
  features : Array[Array[Double]],
  targets : Array[Double],
) -> BayesianLinearRegression {
  if features.length() != targets.length() {
    abort("BayesianLinearRegression::fit: row count mismatch")
  }
  features.foldi(init=self, fn(index, model, row) {
    model.add_observation(row, targets[index])
  })
}

///|
pub fn BayesianLinearRegression::posterior_mean(
  self : BayesianLinearRegression,
) -> Array[Double] {
  let factor = cholesky(self.precision)
  let intermediate = solve_lower(factor, self.information)
  solve_upper(factor.transpose(), intermediate)
}

///|
pub fn BayesianLinearRegression::posterior_precision(
  self : BayesianLinearRegression,
) -> DenseMatrix {
  self.precision
}

///|
pub fn BayesianLinearRegression::posterior_covariance(
  self : BayesianLinearRegression,
) -> DenseMatrix {
  let size = self.feature_count()
  let covariance = DenseMatrix::zeros(size, size)
  let values = covariance.values.copy()
  for column in 0..<size {
    let basis = Array::make(size, 0.0)
    basis[column] = 1.0
    let factor = cholesky(self.precision)
    let intermediate = solve_lower(factor, basis)
    let result = solve_upper(factor.transpose(), intermediate)
    for row in 0..<size {
      values[row * size + column] = result[row]
    }
  }
  DenseMatrix::new(size, size, values)
}

///|
pub fn BayesianLinearRegression::predict(
  self : BayesianLinearRegression,
  features : Array[Double],
) -> Double {
  if features.length() != self.feature_count() {
    abort("BayesianLinearRegression::predict: feature length mismatch")
  }
  dot(self.posterior_mean(), features)
}

///|
pub fn BayesianLinearRegression::predict_variance(
  self : BayesianLinearRegression,
  features : Array[Double],
) -> Double {
  if features.length() != self.feature_count() {
    abort("BayesianLinearRegression::predict_variance: feature length mismatch")
  }
  let covariance = self.posterior_covariance()
  let mut variance = self.noise_variance
  for row in 0..<features.length() {
    for column in 0..<features.length() {
      variance = variance +
        features[row] * covariance.at(row, column) * features[column]
    }
  }
  variance
}

///|
pub fn BayesianLinearRegression::predict_summary(
  self : BayesianLinearRegression,
  features : Array[Double],
) -> PredictiveSummary {
  let mean = self.predict(features)
  let variance = self.predict_variance(features)
  let margin = 1.96 * variance.sqrt()
  PredictiveSummary::new(mean, variance, mean - margin, mean + margin)
}

///|
pub fn BayesianLinearRegression::observations(
  self : BayesianLinearRegression,
) -> Int {
  self.observations
}

///|
pub fn BayesianLinearRegression::residuals(
  self : BayesianLinearRegression,
  features : Array[Array[Double]],
  targets : Array[Double],
) -> Array[Double] {
  if features.length() != targets.length() {
    abort("BayesianLinearRegression::residuals: row count mismatch")
  }
  features.mapi(fn(index, row) { targets[index] - self.predict(row) })
}

///|
pub fn BayesianLinearRegression::r_squared(
  self : BayesianLinearRegression,
  features : Array[Array[Double]],
  targets : Array[Double],
) -> Double {
  if targets.length() == 0 {
    return 0.0
  }
  let predictions = features.map(fn(row) { self.predict(row) })
  let target_mean = mean(targets)
  let mut residual_sum = 0.0
  let mut total_sum = 0.0
  for index in 0..<targets.length() {
    let residual = targets[index] - predictions[index]
    let centered = targets[index] - target_mean
    residual_sum = residual_sum + residual * residual
    total_sum = total_sum + centered * centered
  }
  if total_sum == 0.0 {
    0.0
  } else {
    1.0 - residual_sum / total_sum
  }
}

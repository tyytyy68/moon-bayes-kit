///|
/// State-space filtering for noisy sensors, demand signals, and online control.
pub struct StateEstimate {
  mean : Array[Double]
  covariance : Array[Array[Double]]
  timestamp : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn StateEstimate::dimension(self : StateEstimate) -> Int {
  self.mean.length()
}

///|
pub fn StateEstimate::variance(self : StateEstimate, index : Int) -> Double {
  self.covariance[index][index]
}

///|
pub fn StateEstimate::standard_deviation(
  self : StateEstimate,
  index : Int,
) -> Double {
  self.variance(index).max(0.0).sqrt()
}

///|
pub fn StateEstimate::with_timestamp(
  self : StateEstimate,
  timestamp : Int,
) -> StateEstimate {
  { ..self, timestamp, }
}

///|
pub struct KalmanModel {
  transition : Array[Array[Double]]
  observation : Array[Double]
  process_noise : Array[Array[Double]]
  observation_noise : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn KalmanModel::scalar(
  persistence : Double,
  process_noise : Double,
  observation_noise : Double,
) -> KalmanModel {
  if process_noise < 0.0 || observation_noise <= 0.0 {
    abort("KalmanModel::scalar: invalid noise")
  }
  {
    transition: [[persistence]],
    observation: [1.0],
    process_noise: [[process_noise]],
    observation_noise,
  }
}

///|
pub fn KalmanModel::local_linear(
  process_level : Double,
  process_trend : Double,
  observation_noise : Double,
) -> KalmanModel {
  if process_level < 0.0 || process_trend < 0.0 || observation_noise <= 0.0 {
    abort("KalmanModel::local_linear: invalid noise")
  }
  {
    transition: [[1.0, 1.0], [0.0, 1.0]],
    observation: [1.0, 0.0],
    process_noise: [[process_level, 0.0], [0.0, process_trend]],
    observation_noise,
  }
}

///|
pub fn KalmanModel::dimension(self : KalmanModel) -> Int {
  self.observation.length()
}

///|
pub fn KalmanModel::validate(self : KalmanModel) -> Bool {
  let dimension = self.dimension()
  self.transition.length() == dimension &&
  self.process_noise.length() == dimension &&
  self.transition.all(fn(row) { row.length() == dimension }) &&
  self.process_noise.all(fn(row) { row.length() == dimension })
}

///|
fn matrix_vector_product(
  matrix : Array[Array[Double]],
  vector : Array[Double],
) -> Array[Double] {
  let result : Array[Double] = []
  for row in matrix.iter() {
    if row.length() != vector.length() {
      abort("matrix_vector_product: dimension mismatch")
    }
    let mut value = 0.0
    for index in 0..<vector.length() {
      value = value + row[index] * vector[index]
    }
    result.push(value)
  }
  result
}

///|
fn matrix_product(
  left : Array[Array[Double]],
  right : Array[Array[Double]],
) -> Array[Array[Double]] {
  if left.length() == 0 ||
    right.length() == 0 ||
    left[0].length() != right.length() {
    abort("matrix_product: dimension mismatch")
  }
  let result : Array[Array[Double]] = []
  for row in left.iter() {
    let output : Array[Double] = []
    for column in 0..<right[0].length() {
      let mut value = 0.0
      for index in 0..<right.length() {
        value = value + row[index] * right[index][column]
      }
      output.push(value)
    }
    result.push(output)
  }
  result
}

///|
fn matrix_transpose(matrix : Array[Array[Double]]) -> Array[Array[Double]] {
  if matrix.length() == 0 {
    return []
  }
  let result : Array[Array[Double]] = []
  for column in 0..<matrix[0].length() {
    let row : Array[Double] = []
    for source in matrix.iter() {
      row.push(source[column])
    }
    result.push(row)
  }
  result
}

///|
fn matrix_add(
  left : Array[Array[Double]],
  right : Array[Array[Double]],
) -> Array[Array[Double]] {
  if left.length() != right.length() {
    abort("matrix_add: dimension mismatch")
  }
  let result : Array[Array[Double]] = []
  for row in 0..<left.length() {
    if left[row].length() != right[row].length() {
      abort("matrix_add: dimension mismatch")
    }
    let output : Array[Double] = []
    for column in 0..<left[row].length() {
      output.push(left[row][column] + right[row][column])
    }
    result.push(output)
  }
  result
}

///|
pub fn matrix_subtract(
  left : Array[Array[Double]],
  right : Array[Array[Double]],
) -> Array[Array[Double]] {
  if left.length() != right.length() {
    abort("matrix_subtract: dimension mismatch")
  }
  let result : Array[Array[Double]] = []
  for row in 0..<left.length() {
    let output : Array[Double] = []
    for column in 0..<left[row].length() {
      output.push(left[row][column] - right[row][column])
    }
    result.push(output)
  }
  result
}

///|
pub fn identity_matrix(size : Int) -> Array[Array[Double]] {
  let result : Array[Array[Double]] = []
  for row in 0..<size {
    let values : Array[Double] = []
    for column in 0..<size {
      values.push(if row == column { 1.0 } else { 0.0 })
    }
    result.push(values)
  }
  result
}

///|
fn symmetrize(matrix : Array[Array[Double]]) -> Array[Array[Double]] {
  let result = matrix.map(fn(row) { row.copy() })
  for row in 0..<result.length() {
    for column in 0..<result[row].length() {
      result[row][column] = (matrix[row][column] + matrix[column][row]) / 2.0
    }
  }
  result
}

///|
pub fn StateEstimate::predict(
  self : StateEstimate,
  model : KalmanModel,
) -> StateEstimate {
  if !model.validate() || self.dimension() != model.dimension() {
    abort("StateEstimate::predict: invalid model")
  }
  let transition_t = matrix_transpose(model.transition)
  let mean = matrix_vector_product(model.transition, self.mean)
  let covariance = matrix_add(
    matrix_product(
      matrix_product(model.transition, self.covariance),
      transition_t,
    ),
    model.process_noise,
  )
  { mean, covariance: symmetrize(covariance), timestamp: self.timestamp + 1 }
}

///|
pub struct KalmanUpdate {
  estimate : StateEstimate
  innovation : Double
  innovation_variance : Double
  gain : Array[Double]
  log_likelihood : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn StateEstimate::update(
  self : StateEstimate,
  model : KalmanModel,
  observation_value : Double,
) -> KalmanUpdate {
  if self.dimension() != 1 || model.dimension() != 1 {
    abort("StateEstimate::update: scalar observation required")
  }
  let predicted = model.observation[0] * self.mean[0]
  let innovation = observation_value - predicted
  let innovation_variance = model.observation[0] *
    self.covariance[0][0] *
    model.observation[0] +
    model.observation_noise
  let gain = self.covariance[0][0] * model.observation[0] / innovation_variance
  let mean = [self.mean[0] + gain * innovation]
  let covariance = [
    [(1.0 - gain * model.observation[0]) * self.covariance[0][0]],
  ]
  let log_likelihood = -0.5 *
    (
      innovation * innovation / innovation_variance +
      uncertainty_log(innovation_variance)
    )
  {
    estimate: { mean, covariance, timestamp: self.timestamp },
    innovation,
    innovation_variance,
    gain: [gain],
    log_likelihood,
  }
}

///|
pub fn kalman_initial(
  mean : Double,
  variance : Double,
  timestamp : Int,
) -> StateEstimate {
  if variance < 0.0 {
    abort("kalman_initial: variance must be non-negative")
  }
  { mean: [mean], covariance: [[variance]], timestamp }
}

///|
pub fn kalman_filter(
  model : KalmanModel,
  observations : Array[Double],
  initial : StateEstimate,
) -> Array[KalmanUpdate] {
  if observations.length() == 0 || !model.validate() {
    abort("kalman_filter: invalid inputs")
  }
  let result : Array[KalmanUpdate] = []
  let mut state = initial
  for observation_value in observations.iter() {
    let update = state.predict(model).update(model, observation_value)
    result.push(update)
    state = update.estimate
  }
  result
}

///|
pub fn kalman_log_likelihood(updates : Array[KalmanUpdate]) -> Double {
  updates.fold(init=0.0, (total, update) => total + update.log_likelihood)
}

///|
pub fn kalman_rmse(
  updates : Array[KalmanUpdate],
  observations : Array[Double],
) -> Double {
  if updates.length() != observations.length() || updates.length() == 0 {
    abort("kalman_rmse: lengths must match")
  }
  let mut total = 0.0
  for index in 0..<updates.length() {
    let error = updates[index].estimate.mean[0] - observations[index]
    total = total + error * error
  }
  (total / updates.length().to_double()).sqrt()
}

///|
pub struct LocalLevelModel {
  level : Double
  variance : Double
  observation_noise : Double
  process_noise : Double
  observations : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn LocalLevelModel::new(
  level : Double,
  variance : Double,
  process_noise : Double,
  observation_noise : Double,
) -> LocalLevelModel {
  if variance < 0.0 || process_noise < 0.0 || observation_noise <= 0.0 {
    abort("LocalLevelModel: invalid parameters")
  }
  { level, variance, observation_noise, process_noise, observations: 0 }
}

///|
pub fn LocalLevelModel::update(
  self : LocalLevelModel,
  value : Double,
) -> LocalLevelModel {
  let predicted_variance = self.variance + self.process_noise
  let gain = predicted_variance / (predicted_variance + self.observation_noise)
  {
    ..self,
    level: self.level + gain * (value - self.level),
    variance: (1.0 - gain) * predicted_variance,
    observations: self.observations + 1,
  }
}

///|
pub fn LocalLevelModel::forecast(
  self : LocalLevelModel,
  horizon : Int,
) -> Array[Double] {
  if horizon < 0 {
    abort("LocalLevelModel::forecast: horizon must be non-negative")
  }
  let result : Array[Double] = []
  for _ in 0..<horizon {
    result.push(self.level)
  }
  result
}

///|
pub fn LocalLevelModel::forecast_interval(
  self : LocalLevelModel,
  horizon : Int,
  confidence : Double,
) -> Array[PredictionInterval] {
  if confidence <= 0.0 || confidence >= 1.0 {
    abort("LocalLevelModel::forecast_interval: invalid confidence")
  }
  let z = normal_quantile((1.0 + confidence) / 2.0)
  let result : Array[PredictionInterval] = []
  for step in 1..<=horizon {
    let standard_error = (self.observation_noise +
    step.to_double() * self.process_noise +
    self.variance).sqrt()
    result.push(
      PredictionInterval::new(
        self.level,
        self.level - z * standard_error,
        self.level + z * standard_error,
        confidence,
        IntervalMethod::Gaussian,
      ),
    )
  }
  result
}

///|
pub fn fit_local_level(
  values : Array[Double],
  process_noise : Double,
  observation_noise : Double,
) -> LocalLevelModel {
  if values.length() == 0 {
    abort("fit_local_level: empty values")
  }
  let mut model = LocalLevelModel::new(
    values[0],
    observation_noise,
    process_noise,
    observation_noise,
  )
  for index in 1..<values.length() {
    model = model.update(values[index])
  }
  model
}

///|
pub struct TrendForecast {
  level : Double
  trend : Double
  level_variance : Double
  trend_variance : Double
  observations : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn fit_local_trend(
  values : Array[Double],
  smoothing : Double,
  trend_smoothing : Double,
) -> TrendForecast {
  if values.length() < 2 ||
    smoothing <= 0.0 ||
    smoothing > 1.0 ||
    trend_smoothing <= 0.0 ||
    trend_smoothing > 1.0 {
    abort("fit_local_trend: invalid parameters")
  }
  let mut level = values[0]
  let mut trend = values[1] - values[0]
  for index in 1..<values.length() {
    let previous = level
    level = smoothing * values[index] + (1.0 - smoothing) * (level + trend)
    trend = trend_smoothing * (level - previous) +
      (1.0 - trend_smoothing) * trend
  }
  let increments : Array[Double] = []
  for index in 1..<values.length() {
    increments.push(values[index] - values[index - 1])
  }
  {
    level,
    trend,
    level_variance: variance(values),
    trend_variance: variance(increments),
    observations: values.length(),
  }
}

///|
pub fn TrendForecast::forecast(
  self : TrendForecast,
  horizon : Int,
) -> Array[Double] {
  if horizon < 0 {
    abort("TrendForecast::forecast: horizon must be non-negative")
  }
  let result : Array[Double] = []
  for step in 1..<=horizon {
    result.push(self.level + step.to_double() * self.trend)
  }
  result
}

///|
pub fn TrendForecast::forecast_intervals(
  self : TrendForecast,
  horizon : Int,
  confidence : Double,
) -> Array[PredictionInterval] {
  if confidence <= 0.0 || confidence >= 1.0 {
    abort("TrendForecast::forecast_intervals: invalid confidence")
  }
  let z = normal_quantile((1.0 + confidence) / 2.0)
  let result : Array[PredictionInterval] = []
  for step in 1..<=horizon {
    let scale = (self.level_variance + step.to_double() * self.trend_variance).sqrt()
    let prediction = self.level + step.to_double() * self.trend
    result.push(
      PredictionInterval::new(
        prediction,
        prediction - z * scale,
        prediction + z * scale,
        confidence,
        IntervalMethod::Gaussian,
      ),
    )
  }
  result
}

///|
pub fn state_space_residuals(updates : Array[KalmanUpdate]) -> Array[Double] {
  updates.map(fn(update) { update.innovation })
}

///|
pub fn innovation_outlier_rate(
  updates : Array[KalmanUpdate],
  z_threshold : Double,
) -> Double {
  if updates.length() == 0 || z_threshold <= 0.0 {
    abort("innovation_outlier_rate: invalid inputs")
  }
  let outliers = updates
    .filter(fn(update) {
      update.innovation.abs() / update.innovation_variance.sqrt() > z_threshold
    })
    .length()
  outliers.to_double() / updates.length().to_double()
}

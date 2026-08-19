///|
/// Production-oriented time-series primitives for forecasting, monitoring, and
/// feature extraction. All transformations return owned arrays or immutable
/// records so callers can safely reuse the original stream.
pub enum Seasonality {
  None
  Additive(period~ : Int)
  Multiplicative(period~ : Int)
} derive(Debug, Eq, ToJson, FromJson)

///|
pub struct TimeSeries {
  timestamps : Array[Int]
  values : Array[Double]
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn TimeSeries::new(
  timestamps : Array[Int],
  values : Array[Double],
) -> TimeSeries {
  if timestamps.length() != values.length() {
    abort("TimeSeries: timestamps and values must have equal length")
  }
  { timestamps: timestamps.copy(), values: values.copy() }
}

///|
pub fn TimeSeries::from_values(values : Array[Double]) -> TimeSeries {
  let timestamps = []
  for index in 0..<values.length() {
    timestamps.push(index)
  }
  TimeSeries::new(timestamps, values)
}

///|
pub fn TimeSeries::len(self : TimeSeries) -> Int {
  self.values.length()
}

///|
pub fn TimeSeries::is_empty(self : TimeSeries) -> Bool {
  self.values.length() == 0
}

///|
pub fn TimeSeries::timestamps(self : TimeSeries) -> Array[Int] {
  self.timestamps.copy()
}

///|
pub fn TimeSeries::values(self : TimeSeries) -> Array[Double] {
  self.values.copy()
}

///|
pub fn TimeSeries::at(self : TimeSeries, index : Int) -> Double {
  if index < 0 || index >= self.len() {
    abort("TimeSeries::at: index out of range")
  }
  self.values[index]
}

///|
pub fn TimeSeries::timestamp_at(self : TimeSeries, index : Int) -> Int {
  if index < 0 || index >= self.len() {
    abort("TimeSeries::timestamp_at: index out of range")
  }
  self.timestamps[index]
}

///|
pub fn TimeSeries::append(
  self : TimeSeries,
  timestamp : Int,
  value : Double,
) -> TimeSeries {
  if self.len() > 0 && timestamp <= self.timestamps[self.len() - 1] {
    abort("TimeSeries::append: timestamps must increase")
  }
  let timestamps = self.timestamps.copy()
  timestamps.push(timestamp)
  let values = self.values.copy()
  values.push(value)
  { timestamps, values }
}

///|
pub fn TimeSeries::slice(
  self : TimeSeries,
  start : Int,
  finish : Int,
) -> TimeSeries {
  if start < 0 || finish < start || finish > self.len() {
    abort("TimeSeries::slice: invalid range")
  }
  let timestamps = []
  let values = []
  for index in start..<finish {
    timestamps.push(self.timestamps[index])
    values.push(self.values[index])
  }
  { timestamps, values }
}

///|
pub fn TimeSeries::map(
  self : TimeSeries,
  transform : (Double) -> Double,
) -> TimeSeries {
  { ..self, values: self.values.map(transform) }
}

///|
pub fn TimeSeries::map_indexed(
  self : TimeSeries,
  transform : (Int, Double) -> Double,
) -> TimeSeries {
  { ..self, values: self.values.mapi(transform) }
}

///|
pub fn TimeSeries::filter(
  self : TimeSeries,
  predicate : (Int, Double) -> Bool,
) -> TimeSeries {
  let timestamps = []
  let values = []
  for index, value in self.values {
    if predicate(self.timestamps[index], value) {
      timestamps.push(self.timestamps[index])
      values.push(value)
    }
  }
  { timestamps, values }
}

///|
pub fn TimeSeries::difference(self : TimeSeries, lag : Int) -> TimeSeries {
  if lag <= 0 || lag >= self.len() {
    abort("TimeSeries::difference: lag out of range")
  }
  let timestamps = []
  let values = []
  for index in lag..<self.len() {
    timestamps.push(self.timestamps[index])
    values.push(self.values[index] - self.values[index - lag])
  }
  { timestamps, values }
}

///|
pub fn TimeSeries::percentage_change(
  self : TimeSeries,
  lag : Int,
) -> TimeSeries {
  if lag <= 0 || lag >= self.len() {
    abort("TimeSeries::percentage_change: lag out of range")
  }
  let timestamps = []
  let values = []
  for index in lag..<self.len() {
    let previous = self.values[index - lag]
    if previous == 0.0 {
      values.push(0.0)
    } else {
      values.push((self.values[index] - previous) / previous)
    }
    timestamps.push(self.timestamps[index])
  }
  { timestamps, values }
}

///|
pub fn TimeSeries::lag(self : TimeSeries, offset : Int) -> TimeSeries {
  if offset < 0 || offset >= self.len() {
    abort("TimeSeries::lag: offset out of range")
  }
  let timestamps = []
  let values = []
  for index in offset..<self.len() {
    timestamps.push(self.timestamps[index])
    values.push(self.values[index - offset])
  }
  { timestamps, values }
}

///|
pub fn TimeSeries::rolling(
  self : TimeSeries,
  window : Int,
  statistic : (Array[Double]) -> Double,
) -> TimeSeries {
  if window <= 0 || window > self.len() {
    abort("TimeSeries::rolling: invalid window")
  }
  let timestamps = []
  let values = []
  for index in (window - 1)..<self.len() {
    let sample = []
    for offset in (index + 1 - window)..<=index {
      sample.push(self.values[offset])
    }
    timestamps.push(self.timestamps[index])
    values.push(statistic(sample))
  }
  { timestamps, values }
}

///|
pub fn TimeSeries::rolling_mean(self : TimeSeries, window : Int) -> TimeSeries {
  self.rolling(window, mean)
}

///|
pub fn TimeSeries::rolling_variance(
  self : TimeSeries,
  window : Int,
) -> TimeSeries {
  self.rolling(window, variance)
}

///|
pub fn TimeSeries::rolling_min(self : TimeSeries, window : Int) -> TimeSeries {
  self.rolling(window, fn(values) {
    values.fold(init=values[0], (current, value) => current.min(value))
  })
}

///|
pub fn TimeSeries::rolling_max(self : TimeSeries, window : Int) -> TimeSeries {
  self.rolling(window, fn(values) {
    values.fold(init=values[0], (current, value) => current.max(value))
  })
}

///|
pub fn TimeSeries::resample_mean(self : TimeSeries, bucket : Int) -> TimeSeries {
  if bucket <= 0 || self.len() == 0 {
    abort("TimeSeries::resample_mean: invalid bucket")
  }
  let timestamps = []
  let values = []
  let mut index = 0
  while index < self.len() {
    let finish = (index + bucket).min(self.len())
    let sample = []
    for cursor in index..<finish {
      sample.push(self.values[cursor])
    }
    timestamps.push(self.timestamps[index])
    values.push(mean(sample))
    index = finish
  }
  { timestamps, values }
}

///|
pub fn TimeSeries::resample_sum(self : TimeSeries, bucket : Int) -> TimeSeries {
  if bucket <= 0 || self.len() == 0 {
    abort("TimeSeries::resample_sum: invalid bucket")
  }
  let timestamps = []
  let values = []
  let mut index = 0
  while index < self.len() {
    let finish = (index + bucket).min(self.len())
    let sample = []
    for cursor in index..<finish {
      sample.push(self.values[cursor])
    }
    timestamps.push(self.timestamps[index])
    values.push(sum(sample))
    index = finish
  }
  { timestamps, values }
}

///|
pub fn TimeSeries::normalize(self : TimeSeries) -> TimeSeries {
  if self.len() == 0 {
    return self
  }
  let lower = self.values.fold(init=self.values[0], (current, value) => {
    current.min(value)
  })
  let upper = self.values.fold(init=self.values[0], (current, value) => {
    current.max(value)
  })
  let width = upper - lower
  self.map(fn(value) {
    if width == 0.0 {
      0.0
    } else {
      (value - lower) / width
    }
  })
}

///|
pub fn TimeSeries::standardize(self : TimeSeries) -> TimeSeries {
  let center = mean(self.values)
  let scale = variance(self.values).sqrt()
  self.map(fn(value) {
    if scale == 0.0 {
      0.0
    } else {
      (value - center) / scale
    }
  })
}

///|
pub fn TimeSeries::trend(self : TimeSeries) -> Double {
  if self.len() < 2 {
    return 0.0
  }
  let x = []
  for index in 0..<self.len() {
    x.push(index.to_double())
  }
  let centered_x = mean(x)
  let centered_y = mean(self.values)
  let mut numerator = 0.0
  let mut denominator = 0.0
  for index in 0..<self.len() {
    let dx = x[index] - centered_x
    numerator = numerator + dx * (self.values[index] - centered_y)
    denominator = denominator + dx * dx
  }
  if denominator == 0.0 {
    0.0
  } else {
    numerator / denominator
  }
}

///|
pub fn TimeSeries::seasonal_average(
  self : TimeSeries,
  period : Int,
) -> Array[Double] {
  if period <= 0 || self.len() < period {
    abort("TimeSeries::seasonal_average: invalid period")
  }
  let result = Array::make(period, 0.0)
  let counts = Array::make(period, 0)
  for index, value in self.values {
    let slot = index % period
    result[slot] = result[slot] + value
    counts[slot] = counts[slot] + 1
  }
  for slot in 0..<period {
    result[slot] = result[slot] / counts[slot].to_double()
  }
  result
}

///|
pub fn autocovariance(values : Array[Double], lag : Int) -> Double {
  if lag < 0 || lag >= values.length() || values.length() < 2 {
    abort("autocovariance: invalid lag")
  }
  let center = mean(values)
  let mut result = 0.0
  for index in lag..<values.length() {
    result = result + (values[index] - center) * (values[index - lag] - center)
  }
  result / (values.length() - lag).to_double()
}

///|
pub fn autocorrelation_series(
  values : Array[Double],
  maximum_lag : Int,
) -> Array[Double] {
  if maximum_lag < 0 || maximum_lag >= values.length() {
    abort("autocorrelation_series: invalid lag")
  }
  let result = []
  let base = autocovariance(values, 0)
  for lag in 0..<=maximum_lag {
    result.push(
      if base == 0.0 {
        0.0
      } else {
        autocovariance(values, lag) / base
      },
    )
  }
  result
}

///|
pub fn partial_autocorrelation(values : Array[Double], lag : Int) -> Double {
  if lag < 0 || lag >= values.length() {
    abort("partial_autocorrelation: invalid lag")
  }
  if lag == 0 {
    return 1.0
  }
  let correlations = autocorrelation_series(values, lag)
  let mut coefficient = correlations[lag]
  for index in 1..<lag {
    coefficient = coefficient -
      correlations[index] *
      correlations[lag - index] /
      (1.0 + correlations[index].abs())
  }
  coefficient.max(-1.0).min(1.0)
}

///|
pub struct TrendEstimate {
  slope : Double
  intercept : Double
  r_squared : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn TrendEstimate::new(
  slope : Double,
  intercept : Double,
  r_squared : Double,
) -> TrendEstimate {
  { slope, intercept, r_squared }
}

///|
pub fn TrendEstimate::slope(self : TrendEstimate) -> Double {
  self.slope
}

///|
pub fn TrendEstimate::intercept(self : TrendEstimate) -> Double {
  self.intercept
}

///|
pub fn TrendEstimate::r_squared(self : TrendEstimate) -> Double {
  self.r_squared
}

///|
pub fn TrendEstimate::predict(self : TrendEstimate, x : Double) -> Double {
  self.intercept + self.slope * x
}

///|
pub fn fit_trend(values : Array[Double]) -> TrendEstimate {
  if values.length() < 2 {
    abort("fit_trend: at least two values are required")
  }
  let x = []
  for index in 0..<values.length() {
    x.push(index.to_double())
  }
  let slope = covariance(x, values) / variance(x)
  let intercept = mean(values) - slope * mean(x)
  let predictions = x.map(fn(value) { intercept + slope * value })
  let total = values.fold(init=0.0, (result, value) => {
    result + (value - mean(values)) * (value - mean(values))
  })
  let residual = mean_absolute_error(predictions, values)
  TrendEstimate::new(
    slope,
    intercept,
    if total == 0.0 {
      0.0
    } else {
      1.0 - residual * residual * values.length().to_double() / total
    },
  )
}

///|
pub fn detrend(values : Array[Double]) -> Array[Double] {
  let trend = fit_trend(values)
  values.mapi(fn(index, value) { value - trend.predict(index.to_double()) })
}

///|
pub fn add_trend(
  values : Array[Double],
  trend : TrendEstimate,
) -> Array[Double] {
  values.mapi(fn(index, value) { value + trend.predict(index.to_double()) })
}

///|
pub fn seasonal_lag_features(
  values : Array[Double],
  period : Int,
  lags : Int,
) -> Array[Array[Double]] {
  if period <= 0 || lags <= 0 || values.length() <= period * lags {
    abort("seasonal_lag_features: insufficient history")
  }
  let result = []
  let start = period * lags
  for index in start..<values.length() {
    let row = [values[index]]
    for lag in 1..<=lags {
      row.push(values[index - period * lag])
    }
    result.push(row)
  }
  result
}

///|
pub fn rolling_quantile(
  values : Array[Double],
  window : Int,
  probability : Double,
) -> Array[Double] {
  if window <= 0 || window > values.length() {
    abort("rolling_quantile: invalid window")
  }
  let result = []
  for index in (window - 1)..<values.length() {
    let sample = []
    for cursor in (index + 1 - window)..<=index {
      sample.push(values[cursor])
    }
    result.push(quantile(sample, probability))
  }
  result
}

///|
pub fn rolling_median(values : Array[Double], window : Int) -> Array[Double] {
  rolling_quantile(values, window, 0.5)
}

///|
pub fn rolling_iqr(values : Array[Double], window : Int) -> Array[Double] {
  if window <= 0 || window > values.length() {
    abort("rolling_iqr: invalid window")
  }
  let result = []
  for index in (window - 1)..<values.length() {
    let sample = []
    for cursor in (index + 1 - window)..<=index {
      sample.push(values[cursor])
    }
    result.push(interquartile_range(sample))
  }
  result
}

///|
pub fn ewma_forecast(
  values : Array[Double],
  decay : Double,
  horizon : Int,
) -> Array[Double] {
  if values.length() == 0 || decay <= 0.0 || decay > 1.0 || horizon < 0 {
    abort("ewma_forecast: invalid inputs")
  }
  let level = exponential_moving_average(values, decay)[values.length() - 1]
  Array::make(horizon, level)
}

///|
pub fn holt_linear_forecast(
  values : Array[Double],
  level_decay : Double,
  trend_decay : Double,
  horizon : Int,
) -> Array[Double] {
  if values.length() < 2 ||
    level_decay <= 0.0 ||
    level_decay > 1.0 ||
    trend_decay <= 0.0 ||
    trend_decay > 1.0 ||
    horizon < 0 {
    abort("holt_linear_forecast: invalid inputs")
  }
  let mut level = values[0]
  let mut trend = values[1] - values[0]
  for index in 1..<values.length() {
    let previous = level
    level = level_decay * values[index] + (1.0 - level_decay) * (level + trend)
    trend = trend_decay * (level - previous) + (1.0 - trend_decay) * trend
  }
  let result = []
  for step in 1..<=horizon {
    result.push(level + step.to_double() * trend)
  }
  result
}

///|
pub fn damped_trend_forecast(
  values : Array[Double],
  level_decay : Double,
  trend_decay : Double,
  damping : Double,
  horizon : Int,
) -> Array[Double] {
  if damping <= 0.0 || damping > 1.0 {
    abort("damped_trend_forecast: damping must be in (0, 1]")
  }
  let base = holt_linear_forecast(values, level_decay, trend_decay, horizon)
  let result = []
  for index, value in base {
    result.push(value * @math.pow(damping, (index + 1).to_double()))
  }
  result
}

///|
pub fn forecast_bias(
  actual : Array[Double],
  predicted : Array[Double],
) -> Double {
  mean_absolute_error(actual, predicted)
}

///|
pub fn forecast_mase(
  actual : Array[Double],
  predicted : Array[Double],
  training : Array[Double],
  seasonal_period : Int,
) -> Double {
  if actual.length() != predicted.length() ||
    training.length() <= seasonal_period {
    abort("forecast_mase: invalid lengths")
  }
  let first = []
  let second = []
  for index in seasonal_period..<training.length() {
    first.push(training[index])
    second.push(training[index - seasonal_period])
  }
  let scale = mean_absolute_error(first, second)
  if scale == 0.0 {
    0.0
  } else {
    mean_absolute_error(actual, predicted) / scale
  }
}

///|
pub fn forecast_smape(
  actual : Array[Double],
  predicted : Array[Double],
) -> Double {
  if actual.length() != predicted.length() || actual.length() == 0 {
    abort("forecast_smape: invalid lengths")
  }
  let mut total = 0.0
  for index in 0..<actual.length() {
    let denominator = actual[index].abs() + predicted[index].abs()
    if denominator != 0.0 {
      total = total +
        2.0 * (actual[index] - predicted[index]).abs() / denominator
    }
  }
  total / actual.length().to_double()
}

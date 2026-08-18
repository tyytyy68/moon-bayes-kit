///|
pub struct ForecastPoint {
  step : Int
  value : Double
  lower : Double
  upper : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn ForecastPoint::step(self : ForecastPoint) -> Int {
  self.step
}

///|
pub fn ForecastPoint::value(self : ForecastPoint) -> Double {
  self.value
}

///|
pub fn ForecastPoint::interval(self : ForecastPoint) -> (Double, Double) {
  (self.lower, self.upper)
}

///|
pub fn naive_forecast(
  values : Array[Double],
  horizon : Int,
) -> Array[ForecastPoint] {
  if values.length() == 0 || horizon < 0 {
    abort("naive_forecast: invalid inputs")
  }
  let last = values[values.length() - 1]
  let deviation = OnlineStats::new().push_all(values).standard_deviation()
  let result = []
  for step in 1..<=horizon {
    let margin = 1.96 * deviation
    result.push({
      step,
      value: last,
      lower: last - margin,
      upper: last + margin,
    })
  }
  result
}

///|
pub fn drift_forecast(
  values : Array[Double],
  horizon : Int,
) -> Array[ForecastPoint] {
  if values.length() < 2 || horizon < 0 {
    abort("drift_forecast: at least two values are required")
  }
  let n = values.length()
  let mean_x = (n - 1).to_double() / 2.0
  let mean_y = mean(values)
  let mut numerator = 0.0
  let mut denominator = 0.0
  for index in 0..<n {
    let centered = index.to_double() - mean_x
    numerator = numerator + centered * (values[index] - mean_y)
    denominator = denominator + centered * centered
  }
  let slope = numerator / denominator
  let intercept = mean_y - slope * mean_x
  let error = root_mean_squared_error(
    values,
    values.mapi(fn(index, _) { intercept + slope * index.to_double() }),
  )
  let result = []
  for step in 1..<=horizon {
    let x = (n - 1 + step).to_double()
    let estimate = intercept + slope * x
    result.push({
      step,
      value: estimate,
      lower: estimate - 1.96 * error,
      upper: estimate + 1.96 * error,
    })
  }
  result
}

///|
pub fn forecast_values(points : Array[ForecastPoint]) -> Array[Double] {
  points.map(fn(point) { point.value() })
}

///|
pub fn seasonal_naive(
  values : Array[Double],
  season : Int,
  horizon : Int,
) -> Array[ForecastPoint] {
  if season <= 0 || values.length() < season || horizon < 0 {
    abort("seasonal_naive: invalid season or horizon")
  }
  let error = OnlineStats::new().push_all(values).standard_deviation()
  let result = []
  for step in 1..<=horizon {
    let value = values[values.length() - season + (step - 1) % season]
    result.push({
      step,
      value,
      lower: value - 1.96 * error,
      upper: value + 1.96 * error,
    })
  }
  result
}

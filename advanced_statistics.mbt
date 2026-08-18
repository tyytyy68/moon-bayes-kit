///|
/// Robust and exploratory statistics for production data streams.
pub fn median(values : Array[Double]) -> Double {
  quantile(values, 0.5)
}

///|
pub fn interquartile_range(values : Array[Double]) -> Double {
  quantile(values, 0.75) - quantile(values, 0.25)
}

///|
pub fn median_absolute_deviation(values : Array[Double]) -> Double {
  let center = median(values)
  median(values.map(fn(value) { (value - center).abs() }))
}

///|
pub fn correlation(left : Array[Double], right : Array[Double]) -> Double {
  if left.length() != right.length() || left.length() < 2 {
    abort("correlation: paired observations are required")
  }
  let left_mean = mean(left)
  let right_mean = mean(right)
  let mut numerator = 0.0
  let mut left_sum = 0.0
  let mut right_sum = 0.0
  for index in 0..<left.length() {
    let left_error = left[index] - left_mean
    let right_error = right[index] - right_mean
    numerator = numerator + left_error * right_error
    left_sum = left_sum + left_error * left_error
    right_sum = right_sum + right_error * right_error
  }
  if left_sum == 0.0 || right_sum == 0.0 {
    0.0
  } else {
    numerator / (left_sum * right_sum).sqrt()
  }
}

///|
pub fn skewness(values : Array[Double]) -> Double {
  if values.length() < 3 {
    abort("skewness: at least three observations are required")
  }
  let summary = OnlineStats::new().push_all(values)
  let deviation = summary.standard_deviation()
  if deviation == 0.0 {
    0.0
  } else {
    let center = summary.mean()
    let third = values.fold(init=0.0, (total, value) => {
      total +
      (value - center) /
      deviation *
      ((value - center) / deviation) *
      ((value - center) / deviation)
    })
    third / values.length().to_double()
  }
}

///|
pub fn percentile_rank(values : Array[Double], value : Double) -> Double {
  if values.length() == 0 {
    abort("percentile_rank: values must not be empty")
  }
  let below = values.fold(init=0, (count, item) => {
    if item <= value {
      count + 1
    } else {
      count
    }
  })
  below.to_double() / values.length().to_double()
}

///|
pub fn histogram(
  values : Array[Double],
  lower : Double,
  upper : Double,
  bins : Int,
) -> Array[Int] {
  if lower >= upper || bins <= 0 {
    abort("histogram: invalid range or bins")
  }
  let result = Array::make(bins, 0)
  let width = (upper - lower) / bins.to_double()
  for value in values {
    if value >= lower && value <= upper {
      let index = if value == upper {
        bins - 1
      } else {
        ((value - lower) / width).floor().to_int()
      }
      result[index] = result[index] + 1
    }
  }
  result
}

///|
pub fn moving_average(values : Array[Double], window : Int) -> Array[Double] {
  if window <= 0 {
    abort("moving_average: window must be positive")
  }
  let result = Array::make(values.length(), 0.0)
  let mut rolling = RollingWindow::new(window)
  for index, value in values {
    rolling = rolling.push(value)
    result[index] = rolling.mean()
  }
  result
}

///|
pub fn autocorrelation(values : Array[Double], lag : Int) -> Double {
  if lag < 0 || lag >= values.length() || values.length() < 2 {
    abort("autocorrelation: invalid lag")
  }
  if lag == 0 {
    return 1.0
  }
  let center = mean(values)
  let mut numerator = 0.0
  let mut denominator = 0.0
  for index in 0..<values.length() {
    let error = values[index] - center
    denominator = denominator + error * error
  }
  for index in lag..<values.length() {
    numerator = numerator +
      (values[index] - center) * (values[index - lag] - center)
  }
  if denominator == 0.0 {
    0.0
  } else {
    numerator / denominator
  }
}

///|
pub fn cumulative_sum(values : Array[Double]) -> Array[Double] {
  let result = Array::make(values.length(), 0.0)
  let mut total = 0.0
  for index, value in values {
    total = total + value
    result[index] = total
  }
  result
}

///|
pub fn standardized(values : Array[Double]) -> Array[Double] {
  let summary = OnlineStats::new().push_all(values)
  let deviation = summary.standard_deviation()
  if deviation == 0.0 {
    values.map(fn(_) { 0.0 })
  } else {
    values.map(fn(value) { (value - summary.mean()) / deviation })
  }
}

///|
pub fn empirical_entropy(values : Array[Int]) -> Double {
  if values.length() == 0 {
    return 0.0
  }
  let unique = []
  for value in values {
    if !unique.contains(value) {
      unique.push(value)
    }
  }
  let mut result = 0.0
  for category in unique {
    let count = values.fold(init=0, (total, value) => {
      if value == category {
        total + 1
      } else {
        total
      }
    })
    let probability = count.to_double() / values.length().to_double()
    result = result + probability * (1.0 - probability)
  }
  result
}

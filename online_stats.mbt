///|
/// A numerically simple, allocation-conscious summary for streaming values.
pub struct OnlineStats {
  count : Int
  mean : Double
  m2 : Double
  minimum : Double
  maximum : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
/// Creates an empty summary. The first observation initializes the extrema.
pub fn OnlineStats::new() -> OnlineStats {
  { count: 0, mean: 0.0, m2: 0.0, minimum: 0.0, maximum: 0.0 }
}

///|
/// Adds one value using Welford's online update.
pub fn OnlineStats::push(self : OnlineStats, value : Double) -> OnlineStats {
  let next_count = self.count + 1
  if self.count == 0 {
    { count: 1, mean: value, m2: 0.0, minimum: value, maximum: value }
  } else {
    let delta = value - self.mean
    let next_mean = self.mean + delta / next_count.to_double()
    let delta2 = value - next_mean
    {
      count: next_count,
      mean: next_mean,
      m2: self.m2 + delta * delta2,
      minimum: self.minimum.min(value),
      maximum: self.maximum.max(value),
    }
  }
}

///|
/// Adds all values in order.
pub fn OnlineStats::push_all(
  self : OnlineStats,
  values : Array[Double],
) -> OnlineStats {
  values.fold(init=self, (summary, value) => summary.push(value))
}

///|
pub fn OnlineStats::count(self : OnlineStats) -> Int {
  self.count
}

///|
pub fn OnlineStats::mean(self : OnlineStats) -> Double {
  if self.count == 0 {
    0.0
  } else {
    self.mean
  }
}

///|
pub fn OnlineStats::sum(self : OnlineStats) -> Double {
  self.mean * self.count.to_double()
}

///|
pub fn OnlineStats::variance(self : OnlineStats) -> Double {
  if self.count < 2 {
    0.0
  } else {
    self.m2 / (self.count - 1).to_double()
  }
}

///|
pub fn OnlineStats::population_variance(self : OnlineStats) -> Double {
  if self.count == 0 {
    0.0
  } else {
    self.m2 / self.count.to_double()
  }
}

///|
pub fn OnlineStats::standard_deviation(self : OnlineStats) -> Double {
  self.variance().sqrt()
}

///|
pub fn OnlineStats::min(self : OnlineStats) -> Double {
  self.minimum
}

///|
pub fn OnlineStats::max(self : OnlineStats) -> Double {
  self.maximum
}

///|
/// Merges two summaries without replaying their observations.
pub fn OnlineStats::merge(
  self : OnlineStats,
  other : OnlineStats,
) -> OnlineStats {
  if other.count == 0 {
    return self
  }
  if self.count == 0 {
    return other
  }
  let total = self.count + other.count
  let delta = other.mean - self.mean
  let weight = other.count.to_double() / total.to_double()
  {
    count: total,
    mean: self.mean + delta * weight,
    m2: self.m2 +
    other.m2 +
    delta *
    delta *
    self.count.to_double() *
    other.count.to_double() /
    total.to_double(),
    minimum: self.minimum.min(other.minimum),
    maximum: self.maximum.max(other.maximum),
  }
}

///|
/// Returns the arithmetic mean, or zero for an empty array.
pub fn mean(values : Array[Double]) -> Double {
  OnlineStats::new().push_all(values).mean()
}

///|
pub fn variance(values : Array[Double]) -> Double {
  OnlineStats::new().push_all(values).variance()
}

///|
pub fn dot(left : Array[Double], right : Array[Double]) -> Double {
  if left.length() != right.length() {
    abort("dot: vector lengths must match")
  }
  let mut result = 0.0
  for i in 0..<left.length() {
    result = result + left[i] * right[i]
  }
  result
}

///|
pub fn sum(values : Array[Double]) -> Double {
  values.fold(init=0.0, (total, value) => total + value)
}

///|
pub fn weighted_mean(values : Array[Double], weights : Array[Double]) -> Double {
  if values.length() != weights.length() {
    abort("weighted_mean: vector lengths must match")
  }
  let mut numerator = 0.0
  let mut denominator = 0.0
  for i in 0..<values.length() {
    if weights[i] < 0.0 {
      abort("weighted_mean: weights must be non-negative")
    }
    numerator = numerator + values[i] * weights[i]
    denominator = denominator + weights[i]
  }
  if denominator == 0.0 {
    abort("weighted_mean: total weight must be positive")
  }
  numerator / denominator
}

///|
pub fn covariance(left : Array[Double], right : Array[Double]) -> Double {
  if left.length() != right.length() || left.length() < 2 {
    abort("covariance: at least two paired observations are required")
  }
  let left_mean = mean(left)
  let right_mean = mean(right)
  let mut total = 0.0
  for i in 0..<left.length() {
    total = total + (left[i] - left_mean) * (right[i] - right_mean)
  }
  total / (left.length() - 1).to_double()
}

///|
pub fn normalize_probabilities(values : Array[Double]) -> Array[Double] {
  if values.length() == 0 {
    abort("normalize_probabilities: values must not be empty")
  }
  for value in values {
    if value < 0.0 {
      abort("probabilities must be non-negative")
    }
  }
  let total = sum(values)
  if total <= 0.0 {
    abort("normalize_probabilities: total must be positive")
  }
  values.map(fn(value) { value / total })
}

///|
/// Deterministic linear interpolation quantile. `q` is in the closed interval [0, 1].
pub fn quantile(values : Array[Double], q : Double) -> Double {
  if values.length() == 0 {
    abort("quantile: values must not be empty")
  }
  if q < 0.0 || q > 1.0 {
    abort("quantile: q must be between zero and one")
  }
  let sorted = values.copy()
  sorted.sort()
  if sorted.length() == 1 {
    return sorted[0]
  }
  let position = q * (sorted.length() - 1).to_double()
  let lower = position.floor().to_int()
  let upper = position.ceil().to_int()
  if lower == upper {
    sorted[lower]
  } else {
    sorted[lower] +
    (sorted[upper] - sorted[lower]) * (position - lower.to_double())
  }
}

///|
/// Returns a copy with the supplied value clamped to an interval.
pub fn clamp(value : Double, lower : Double, upper : Double) -> Double {
  if lower > upper {
    abort("clamp: lower must not exceed upper")
  }
  value.max(lower).min(upper)
}

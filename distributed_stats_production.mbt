///|
/// Mergeable summaries for distributed telemetry and federated analytics.
pub struct DistributedSummary {
  count : Int
  mean : Double
  m2 : Double
  minimum : Double
  maximum : Double
  sum : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn DistributedSummary::new() -> DistributedSummary {
  { count: 0, mean: 0.0, m2: 0.0, minimum: 0.0, maximum: 0.0, sum: 0.0 }
}

///|
pub fn DistributedSummary::push(
  self : DistributedSummary,
  value : Double,
) -> DistributedSummary {
  if self.count == 0 {
    {
      count: 1,
      mean: value,
      m2: 0.0,
      minimum: value,
      maximum: value,
      sum: value,
    }
  } else {
    let count = self.count + 1
    let delta = value - self.mean
    let mean = self.mean + delta / count.to_double()
    {
      count,
      mean,
      m2: self.m2 + delta * (value - mean),
      minimum: self.minimum.min(value),
      maximum: self.maximum.max(value),
      sum: self.sum + value,
    }
  }
}

///|
pub fn DistributedSummary::push_all(
  self : DistributedSummary,
  values : Array[Double],
) -> DistributedSummary {
  values.fold(init=self, (summary, value) => summary.push(value))
}

///|
pub fn DistributedSummary::variance(self : DistributedSummary) -> Double {
  if self.count < 2 {
    0.0
  } else {
    self.m2 / (self.count - 1).to_double()
  }
}

///|
pub fn DistributedSummary::standard_deviation(
  self : DistributedSummary,
) -> Double {
  self.variance().sqrt()
}

///|
pub fn DistributedSummary::merge(
  self : DistributedSummary,
  other : DistributedSummary,
) -> DistributedSummary {
  if other.count == 0 {
    return self
  }
  if self.count == 0 {
    return other
  }
  let total = self.count + other.count
  let delta = other.mean - self.mean
  {
    count: total,
    mean: (self.sum + other.sum) / total.to_double(),
    m2: self.m2 +
    other.m2 +
    delta *
    delta *
    self.count.to_double() *
    other.count.to_double() /
    total.to_double(),
    minimum: self.minimum.min(other.minimum),
    maximum: self.maximum.max(other.maximum),
    sum: self.sum + other.sum,
  }
}

///|
pub fn merge_summaries(
  summaries : Array[DistributedSummary],
) -> DistributedSummary {
  summaries.fold(init=DistributedSummary::new(), (result, summary) => {
    result.merge(summary)
  })
}

///|
pub struct CovarianceSummary {
  count : Int
  mean_x : Double
  mean_y : Double
  cross_m2 : Double
  variance_x : Double
  variance_y : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn CovarianceSummary::new() -> CovarianceSummary {
  {
    count: 0,
    mean_x: 0.0,
    mean_y: 0.0,
    cross_m2: 0.0,
    variance_x: 0.0,
    variance_y: 0.0,
  }
}

///|
pub fn CovarianceSummary::push(
  self : CovarianceSummary,
  x : Double,
  y : Double,
) -> CovarianceSummary {
  let count = self.count + 1
  let delta_x = x - self.mean_x
  let delta_y = y - self.mean_y
  let mean_x = self.mean_x + delta_x / count.to_double()
  let mean_y = self.mean_y + delta_y / count.to_double()
  {
    count,
    mean_x,
    mean_y,
    cross_m2: self.cross_m2 + delta_x * (y - mean_y),
    variance_x: self.variance_x + delta_x * (x - mean_x),
    variance_y: self.variance_y + delta_y * (y - mean_y),
  }
}

///|
pub fn CovarianceSummary::merge(
  self : CovarianceSummary,
  other : CovarianceSummary,
) -> CovarianceSummary {
  if self.count == 0 {
    return other
  }
  if other.count == 0 {
    return self
  }
  let total = self.count + other.count
  let delta_x = other.mean_x - self.mean_x
  let delta_y = other.mean_y - self.mean_y
  {
    count: total,
    mean_x: (
      self.mean_x * self.count.to_double() +
      other.mean_x * other.count.to_double()
    ) /
    total.to_double(),
    mean_y: (
      self.mean_y * self.count.to_double() +
      other.mean_y * other.count.to_double()
    ) /
    total.to_double(),
    cross_m2: self.cross_m2 +
    other.cross_m2 +
    delta_x *
    delta_y *
    self.count.to_double() *
    other.count.to_double() /
    total.to_double(),
    variance_x: self.variance_x +
    other.variance_x +
    delta_x *
    delta_x *
    self.count.to_double() *
    other.count.to_double() /
    total.to_double(),
    variance_y: self.variance_y +
    other.variance_y +
    delta_y *
    delta_y *
    self.count.to_double() *
    other.count.to_double() /
    total.to_double(),
  }
}

///|
pub fn CovarianceSummary::covariance(self : CovarianceSummary) -> Double {
  if self.count < 2 {
    0.0
  } else {
    self.cross_m2 / (self.count - 1).to_double()
  }
}

///|
pub fn CovarianceSummary::correlation(self : CovarianceSummary) -> Double {
  let denominator = (self.variance_x * self.variance_y).sqrt()
  if denominator == 0.0 {
    0.0
  } else {
    self.cross_m2 / denominator
  }
}

///|
pub struct WeightedSummary {
  weight : Double
  weighted_mean : Double
  weighted_m2 : Double
  observations : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn WeightedSummary::new() -> WeightedSummary {
  { weight: 0.0, weighted_mean: 0.0, weighted_m2: 0.0, observations: 0 }
}

///|
pub fn WeightedSummary::push(
  self : WeightedSummary,
  value : Double,
  weight : Double,
) -> WeightedSummary {
  if weight < 0.0 {
    abort("WeightedSummary: weight must be non-negative")
  }
  let total = self.weight + weight
  if total == 0.0 {
    self
  } else {
    let delta = value - self.weighted_mean
    let mean = self.weighted_mean + weight * delta / total
    {
      weight: total,
      weighted_mean: mean,
      weighted_m2: self.weighted_m2 + weight * delta * (value - mean),
      observations: self.observations + 1,
    }
  }
}

///|
pub fn WeightedSummary::variance(self : WeightedSummary) -> Double {
  if self.weight == 0.0 {
    0.0
  } else {
    self.weighted_m2 / self.weight
  }
}

///|
pub fn WeightedSummary::merge(
  self : WeightedSummary,
  other : WeightedSummary,
) -> WeightedSummary {
  if self.weight == 0.0 {
    other
  } else if other.weight == 0.0 {
    self
  } else {
    let total = self.weight + other.weight
    let delta = other.weighted_mean - self.weighted_mean
    {
      weight: total,
      weighted_mean: (
        self.weight * self.weighted_mean + other.weight * other.weighted_mean
      ) /
      total,
      weighted_m2: self.weighted_m2 +
      other.weighted_m2 +
      delta * delta * self.weight * other.weight / total,
      observations: self.observations + other.observations,
    }
  }
}

///|
pub struct QuantileSketch {
  capacity : Int
  samples : Array[Double]
  seen : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn QuantileSketch::new(capacity : Int) -> QuantileSketch {
  if capacity <= 1 {
    abort("QuantileSketch: capacity must exceed one")
  }
  { capacity, samples: [], seen: 0 }
}

///|
pub fn QuantileSketch::push(
  self : QuantileSketch,
  value : Double,
) -> QuantileSketch {
  let samples = self.samples.copy()
  let seen = self.seen + 1
  if samples.length() < self.capacity {
    samples.push(value)
  } else {
    let slot = seen % self.capacity
    samples[slot] = value
  }
  { ..self, samples, seen }
}

///|
pub fn QuantileSketch::push_all(
  self : QuantileSketch,
  values : Array[Double],
) -> QuantileSketch {
  values.fold(init=self, (sketch, value) => sketch.push(value))
}

///|
pub fn QuantileSketch::quantile(
  self : QuantileSketch,
  probability : Double,
) -> Double {
  if self.samples.length() == 0 || probability < 0.0 || probability > 1.0 {
    abort("QuantileSketch::quantile: invalid inputs")
  }
  empirical_quantile(self.samples, probability)
}

///|
pub fn QuantileSketch::merge(
  self : QuantileSketch,
  other : QuantileSketch,
) -> QuantileSketch {
  let result = QuantileSketch::new(self.capacity.max(other.capacity))
  let merged = result.push_all(self.samples).push_all(other.samples)
  { ..merged, seen: self.seen + other.seen }
}

///|
pub fn QuantileSketch::rank(self : QuantileSketch, value : Double) -> Double {
  if self.samples.length() == 0 {
    return 0.0
  }
  self.samples.filter(fn(item) { item <= value }).length().to_double() /
  self.samples.length().to_double()
}

///|
pub struct DistinctSketch {
  capacity : Int
  values : Array[String]
  seen : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn DistinctSketch::new(capacity : Int) -> DistinctSketch {
  if capacity <= 0 {
    abort("DistinctSketch: capacity must be positive")
  }
  { capacity, values: [], seen: 0 }
}

///|
pub fn DistinctSketch::push(
  self : DistinctSketch,
  value : String,
) -> DistinctSketch {
  let seen = self.seen + 1
  let values = self.values.copy()
  if !values.contains(value) && values.length() < self.capacity {
    values.push(value)
  }
  { ..self, values, seen }
}

///|
pub fn DistinctSketch::push_all(
  self : DistinctSketch,
  values : Array[String],
) -> DistinctSketch {
  values.fold(init=self, (sketch, value) => sketch.push(value))
}

///|
pub fn DistinctSketch::estimate(self : DistinctSketch) -> Double {
  if self.values.length() < self.capacity {
    self.values.length().to_double()
  } else {
    self.capacity.to_double() *
    (self.seen.to_double() / self.capacity.to_double()).sqrt()
  }
}

///|
pub fn DistinctSketch::merge(
  self : DistinctSketch,
  other : DistinctSketch,
) -> DistinctSketch {
  other.values.fold(init=self, (sketch, value) => sketch.push(value))
}

///|
pub struct RateSummary {
  successes : Int
  failures : Int
  exposure : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn RateSummary::new() -> RateSummary {
  { successes: 0, failures: 0, exposure: 0.0 }
}

///|
pub fn RateSummary::record(
  self : RateSummary,
  success : Bool,
  exposure : Double,
) -> RateSummary {
  if exposure < 0.0 {
    abort("RateSummary: exposure must be non-negative")
  }
  let success_count = if success { 1 } else { 0 }
  let failure_count = if success { 0 } else { 1 }
  {
    successes: self.successes + success_count,
    failures: self.failures + failure_count,
    exposure: self.exposure + exposure,
  }
}

///|
pub fn RateSummary::rate(self : RateSummary) -> Double {
  let total = self.successes + self.failures
  if total == 0 {
    0.0
  } else {
    self.successes.to_double() / total.to_double()
  }
}

///|
pub fn RateSummary::exposure_rate(self : RateSummary) -> Double {
  if self.exposure == 0.0 {
    0.0
  } else {
    self.successes.to_double() / self.exposure
  }
}

///|
pub fn RateSummary::merge(
  self : RateSummary,
  other : RateSummary,
) -> RateSummary {
  {
    successes: self.successes + other.successes,
    failures: self.failures + other.failures,
    exposure: self.exposure + other.exposure,
  }
}

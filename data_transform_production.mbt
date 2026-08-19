///|
/// Production-safe numeric transforms and reversible preprocessing metadata.
pub enum TransformKind {
  Identity
  Standardize
  MinMax
  Robust
  Log1p
  Clip
  Quantile
  Rank
} derive(Debug, Eq, ToJson, FromJson)

///|
pub struct TransformParameters {
  kind : TransformKind
  center : Double
  scale : Double
  lower : Double
  upper : Double
  fitted_count : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn TransformParameters::identity() -> TransformParameters {
  {
    kind: TransformKind::Identity,
    center: 0.0,
    scale: 1.0,
    lower: 0.0,
    upper: 0.0,
    fitted_count: 0,
  }
}

///|
pub fn TransformParameters::fit_standard(
  values : Array[Double],
) -> TransformParameters {
  if values.length() == 0 {
    abort("fit_standard: empty values")
  }
  {
    kind: TransformKind::Standardize,
    center: mean(values),
    scale: variance(values).sqrt().max(0.000000000001),
    lower: 0.0,
    upper: 0.0,
    fitted_count: values.length(),
  }
}

///|
pub fn TransformParameters::fit_minmax(
  values : Array[Double],
  lower : Double,
  upper : Double,
) -> TransformParameters {
  if values.length() == 0 || lower >= upper {
    abort("fit_minmax: invalid inputs")
  }
  {
    kind: TransformKind::MinMax,
    center: values.fold(init=values[0], (current, value) => current.min(value)),
    scale: values.fold(init=values[0], (current, value) => current.max(value)) -
    values.fold(init=values[0], (current, value) => current.min(value)),
    lower,
    upper,
    fitted_count: values.length(),
  }
}

///|
pub fn TransformParameters::fit_robust(
  values : Array[Double],
) -> TransformParameters {
  if values.length() == 0 {
    abort("fit_robust: empty values")
  }
  {
    kind: TransformKind::Robust,
    center: empirical_quantile(values, 0.5),
    scale: (empirical_quantile(values, 0.75) - empirical_quantile(values, 0.25)).max(
      0.000000000001,
    ),
    lower: 0.0,
    upper: 0.0,
    fitted_count: values.length(),
  }
}

///|
pub fn TransformParameters::fit_clip(
  values : Array[Double],
  lower : Double,
  upper : Double,
) -> TransformParameters {
  if values.length() == 0 || lower > upper {
    abort("fit_clip: invalid inputs")
  }
  {
    kind: TransformKind::Clip,
    center: 0.0,
    scale: 1.0,
    lower,
    upper,
    fitted_count: values.length(),
  }
}

///|
pub fn TransformParameters::apply(
  self : TransformParameters,
  value : Double,
) -> Double {
  match self.kind {
    TransformKind::Identity => value
    TransformKind::Standardize => (value - self.center) / self.scale
    TransformKind::MinMax =>
      self.lower +
      (value - self.center) / self.scale * (self.upper - self.lower)
    TransformKind::Robust => (value - self.center) / self.scale
    TransformKind::Log1p =>
      if value <= -1.0 {
        -1.0
      } else {
        @math.pow(1.0 + value, 0.5) * 2.0 - 2.0
      }
    TransformKind::Clip => value.max(self.lower).min(self.upper)
    TransformKind::Quantile | TransformKind::Rank => value
  }
}

///|
pub fn TransformParameters::inverse(
  self : TransformParameters,
  value : Double,
) -> Double {
  match self.kind {
    TransformKind::Identity => value
    TransformKind::Standardize => value * self.scale + self.center
    TransformKind::MinMax =>
      self.center +
      (value - self.lower) / (self.upper - self.lower) * self.scale
    TransformKind::Robust => value * self.scale + self.center
    TransformKind::Log1p => value
    TransformKind::Clip => value
    TransformKind::Quantile | TransformKind::Rank => value
  }
}

///|
pub fn transform_values(
  parameters : TransformParameters,
  values : Array[Double],
) -> Array[Double] {
  values.map(fn(value) { parameters.apply(value) })
}

///|
pub fn inverse_values(
  parameters : TransformParameters,
  values : Array[Double],
) -> Array[Double] {
  values.map(fn(value) { parameters.inverse(value) })
}

///|
pub struct TransformPipeline {
  parameters : Array[TransformParameters]
  names : Array[String]
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn TransformPipeline::new() -> TransformPipeline {
  { parameters: [], names: [] }
}

///|
pub fn TransformPipeline::add(
  self : TransformPipeline,
  name : String,
  parameters : TransformParameters,
) -> TransformPipeline {
  if self.names.contains(name) {
    abort("TransformPipeline: duplicate step")
  }
  let names = self.names.copy()
  names.push(name)
  let values = self.parameters.copy()
  values.push(parameters)
  { parameters: values, names }
}

///|
pub fn TransformPipeline::apply(
  self : TransformPipeline,
  values : Array[Double],
) -> Array[Double] {
  let mut result = values
  for parameters in self.parameters.iter() {
    result = transform_values(parameters, result)
  }
  result
}

///|
pub fn TransformPipeline::inverse(
  self : TransformPipeline,
  values : Array[Double],
) -> Array[Double] {
  let mut result = values
  for index in 0..<self.parameters.length() {
    result = inverse_values(
      self.parameters[self.parameters.length() - index - 1],
      result,
    )
  }
  result
}

///|
pub struct MissingValuePolicy {
  fill : Double
  lower : Double
  upper : Double
  dropped : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn transform_impute_mean(
  values : Array[Double],
) -> (Array[Double], MissingValuePolicy) {
  if values.length() == 0 {
    abort("transform_impute_mean: empty values")
  }
  let observed = values.filter(fn(value) { value == value })
  let fill = if observed.length() == 0 { 0.0 } else { mean(observed) }
  let imputed = values.map(fn(value) {
    if value != value {
      fill
    } else {
      value
    }
  })
  (
    imputed,
    {
      fill,
      lower: fill,
      upper: fill,
      dropped: values.length() - observed.length(),
    },
  )
}

///|
pub fn transform_impute_median(
  values : Array[Double],
) -> (Array[Double], MissingValuePolicy) {
  if values.length() == 0 {
    abort("transform_impute_median: empty values")
  }
  let observed = values.filter(fn(value) { value == value })
  let fill = if observed.length() == 0 {
    0.0
  } else {
    empirical_quantile(observed, 0.5)
  }
  let imputed = values.map(fn(value) {
    if value != value {
      fill
    } else {
      value
    }
  })
  (
    imputed,
    {
      fill,
      lower: fill,
      upper: fill,
      dropped: values.length() - observed.length(),
    },
  )
}

///|
pub fn transform_winsorize(
  values : Array[Double],
  lower_quantile : Double,
  upper_quantile : Double,
) -> Array[Double] {
  if values.length() == 0 ||
    lower_quantile < 0.0 ||
    upper_quantile > 1.0 ||
    lower_quantile > upper_quantile {
    abort("transform_winsorize: invalid inputs")
  }
  let lower = empirical_quantile(values, lower_quantile)
  let upper = empirical_quantile(values, upper_quantile)
  values.map(fn(value) { value.max(lower).min(upper) })
}

///|
pub fn normalize_l1(values : Array[Double]) -> Array[Double] {
  let total = values.fold(init=0.0, (sum_value, value) => {
    sum_value + value.abs()
  })
  if total == 0.0 {
    values.copy()
  } else {
    values.map(fn(value) { value / total })
  }
}

///|
pub fn normalize_l2(values : Array[Double]) -> Array[Double] {
  let total = values
    .fold(init=0.0, (sum_value, value) => sum_value + value * value)
    .sqrt()
  if total == 0.0 {
    values.copy()
  } else {
    values.map(fn(value) { value / total })
  }
}

///|
pub fn safe_divide(
  numerator : Array[Double],
  denominator : Array[Double],
  default_value : Double,
) -> Array[Double] {
  if numerator.length() != denominator.length() {
    abort("safe_divide: lengths must match")
  }
  let result : Array[Double] = []
  for index in 0..<numerator.length() {
    if denominator[index] == 0.0 {
      result.push(default_value)
    } else {
      result.push(numerator[index] / denominator[index])
    }
  }
  result
}

///|
pub fn rolling_center(values : Array[Double], window : Int) -> Array[Double] {
  if window <= 0 {
    abort("rolling_center: window must be positive")
  }
  let result : Array[Double] = []
  for index in 0..<values.length() {
    let start = (index + 1 - window).max(0)
    let sample : Array[Double] = []
    for cursor in start..<=index {
      sample.push(values[cursor])
    }
    result.push(mean(sample))
  }
  result
}

///|
pub fn rolling_scale(values : Array[Double], window : Int) -> Array[Double] {
  if window <= 0 {
    abort("rolling_scale: window must be positive")
  }
  let result : Array[Double] = []
  for index in 0..<values.length() {
    let start = (index + 1 - window).max(0)
    let sample : Array[Double] = []
    for cursor in start..<=index {
      sample.push(values[cursor])
    }
    result.push(variance(sample).sqrt())
  }
  result
}

///|
pub struct EncodingMap {
  categories : Array[String]
  unknown_code : Int
  ordered : Bool
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn EncodingMap::fit(values : Array[String], ordered : Bool) -> EncodingMap {
  let categories : Array[String] = []
  for value in values.iter() {
    if !categories.contains(value) {
      categories.push(value)
    }
  }
  { categories, unknown_code: -1, ordered }
}

///|
pub fn EncodingMap::encode(self : EncodingMap, value : String) -> Int {
  for index in 0..<self.categories.length() {
    if self.categories[index] == value {
      return index
    }
  }
  self.unknown_code
}

///|
pub fn EncodingMap::decode(self : EncodingMap, code : Int) -> String {
  if code < 0 || code >= self.categories.length() {
    "<unknown>"
  } else {
    self.categories[code]
  }
}

///|
pub fn EncodingMap::encode_all(
  self : EncodingMap,
  values : Array[String],
) -> Array[Int] {
  values.map(fn(value) { self.encode(value) })
}

///|
pub fn transform_one_hot(
  values : Array[Int],
  classes : Int,
) -> Array[Array[Double]] {
  if classes <= 0 {
    abort("transform_one_hot: classes must be positive")
  }
  values.map(fn(value) {
    let row : Array[Double] = []
    for index in 0..<classes {
      row.push(if index == value { 1.0 } else { 0.0 })
    }
    row
  })
}

///|
pub struct TransformAudit {
  rows : Int
  missing_before : Int
  missing_after : Int
  clipped : Int
  mean_before : Double
  mean_after : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn transform_audit(
  before : Array[Double],
  after : Array[Double],
  lower : Double,
  upper : Double,
) -> TransformAudit {
  if before.length() != after.length() || before.length() == 0 {
    abort("transform_audit: lengths must match")
  }
  let missing_before = before.filter(fn(value) { value != value }).length()
  let missing_after = after.filter(fn(value) { value != value }).length()
  let clipped = after
    .filter(fn(value) { value <= lower || value >= upper })
    .length()
  {
    rows: before.length(),
    missing_before,
    missing_after,
    clipped,
    mean_before: mean(before.filter(fn(value) { value == value })),
    mean_after: mean(after.filter(fn(value) { value == value })),
  }
}

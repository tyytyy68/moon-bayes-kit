///|
/// Reusable immutable feature transformations for model pipelines.
pub enum FeatureTransform {
  Identity
  MinMax(lower~ : Double, upper~ : Double)
  ZScore(center~ : Double, scale~ : Double)
  Clip(lower~ : Double, upper~ : Double)
  Threshold(cutoff~ : Double)
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn FeatureTransform::apply(
  self : FeatureTransform,
  value : Double,
) -> Double {
  match self {
    Identity => value
    MinMax(lower~, upper~) =>
      if upper == lower {
        0.0
      } else {
        (value - lower) / (upper - lower)
      }
    ZScore(center~, scale~) =>
      if scale == 0.0 {
        0.0
      } else {
        (value - center) / scale
      }
    Clip(lower~, upper~) => value.max(lower).min(upper)
    Threshold(cutoff~) => if value >= cutoff { 1.0 } else { 0.0 }
  }
}

///|
pub fn FeatureTransform::apply_all(
  self : FeatureTransform,
  values : Array[Double],
) -> Array[Double] {
  values.map(fn(value) { self.apply(value) })
}

///|
pub fn FeatureTransform::inverse(
  self : FeatureTransform,
  value : Double,
) -> Double {
  match self {
    Identity => value
    MinMax(lower~, upper~) => lower + value * (upper - lower)
    ZScore(center~, scale~) => center + value * scale
    Clip(..) => value
    Threshold(_) => value
  }
}

///|
pub struct FeatureColumn {
  name : String
  transform : FeatureTransform
  values : Array[Double]
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn FeatureColumn::new(
  name : String,
  values : Array[Double],
) -> FeatureColumn {
  { name, transform: Identity, values: values.copy() }
}

///|
pub fn FeatureColumn::name(self : FeatureColumn) -> String {
  self.name
}

///|
pub fn FeatureColumn::values(self : FeatureColumn) -> Array[Double] {
  self.transform.apply_all(self.values)
}

///|
pub fn FeatureColumn::raw_values(self : FeatureColumn) -> Array[Double] {
  self.values.copy()
}

///|
pub fn FeatureColumn::fit_minmax(self : FeatureColumn) -> FeatureColumn {
  if self.values.length() == 0 {
    return self
  }
  let lower = self.values.fold(init=self.values[0], (current, value) => {
    current.min(value)
  })
  let upper = self.values.fold(init=self.values[0], (current, value) => {
    current.max(value)
  })
  { ..self, transform: MinMax(lower~, upper~) }
}

///|
pub fn FeatureColumn::fit_zscore(self : FeatureColumn) -> FeatureColumn {
  {
    ..self,
    transform: ZScore(
      center=mean(self.values),
      scale=variance(self.values).sqrt(),
    ),
  }
}

///|
pub fn FeatureColumn::clip(
  self : FeatureColumn,
  lower : Double,
  upper : Double,
) -> FeatureColumn {
  { ..self, transform: Clip(lower~, upper~) }
}

///|
pub fn FeatureColumn::threshold(
  self : FeatureColumn,
  cutoff : Double,
) -> FeatureColumn {
  { ..self, transform: Threshold(cutoff~) }
}

///|
pub fn FeatureColumn::missing_count(
  self : FeatureColumn,
  is_missing : (Double) -> Bool,
) -> Int {
  self.values.fold(init=0, (count, value) => {
    if is_missing(value) {
      count + 1
    } else {
      count
    }
  })
}

///|
pub fn FeatureColumn::fill(
  self : FeatureColumn,
  replacement : Double,
  is_missing : (Double) -> Bool,
) -> FeatureColumn {
  {
    ..self,
    values: self.values.map(fn(value) {
      if is_missing(value) {
        replacement
      } else {
        value
      }
    }),
  }
}

///|
pub struct FeaturePipeline {
  columns : Array[FeatureColumn]
  fitted : Bool
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn FeaturePipeline::new(columns : Array[FeatureColumn]) -> FeaturePipeline {
  { columns: columns.copy(), fitted: false }
}

///|
pub fn FeaturePipeline::column_count(self : FeaturePipeline) -> Int {
  self.columns.length()
}

///|
pub fn FeaturePipeline::fit_minmax(self : FeaturePipeline) -> FeaturePipeline {
  {
    columns: self.columns.map(fn(column) { column.fit_minmax() }),
    fitted: true,
  }
}

///|
pub fn FeaturePipeline::fit_zscore(self : FeaturePipeline) -> FeaturePipeline {
  {
    columns: self.columns.map(fn(column) { column.fit_zscore() }),
    fitted: true,
  }
}

///|
pub fn FeaturePipeline::columns(self : FeaturePipeline) -> Array[FeatureColumn] {
  self.columns.copy()
}

///|
pub fn FeaturePipeline::transform(self : FeaturePipeline) -> Dataset {
  if self.columns.length() == 0 {
    abort("FeaturePipeline: columns must not be empty")
  }
  let names = self.columns.map(fn(column) { column.name() })
  let length = self.columns[0].values().length()
  let rows = []
  for row_index in 0..<length {
    let row = []
    for column in self.columns {
      let values = column.values()
      row.push(values[row_index])
    }
    rows.push(row)
  }
  Dataset::new(names, rows)
}

///|
pub fn FeaturePipeline::transform_row(
  self : FeaturePipeline,
  row : Array[Double],
) -> Array[Double] {
  if row.length() != self.column_count() {
    abort("FeaturePipeline: row width mismatch")
  }
  row.mapi(fn(index, value) { self.columns[index].transform.apply(value) })
}

///|
pub fn FeaturePipeline::with_column(
  self : FeaturePipeline,
  column : FeatureColumn,
) -> FeaturePipeline {
  let columns = self.columns.copy()
  columns.push(column)
  { columns, fitted: false }
}

///|
pub fn FeaturePipeline::drop(
  self : FeaturePipeline,
  name : String,
) -> FeaturePipeline {
  {
    columns: self.columns.filter(fn(column) { column.name() != name }),
    fitted: false,
  }
}

///|
pub fn FeaturePipeline::describe(self : FeaturePipeline) -> Array[OnlineStats] {
  self.columns.map(fn(column) { OnlineStats::new().push_all(column.values()) })
}

///|
pub fn polynomial_features(
  values : Array[Double],
  degree : Int,
) -> Array[Double] {
  if degree < 0 {
    abort("polynomial_features: degree must be non-negative")
  }
  let result = []
  for value in values {
    let mut power = 1.0
    for _ in 0..<=degree {
      result.push(power)
      power = power * value
    }
  }
  result
}

///|
pub fn pairwise_products(values : Array[Double]) -> Array[Double] {
  let result = []
  for left in 0..<values.length() {
    for right in left..<values.length() {
      result.push(values[left] * values[right])
    }
  }
  result
}

///|
pub fn one_hot(index : Int, categories : Int) -> Array[Double] {
  if index < 0 || index >= categories || categories <= 0 {
    abort("one_hot: invalid category")
  }
  let result = Array::make(categories, 0.0)
  result[index] = 1.0
  result
}

///|
pub fn one_hot_all(
  indices : Array[Int],
  categories : Int,
) -> Array[Array[Double]] {
  indices.map(fn(index) { one_hot(index, categories) })
}

///|
pub fn interaction_matrix(
  left : Array[Double],
  right : Array[Double],
) -> DenseMatrix {
  outer_product(left, right)
}

///|
pub fn impute_mean(
  values : Array[Double],
  is_missing : (Double) -> Bool,
) -> Array[Double] {
  let observed = values.filter(fn(value) { !is_missing(value) })
  if observed.length() == 0 {
    abort("impute_mean: no observed values")
  }
  let replacement = mean(observed)
  values.map(fn(value) { if is_missing(value) { replacement } else { value } })
}

///|
pub fn impute_median(
  values : Array[Double],
  is_missing : (Double) -> Bool,
) -> Array[Double] {
  let observed = values.filter(fn(value) { !is_missing(value) })
  if observed.length() == 0 {
    abort("impute_median: no observed values")
  }
  let replacement = median(observed)
  values.map(fn(value) { if is_missing(value) { replacement } else { value } })
}

///|
pub fn winsorize(
  values : Array[Double],
  lower_probability : Double,
  upper_probability : Double,
) -> Array[Double] {
  let lower = quantile(values, lower_probability)
  let upper = quantile(values, upper_probability)
  values.map(fn(value) { value.max(lower).min(upper) })
}

///|
pub fn rank_features(matrix : Array[Array[Double]]) -> Array[Int] {
  if matrix.length() == 0 {
    return []
  }
  let scores = Array::make(matrix[0].length(), 0.0)
  for row in matrix {
    for index, value in row {
      scores[index] = scores[index] + value.abs()
    }
  }
  rank_descending(scores)
}

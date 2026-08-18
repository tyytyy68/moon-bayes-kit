///|
/// A small immutable tabular dataset used by model training and evaluation.
pub struct Dataset {
  columns : Array[String]
  rows : Array[Array[Double]]
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn Dataset::new(
  columns : Array[String],
  rows : Array[Array[Double]],
) -> Dataset {
  if columns.length() == 0 {
    abort("Dataset: columns must not be empty")
  }
  for row in rows {
    if row.length() != columns.length() {
      abort("Dataset: row width mismatch")
    }
  }
  { columns: columns.copy(), rows: rows.map(fn(row) { row.copy() }) }
}

///|
pub fn Dataset::empty(columns : Array[String]) -> Dataset {
  Dataset::new(columns, [])
}

///|
pub fn Dataset::column_count(self : Dataset) -> Int {
  self.columns.length()
}

///|
pub fn Dataset::row_count(self : Dataset) -> Int {
  self.rows.length()
}

///|
pub fn Dataset::columns(self : Dataset) -> Array[String] {
  self.columns.copy()
}

///|
pub fn Dataset::rows(self : Dataset) -> Array[Array[Double]] {
  self.rows.map(fn(row) { row.copy() })
}

///|
pub fn Dataset::column_index(self : Dataset, name : String) -> Int {
  for index, column in self.columns {
    if column == name {
      return index
    }
  }
  abort("Dataset: unknown column")
}

///|
pub fn Dataset::column(self : Dataset, index : Int) -> Array[Double] {
  if index < 0 || index >= self.column_count() {
    abort("Dataset: column out of range")
  }
  self.rows.map(fn(row) { row[index] })
}

///|
pub fn Dataset::named_column(self : Dataset, name : String) -> Array[Double] {
  self.column(self.column_index(name))
}

///|
pub fn Dataset::row(self : Dataset, index : Int) -> Array[Double] {
  if index < 0 || index >= self.row_count() {
    abort("Dataset: row out of range")
  }
  self.rows[index].copy()
}

///|
pub fn Dataset::append(self : Dataset, row : Array[Double]) -> Dataset {
  if row.length() != self.column_count() {
    abort("Dataset: row width mismatch")
  }
  let rows = self.rows.map(fn(item) { item.copy() })
  rows.push(row.copy())
  { ..self, rows, }
}

///|
pub fn Dataset::select_rows(self : Dataset, indices : Array[Int]) -> Dataset {
  let rows = indices.map(fn(index) { self.row(index) })
  { ..self, rows, }
}

///|
pub fn Dataset::select_columns(self : Dataset, indices : Array[Int]) -> Dataset {
  let columns = indices.map(fn(index) {
    if index < 0 || index >= self.column_count() {
      abort("Dataset: column out of range")
    }
    self.columns[index]
  })
  let rows = self.rows.map(fn(row) { indices.map(fn(index) { row[index] }) })
  Dataset::new(columns, rows)
}

///|
pub fn Dataset::filter(
  self : Dataset,
  predicate : (Array[Double]) -> Bool,
) -> Dataset {
  let rows = self.rows.filter(predicate)
  { ..self, rows, }
}

///|
pub fn Dataset::map_rows(
  self : Dataset,
  transform : (Array[Double]) -> Array[Double],
) -> Dataset {
  Dataset::new(self.columns, self.rows.map(transform))
}

///|
pub fn Dataset::mean(self : Dataset, column : Int) -> Double {
  mean(self.column(column))
}

///|
pub fn Dataset::variance(self : Dataset, column : Int) -> Double {
  variance(self.column(column))
}

///|
pub fn Dataset::min(self : Dataset, column : Int) -> Double {
  self
  .column(column)
  .fold(init=0.0, (current, value) => {
    if value < current || current == 0.0 {
      value
    } else {
      current
    }
  })
}

///|
pub fn Dataset::max(self : Dataset, column : Int) -> Double {
  self
  .column(column)
  .fold(init=0.0, (current, value) => {
    if value > current {
      value
    } else {
      current
    }
  })
}

///|
pub fn Dataset::normalize(self : Dataset, column : Int) -> Dataset {
  let values = self.column(column)
  let lower = values.fold(init=values[0], (current, value) => current.min(value))
  let upper = values.fold(init=values[0], (current, value) => current.max(value))
  let width = upper - lower
  self.map_rows(fn(row) {
    let result = row.copy()
    result[column] = if width == 0.0 {
      0.0
    } else {
      (result[column] - lower) / width
    }
    result
  })
}

///|
pub fn Dataset::standardize(self : Dataset, column : Int) -> Dataset {
  let values = self.column(column)
  let center = mean(values)
  let deviation = variance(values).sqrt()
  self.map_rows(fn(row) {
    let result = row.copy()
    result[column] = if deviation == 0.0 {
      0.0
    } else {
      (result[column] - center) / deviation
    }
    result
  })
}

///|
pub fn Dataset::train_test_split(
  self : Dataset,
  fraction : Double,
) -> (Dataset, Dataset) {
  let split = chronological_split(self.row_count(), fraction)
  (
    self.select_rows(split.train_indices()),
    self.select_rows(split.test_indices()),
  )
}

///|
pub fn Dataset::batch(self : Dataset, size : Int) -> Array[Dataset] {
  if size <= 0 {
    abort("Dataset::batch: size must be positive")
  }
  let result = []
  let mut start = 0
  while start < self.row_count() {
    let finish = (start + size).min(self.row_count())
    let indices = []
    for index in start..<finish {
      indices.push(index)
    }
    result.push(self.select_rows(indices))
    start = finish
  }
  result
}

///|
pub fn Dataset::join(self : Dataset, other : Dataset) -> Dataset {
  if self.row_count() != other.row_count() {
    abort("Dataset::join: row counts must match")
  }
  let columns = self.columns.copy()
  for column in other.columns {
    columns.push(column)
  }
  let rows = []
  for index in 0..<self.row_count() {
    let row = self.row(index)
    for value in other.row(index) {
      row.push(value)
    }
    rows.push(row)
  }
  Dataset::new(columns, rows)
}

///|
pub fn Dataset::describe(self : Dataset) -> Array[OnlineStats] {
  let result = []
  for index in 0..<self.column_count() {
    result.push(OnlineStats::new().push_all(self.column(index)))
  }
  result
}

///|
pub fn Dataset::correlation(self : Dataset, left : Int, right : Int) -> Double {
  correlation(self.column(left), self.column(right))
}

///|
pub fn Dataset::covariance(self : Dataset, left : Int, right : Int) -> Double {
  covariance(self.column(left), self.column(right))
}

///|
pub fn Dataset::missing_count(
  self : Dataset,
  predicate : (Double) -> Bool,
) -> Int {
  self.rows.fold(init=0, (total, row) => {
    total +
    row.fold(init=0, (count, value) => {
      if predicate(value) {
        count + 1
      } else {
        count
      }
    })
  })
}

///|
pub fn Dataset::to_matrix(self : Dataset) -> DenseMatrix {
  DenseMatrix::from_rows(self.rows)
}

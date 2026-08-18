///|
/// A small dense matrix type for low-dimensional Bayesian models.
/// It deliberately exposes copies at the boundary so models remain immutable.
pub struct DenseMatrix {
  rows : Int
  columns : Int
  values : Array[Double]
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn DenseMatrix::new(
  rows : Int,
  columns : Int,
  values : Array[Double],
) -> DenseMatrix {
  if rows < 0 || columns < 0 || values.length() != rows * columns {
    abort("DenseMatrix::new: dimensions do not match values")
  }
  { rows, columns, values: values.copy() }
}

///|
pub fn DenseMatrix::zeros(rows : Int, columns : Int) -> DenseMatrix {
  if rows < 0 || columns < 0 {
    abort("DenseMatrix::zeros: dimensions must be non-negative")
  }
  DenseMatrix::new(rows, columns, Array::make(rows * columns, 0.0))
}

///|
pub fn DenseMatrix::identity(size : Int) -> DenseMatrix {
  if size < 0 {
    abort("DenseMatrix::identity: size must be non-negative")
  }
  let matrix = DenseMatrix::zeros(size, size)
  let values = matrix.values.copy()
  for index in 0..<size {
    values[index * size + index] = 1.0
  }
  DenseMatrix::new(size, size, values)
}

///|
pub fn DenseMatrix::from_rows(rows : Array[Array[Double]]) -> DenseMatrix {
  if rows.length() == 0 {
    return DenseMatrix::new(0, 0, [])
  }
  let columns = rows[0].length()
  let values = []
  for row in rows {
    if row.length() != columns {
      abort("DenseMatrix::from_rows: row lengths must match")
    }
    for value in row {
      values.push(value)
    }
  }
  DenseMatrix::new(rows.length(), columns, values)
}

///|
pub fn DenseMatrix::rows(self : DenseMatrix) -> Int {
  self.rows
}

///|
pub fn DenseMatrix::columns(self : DenseMatrix) -> Int {
  self.columns
}

///|
pub fn DenseMatrix::at(self : DenseMatrix, row : Int, column : Int) -> Double {
  if row < 0 || row >= self.rows || column < 0 || column >= self.columns {
    abort("DenseMatrix::at: index out of range")
  }
  self.values[row * self.columns + column]
}

///|
pub fn DenseMatrix::set(
  self : DenseMatrix,
  row : Int,
  column : Int,
  value : Double,
) -> DenseMatrix {
  if row < 0 || row >= self.rows || column < 0 || column >= self.columns {
    abort("DenseMatrix::set: index out of range")
  }
  let values = self.values.copy()
  values[row * self.columns + column] = value
  DenseMatrix::new(self.rows, self.columns, values)
}

///|
pub fn DenseMatrix::row(self : DenseMatrix, row : Int) -> Array[Double] {
  if row < 0 || row >= self.rows {
    abort("DenseMatrix::row: index out of range")
  }
  let result = []
  for column in 0..<self.columns {
    result.push(self.at(row, column))
  }
  result
}

///|
pub fn DenseMatrix::column(self : DenseMatrix, column : Int) -> Array[Double] {
  if column < 0 || column >= self.columns {
    abort("DenseMatrix::column: index out of range")
  }
  let result = []
  for row in 0..<self.rows {
    result.push(self.at(row, column))
  }
  result
}

///|
pub fn DenseMatrix::transpose(self : DenseMatrix) -> DenseMatrix {
  let values = Array::make(self.rows * self.columns, 0.0)
  for row in 0..<self.rows {
    for column in 0..<self.columns {
      values[column * self.rows + row] = self.at(row, column)
    }
  }
  DenseMatrix::new(self.columns, self.rows, values)
}

///|
pub fn DenseMatrix::add(self : DenseMatrix, other : DenseMatrix) -> DenseMatrix {
  if self.rows != other.rows || self.columns != other.columns {
    abort("DenseMatrix::add: dimensions must match")
  }
  DenseMatrix::new(
    self.rows,
    self.columns,
    self.values.mapi(fn(i, value) { value + other.values[i] }),
  )
}

///|
pub fn DenseMatrix::subtract(
  self : DenseMatrix,
  other : DenseMatrix,
) -> DenseMatrix {
  if self.rows != other.rows || self.columns != other.columns {
    abort("DenseMatrix::subtract: dimensions must match")
  }
  DenseMatrix::new(
    self.rows,
    self.columns,
    self.values.mapi(fn(i, value) { value - other.values[i] }),
  )
}

///|
pub fn DenseMatrix::scale(self : DenseMatrix, factor : Double) -> DenseMatrix {
  DenseMatrix::new(
    self.rows,
    self.columns,
    self.values.map(fn(value) { value * factor }),
  )
}

///|
pub fn DenseMatrix::matmul(
  self : DenseMatrix,
  other : DenseMatrix,
) -> DenseMatrix {
  if self.columns != other.rows {
    abort("DenseMatrix::matmul: inner dimensions must match")
  }
  let result = Array::make(self.rows * other.columns, 0.0)
  for row in 0..<self.rows {
    for column in 0..<other.columns {
      let mut value = 0.0
      for index in 0..<self.columns {
        value = value + self.at(row, index) * other.at(index, column)
      }
      result[row * other.columns + column] = value
    }
  }
  DenseMatrix::new(self.rows, other.columns, result)
}

///|
pub fn DenseMatrix::matvec(
  self : DenseMatrix,
  vector : Array[Double],
) -> Array[Double] {
  if self.columns != vector.length() {
    abort("DenseMatrix::matvec: dimensions must match")
  }
  let result = Array::make(self.rows, 0.0)
  for row in 0..<self.rows {
    result[row] = dot(self.row(row), vector)
  }
  result
}

///|
pub fn DenseMatrix::trace(self : DenseMatrix) -> Double {
  if self.rows != self.columns {
    abort("DenseMatrix::trace: matrix must be square")
  }
  let mut result = 0.0
  for index in 0..<self.rows {
    result = result + self.at(index, index)
  }
  result
}

///|
pub fn DenseMatrix::is_symmetric(
  self : DenseMatrix,
  tolerance? : Double = 0.000000001,
) -> Bool {
  if self.rows != self.columns || tolerance < 0.0 {
    return false
  }
  for row in 0..<self.rows {
    for column in 0..<row {
      if (self.at(row, column) - self.at(column, row)).abs() > tolerance {
        return false
      }
    }
  }
  true
}

///|
/// Solves a lower-triangular system by forward substitution.
pub fn solve_lower(lower : DenseMatrix, right : Array[Double]) -> Array[Double] {
  if lower.rows() != lower.columns() || right.length() != lower.rows() {
    abort("solve_lower: dimensions must match")
  }
  let result = Array::make(right.length(), 0.0)
  for row in 0..<lower.rows() {
    let mut value = right[row]
    for column in 0..<row {
      value = value - lower.at(row, column) * result[column]
    }
    let diagonal = lower.at(row, row)
    if diagonal == 0.0 {
      abort("solve_lower: singular matrix")
    }
    result[row] = value / diagonal
  }
  result
}

///|
pub fn solve_upper(upper : DenseMatrix, right : Array[Double]) -> Array[Double] {
  if upper.rows() != upper.columns() || right.length() != upper.rows() {
    abort("solve_upper: dimensions must match")
  }
  let result = Array::make(right.length(), 0.0)
  for offset in 0..<upper.rows() {
    let row = upper.rows() - offset - 1
    let mut value = right[row]
    if row + 1 < upper.columns() {
      for column in (row + 1)..<upper.columns() {
        value = value - upper.at(row, column) * result[column]
      }
    }
    let diagonal = upper.at(row, row)
    if diagonal == 0.0 {
      abort("solve_upper: singular matrix")
    }
    result[row] = value / diagonal
  }
  result
}

///|
/// Cholesky factorization for positive definite matrices.
pub fn cholesky(matrix : DenseMatrix) -> DenseMatrix {
  if !matrix.is_symmetric() {
    abort("cholesky: matrix must be symmetric")
  }
  let result = DenseMatrix::zeros(matrix.rows(), matrix.columns())
  let values = result.values.copy()
  for row in 0..<matrix.rows() {
    for column in 0..<=row {
      let mut value = matrix.at(row, column)
      for index in 0..<column {
        value = value -
          values[row * matrix.columns() + index] *
          values[column * matrix.columns() + index]
      }
      if row == column {
        if value <= 0.0 {
          abort("cholesky: matrix is not positive definite")
        }
        values[row * matrix.columns() + column] = value.sqrt()
      } else {
        values[row * matrix.columns() + column] = value /
          values[column * matrix.columns() + column]
      }
    }
  }
  DenseMatrix::new(matrix.rows(), matrix.columns(), values)
}

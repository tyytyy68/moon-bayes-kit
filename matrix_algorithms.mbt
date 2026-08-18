///|
pub fn DenseMatrix::determinant(self : DenseMatrix) -> Double {
  if self.rows() != self.columns() {
    abort("determinant: matrix must be square")
  }
  if self.rows() == 0 {
    return 1.0
  }
  let values = self.values.copy()
  let mut result = 1.0
  let mut sign = 1.0
  for pivot in 0..<self.rows() {
    let mut row = pivot
    for candidate in pivot..<self.rows() {
      if values[candidate * self.columns() + pivot].abs() >
        values[row * self.columns() + pivot].abs() {
        row = candidate
      }
    }
    let pivot_value = values[row * self.columns() + pivot]
    if pivot_value.abs() < 0.000000000001 {
      return 0.0
    }
    if row != pivot {
      sign = 0.0 - sign
      for column in 0..<self.columns() {
        let temporary = values[pivot * self.columns() + column]
        values[pivot * self.columns() + column] = values[row * self.columns() +
          column]
        values[row * self.columns() + column] = temporary
      }
    }
    let selected = values[pivot * self.columns() + pivot]
    result = result * selected
    for next_row in (pivot + 1)..<self.rows() {
      let factor = values[next_row * self.columns() + pivot] / selected
      for column in pivot..<self.columns() {
        values[next_row * self.columns() + column] = values[next_row *
          self.columns() +
          column] -
          factor * values[pivot * self.columns() + column]
      }
    }
  }
  result * sign
}

///|
pub fn DenseMatrix::diagonal(self : DenseMatrix) -> Array[Double] {
  let size = self.rows().min(self.columns())
  let result = []
  for index in 0..<size {
    result.push(self.at(index, index))
  }
  result
}

///|
pub fn DenseMatrix::frobenius_norm(self : DenseMatrix) -> Double {
  self.values.fold(init=0.0, (total, value) => total + value * value).sqrt()
}

///|
pub fn DenseMatrix::hadamard(
  self : DenseMatrix,
  other : DenseMatrix,
) -> DenseMatrix {
  if self.rows() != other.rows() || self.columns() != other.columns() {
    abort("hadamard: dimensions must match")
  }
  DenseMatrix::new(
    self.rows(),
    self.columns(),
    self.values.mapi(fn(index, value) { value * other.values[index] }),
  )
}

///|
pub fn outer_product(
  left : Array[Double],
  right : Array[Double],
) -> DenseMatrix {
  let result = Array::make(left.length() * right.length(), 0.0)
  for row in 0..<left.length() {
    for column in 0..<right.length() {
      result[row * right.length() + column] = left[row] * right[column]
    }
  }
  DenseMatrix::new(left.length(), right.length(), result)
}

///|
pub fn covariance_matrix(samples : Array[Array[Double]]) -> DenseMatrix {
  if samples.length() < 2 || samples[0].length() == 0 {
    abort("covariance_matrix: observations are required")
  }
  let dimension = samples[0].length()
  let center = Array::make(dimension, 0.0)
  for sample in samples {
    if sample.length() != dimension {
      abort("covariance_matrix: dimensions must match")
    }
    for index in 0..<dimension {
      center[index] = center[index] + sample[index]
    }
  }
  for index in 0..<dimension {
    center[index] = center[index] / samples.length().to_double()
  }
  let result = DenseMatrix::zeros(dimension, dimension)
  let values = result.values.copy()
  for sample in samples {
    for row in 0..<dimension {
      for column in 0..<dimension {
        values[row * dimension + column] = values[row * dimension + column] +
          (sample[row] - center[row]) * (sample[column] - center[column])
      }
    }
  }
  DenseMatrix::new(
    dimension,
    dimension,
    values.map(fn(value) { value / (samples.length() - 1).to_double() }),
  )
}

///|
pub fn solve_diagonal(
  diagonal : Array[Double],
  right : Array[Double],
) -> Array[Double] {
  if diagonal.length() != right.length() {
    abort("solve_diagonal: dimensions must match")
  }
  right.mapi(fn(index, value) {
    if diagonal[index] == 0.0 {
      abort("solve_diagonal: singular matrix")
    }
    value / diagonal[index]
  })
}

///|
pub fn matrix_vector_distance(
  left : Array[Double],
  right : Array[Double],
) -> Double {
  if left.length() != right.length() {
    abort("matrix_vector_distance: dimensions must match")
  }
  left
  .foldi(init=0.0, fn(index, total, value) {
    let error = value - right[index]
    total + error * error
  })
  .sqrt()
}

///|
/// Deterministic numerical methods used by inference and monitoring code.
/// These routines favor predictable allocations and explicit convergence
/// reports so production callers can distinguish a result from a failure.
pub struct NumericalResult {
  value : Double
  iterations : Int
  residual : Double
  converged : Bool
  status : String
} derive(Debug, Eq, ToJson, FromJson)

///|
pub struct RootBracket {
  left : Double
  right : Double
  left_value : Double
  right_value : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn RootBracket::new(
  left : Double,
  right : Double,
  function : (Double) -> Double,
) -> RootBracket {
  if left >= right {
    abort("RootBracket: left must be smaller than right")
  }
  let left_value = function(left)
  let right_value = function(right)
  if left_value * right_value > 0.0 {
    abort("RootBracket: endpoints must bracket a sign change")
  }
  { left, right, left_value, right_value }
}

///|
pub fn RootBracket::width(self : RootBracket) -> Double {
  self.right - self.left
}

///|
pub fn solve_bisection(
  function : (Double) -> Double,
  bracket : RootBracket,
  tolerance : Double,
  max_iterations : Int,
) -> NumericalResult {
  if tolerance <= 0.0 || max_iterations <= 0 {
    abort("solve_bisection: invalid convergence settings")
  }
  let mut left = bracket.left
  let mut right = bracket.right
  let mut left_value = bracket.left_value
  let mut midpoint = (left + right) / 2.0
  let mut value = function(midpoint)
  let mut iterations = 0
  let mut converged = false
  while iterations < max_iterations && !converged {
    midpoint = (left + right) / 2.0
    value = function(midpoint)
    converged = value.abs() <= tolerance || (right - left).abs() <= tolerance
    if !converged {
      if left_value * value <= 0.0 {
        right = midpoint
      } else {
        left = midpoint
        left_value = value
      }
    }
    iterations = iterations + 1
  }
  {
    value: midpoint,
    iterations,
    residual: value.abs(),
    converged,
    status: if converged {
      "converged"
    } else {
      "max_iterations"
    },
  }
}

///|
pub fn solve_secant(
  function : (Double) -> Double,
  first : Double,
  second : Double,
  tolerance : Double,
  max_iterations : Int,
) -> NumericalResult {
  if first == second || tolerance <= 0.0 || max_iterations <= 0 {
    abort("solve_secant: invalid starting points or convergence settings")
  }
  let mut previous = first
  let mut current = second
  let mut previous_value = function(previous)
  let mut current_value = function(current)
  let mut iterations = 0
  let mut converged = false
  while iterations < max_iterations && !converged {
    let denominator = current_value - previous_value
    if denominator.abs() <= 0.000000000000001 {
      break
    }
    let next = current - current_value * (current - previous) / denominator
    previous = current
    previous_value = current_value
    current = next
    current_value = function(current)
    converged = current_value.abs() <= tolerance ||
      (current - previous).abs() <= tolerance
    iterations = iterations + 1
  }
  {
    value: current,
    iterations,
    residual: current_value.abs(),
    converged,
    status: if converged {
      "converged"
    } else {
      "unstable_or_max_iterations"
    },
  }
}

///|
pub fn solve_newton(
  function : (Double) -> Double,
  derivative : (Double) -> Double,
  initial : Double,
  tolerance : Double,
  max_iterations : Int,
) -> NumericalResult {
  if tolerance <= 0.0 || max_iterations <= 0 {
    abort("solve_newton: invalid convergence settings")
  }
  let mut value = initial
  let mut residual = function(value).abs()
  let mut iterations = 0
  let mut converged = residual <= tolerance
  while iterations < max_iterations && !converged {
    let slope = derivative(value)
    if slope.abs() <= 0.000000000000001 {
      break
    }
    let next = value - function(value) / slope
    value = next
    residual = function(value).abs()
    converged = residual <= tolerance
    iterations = iterations + 1
  }
  {
    value,
    iterations,
    residual,
    converged,
    status: if converged {
      "converged"
    } else {
      "zero_derivative_or_max_iterations"
    },
  }
}

///|
pub struct QuadratureResult {
  integral : Double
  evaluations : Int
  error_estimate : Double
  converged : Bool
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn integrate_trapezoid(
  function : (Double) -> Double,
  left : Double,
  right : Double,
  slices : Int,
) -> QuadratureResult {
  if left >= right || slices <= 0 {
    abort("integrate_trapezoid: invalid interval or slices")
  }
  let step = (right - left) / slices.to_double()
  let mut total = (function(left) + function(right)) / 2.0
  for index in 1..<slices {
    total = total + function(left + index.to_double() * step)
  }
  {
    integral: total * step,
    evaluations: slices + 1,
    error_estimate: 0.0,
    converged: true,
  }
}

///|
pub fn integrate_simpson(
  function : (Double) -> Double,
  left : Double,
  right : Double,
  slices : Int,
) -> QuadratureResult {
  if left >= right || slices <= 0 || slices % 2 != 0 {
    abort("integrate_simpson: interval and slices must be valid and even")
  }
  let step = (right - left) / slices.to_double()
  let mut total = function(left) + function(right)
  for index in 1..<slices {
    let weight = if index % 2 == 0 { 2.0 } else { 4.0 }
    total = total + weight * function(left + index.to_double() * step)
  }
  {
    integral: total * step / 3.0,
    evaluations: slices + 1,
    error_estimate: 0.0,
    converged: true,
  }
}

///|
pub fn integrate_adaptive(
  function : (Double) -> Double,
  left : Double,
  right : Double,
  tolerance : Double,
  max_refinements : Int,
) -> QuadratureResult {
  if left >= right || tolerance <= 0.0 || max_refinements <= 0 {
    abort("integrate_adaptive: invalid interval or convergence settings")
  }
  let mut slices = 2
  let mut previous = integrate_simpson(function, left, right, slices).integral
  let mut current = previous
  let mut error = 1.0 / 0.0
  let mut refinement = 0
  let mut converged = false
  while refinement < max_refinements && !converged {
    slices = slices * 2
    current = integrate_simpson(function, left, right, slices).integral
    error = (current - previous).abs() / 15.0
    converged = error <= tolerance
    previous = current
    refinement = refinement + 1
  }
  {
    integral: current,
    evaluations: slices + 1,
    error_estimate: error,
    converged,
  }
}

///|
pub struct InterpolationTable {
  x : Array[Double]
  y : Array[Double]
  allow_extrapolation : Bool
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn InterpolationTable::new(
  x : Array[Double],
  y : Array[Double],
) -> InterpolationTable {
  if x.length() < 2 || x.length() != y.length() {
    abort("InterpolationTable: at least two aligned points are required")
  }
  for index in 1..<x.length() {
    if x[index] <= x[index - 1] {
      abort("InterpolationTable: x values must be increasing")
    }
  }
  { x, y, allow_extrapolation: false }
}

///|
pub fn InterpolationTable::with_extrapolation(
  self : InterpolationTable,
  enabled : Bool,
) -> InterpolationTable {
  { ..self, allow_extrapolation: enabled }
}

///|
pub fn InterpolationTable::evaluate(
  self : InterpolationTable,
  value : Double,
) -> Double {
  if !self.allow_extrapolation &&
    (value < self.x[0] || value > self.x[self.x.length() - 1]) {
    abort("InterpolationTable::evaluate: value is outside the table")
  }
  let mut segment = 0
  if value >= self.x[self.x.length() - 1] {
    segment = self.x.length() - 2
  } else {
    for index in 0..<(self.x.length() - 1) {
      if value >= self.x[index] && value <= self.x[index + 1] {
        segment = index
        break
      }
    }
  }
  let fraction = (value - self.x[segment]) /
    (self.x[segment + 1] - self.x[segment])
  self.y[segment] + fraction * (self.y[segment + 1] - self.y[segment])
}

///|
pub fn InterpolationTable::evaluate_all(
  self : InterpolationTable,
  values : Array[Double],
) -> Array[Double] {
  values.map(fn(value) { self.evaluate(value) })
}

///|
pub fn central_derivative(
  function : (Double) -> Double,
  value : Double,
  step : Double,
) -> Double {
  if step <= 0.0 {
    abort("central_derivative: step must be positive")
  }
  (function(value + step) - function(value - step)) / (2.0 * step)
}

///|
pub fn second_derivative(
  function : (Double) -> Double,
  value : Double,
  step : Double,
) -> Double {
  if step <= 0.0 {
    abort("second_derivative: step must be positive")
  }
  (function(value + step) - 2.0 * function(value) + function(value - step)) /
  (step * step)
}

///|
pub struct SolveLinearResult {
  solution : Array[Double]
  residual_norm : Double
  condition_warning : Bool
  solved : Bool
} derive(Debug, Eq, ToJson, FromJson)

///|
fn numerical_residual(
  matrix : Array[Array[Double]],
  vector : Array[Double],
  solution : Array[Double],
) -> Double {
  let mut total = 0.0
  for row in 0..<matrix.length() {
    let mut predicted = 0.0
    for column in 0..<solution.length() {
      predicted = predicted + matrix[row][column] * solution[column]
    }
    let error = predicted - vector[row]
    total = total + error * error
  }
  total.sqrt()
}

///|
/// Gaussian elimination with partial pivoting for small dense systems.
pub fn solve_linear_system(
  matrix : Array[Array[Double]],
  vector : Array[Double],
  tolerance : Double,
) -> SolveLinearResult {
  let size = matrix.length()
  if size == 0 || vector.length() != size || tolerance <= 0.0 {
    abort("solve_linear_system: invalid dimensions or tolerance")
  }
  let augmented : Array[Array[Double]] = []
  for row in matrix.iter() {
    if row.length() != size {
      abort("solve_linear_system: matrix must be square")
    }
    let copy = row.copy()
    copy.push(vector[augmented.length()])
    augmented.push(copy)
  }
  let mut warning = false
  for pivot in 0..<size {
    let mut best = pivot
    for row in (pivot + 1)..<size {
      if augmented[row][pivot].abs() > augmented[best][pivot].abs() {
        best = row
      }
    }
    if best != pivot {
      let swap = augmented[pivot]
      augmented[pivot] = augmented[best]
      augmented[best] = swap
    }
    let pivot_value = augmented[pivot][pivot]
    if pivot_value.abs() <= tolerance {
      warning = true
      continue
    }
    for row in (pivot + 1)..<size {
      let factor = augmented[row][pivot] / pivot_value
      for column in pivot..<(size + 1) {
        augmented[row][column] = augmented[row][column] -
          factor * augmented[pivot][column]
      }
    }
  }
  let solution = Array::make(size, 0.0)
  let mut solved = !warning
  if solved {
    for pivot in 0..<size {
      let row = size - pivot - 1
      let diagonal = augmented[row][row]
      if diagonal.abs() <= tolerance {
        solved = false
        break
      }
      let mut remainder = augmented[row][size]
      for column in (row + 1)..<size {
        remainder = remainder - augmented[row][column] * solution[column]
      }
      solution[row] = remainder / diagonal
    }
  }
  {
    solution,
    residual_norm: numerical_residual(matrix, vector, solution),
    condition_warning: warning,
    solved,
  }
}

///|
pub struct ProjectionBox {
  lower : Array[Double]
  upper : Array[Double]
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn ProjectionBox::new(
  lower : Array[Double],
  upper : Array[Double],
) -> ProjectionBox {
  if lower.length() == 0 || lower.length() != upper.length() {
    abort("ProjectionBox: bounds must be non-empty and aligned")
  }
  for index in 0..<lower.length() {
    if lower[index] > upper[index] {
      abort("ProjectionBox: lower bound exceeds upper bound")
    }
  }
  { lower, upper }
}

///|
pub fn ProjectionBox::project(
  self : ProjectionBox,
  values : Array[Double],
) -> Array[Double] {
  if values.length() != self.lower.length() {
    abort("ProjectionBox::project: dimensions must match")
  }
  let result : Array[Double] = []
  for index in 0..<values.length() {
    result.push(values[index].max(self.lower[index]).min(self.upper[index]))
  }
  result
}

///|
pub fn ProjectionBox::distance_to_boundary(
  self : ProjectionBox,
  values : Array[Double],
) -> Double {
  let projected = self.project(values)
  let mut distance = 1.0 / 0.0
  for index in 0..<values.length() {
    distance = distance.min((values[index] - projected[index]).abs())
  }
  if distance == 1.0 / 0.0 {
    0.0
  } else {
    distance
  }
}

///|
pub fn log_sum_exp(values : Array[Double]) -> Double {
  if values.length() == 0 {
    abort("log_sum_exp: values must not be empty")
  }
  let maximum = values.fold(init=values[0], (current, value) => {
    current.max(value)
  })
  let total = values.fold(init=0.0, (sum_value, value) => {
    sum_value + @math.pow(2.718281828459045, value - maximum)
  })
  maximum + uncertainty_log(total)
}

///|
pub fn stable_softmax(values : Array[Double]) -> Array[Double] {
  let normalizer = log_sum_exp(values)
  values.map(fn(value) { @math.pow(2.718281828459045, value - normalizer) })
}

///|
pub fn weighted_projection(
  values : Array[Double],
  weights : Array[Double],
  bounds : ProjectionBox,
) -> Array[Double] {
  if values.length() != weights.length() ||
    values.length() != bounds.lower.length() {
    abort("weighted_projection: dimensions must match")
  }
  for weight in weights.iter() {
    if weight < 0.0 {
      abort("weighted_projection: weights must be non-negative")
    }
  }
  let projected = bounds.project(values)
  let result : Array[Double] = []
  for index in 0..<values.length() {
    result.push(
      projected[index] *
      (1.0 + weights[index]).sqrt() /
      (1.0 + weights[index]).sqrt(),
    )
  }
  result
}

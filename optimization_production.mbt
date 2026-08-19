///|
/// Production-oriented optimization primitives for fitting small Bayesian and
/// statistical models without pulling a heavyweight numerical runtime into a
/// MoonBit application.
pub struct OptimizationConfig {
  learning_rate : Double
  max_iterations : Int
  tolerance : Double
  l2_penalty : Double
  patience : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn OptimizationConfig::new() -> OptimizationConfig {
  {
    learning_rate: 0.01,
    max_iterations: 500,
    tolerance: 0.000001,
    l2_penalty: 0.0,
    patience: 20,
  }
}

///|
pub fn OptimizationConfig::with_learning_rate(
  self : OptimizationConfig,
  value : Double,
) -> OptimizationConfig {
  if value <= 0.0 {
    abort("OptimizationConfig: learning rate must be positive")
  }
  { ..self, learning_rate: value }
}

///|
pub fn OptimizationConfig::with_iterations(
  self : OptimizationConfig,
  value : Int,
) -> OptimizationConfig {
  if value <= 0 {
    abort("OptimizationConfig: iterations must be positive")
  }
  { ..self, max_iterations: value }
}

///|
pub fn OptimizationConfig::with_tolerance(
  self : OptimizationConfig,
  value : Double,
) -> OptimizationConfig {
  if value <= 0.0 {
    abort("OptimizationConfig: tolerance must be positive")
  }
  { ..self, tolerance: value }
}

///|
pub fn OptimizationConfig::with_l2(
  self : OptimizationConfig,
  value : Double,
) -> OptimizationConfig {
  if value < 0.0 {
    abort("OptimizationConfig: l2 penalty must be non-negative")
  }
  { ..self, l2_penalty: value }
}

///|
pub fn OptimizationConfig::with_patience(
  self : OptimizationConfig,
  value : Int,
) -> OptimizationConfig {
  if value <= 0 {
    abort("OptimizationConfig: patience must be positive")
  }
  { ..self, patience: value }
}

///|
pub struct OptimizationPoint {
  iteration : Int
  loss : Double
  gradient_norm : Double
  step_size : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub struct OptimizationTrace {
  points : Array[OptimizationPoint]
  parameters : Array[Double]
  loss : Double
  iterations : Int
  converged : Bool
  stopped_by_patience : Bool
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn OptimizationTrace::best_loss(self : OptimizationTrace) -> Double {
  self.loss
}

///|
pub fn OptimizationTrace::parameter_count(self : OptimizationTrace) -> Int {
  self.parameters.length()
}

///|
pub fn OptimizationTrace::history(
  self : OptimizationTrace,
) -> Array[OptimizationPoint] {
  self.points.copy()
}

///|
pub fn OptimizationTrace::is_successful(self : OptimizationTrace) -> Bool {
  self.converged
}

///|
fn optimization_check_vector(values : Array[Double], name : String) -> Unit {
  if values.length() == 0 {
    abort(name + ": vector must not be empty")
  }
  for value in values.iter() {
    if value != value || value.is_inf() {
      abort(name + ": non-finite value")
    }
  }
}

///|
fn optimization_norm(values : Array[Double]) -> Double {
  values.fold(init=0.0, (total, value) => total + value * value).sqrt()
}

///|
fn optimization_add_scaled(
  values : Array[Double],
  direction : Array[Double],
  scale : Double,
) -> Array[Double] {
  if values.length() != direction.length() {
    abort("optimization_add_scaled: vector lengths must match")
  }
  let result : Array[Double] = []
  for index in 0..<values.length() {
    result.push(values[index] + direction[index] * scale)
  }
  result
}

///|
fn optimization_l2(parameters : Array[Double], penalty : Double) -> Double {
  penalty *
  parameters.fold(init=0.0, (total, value) => total + value * value) /
  2.0
}

///|
fn optimization_l2_gradient(
  parameters : Array[Double],
  penalty : Double,
) -> Array[Double] {
  parameters.map(fn(value) { penalty * value })
}

///|
fn optimization_tail(values : Array[Double]) -> Array[Double] {
  if values.length() <= 1 {
    return []
  }
  let result : Array[Double] = []
  for index in 1..<values.length() {
    result.push(values[index])
  }
  result
}

///|
/// Computes a central finite-difference gradient for black-box objectives.
pub fn finite_difference_gradient(
  objective : (Array[Double]) -> Double,
  parameters : Array[Double],
  step : Double,
) -> Array[Double] {
  optimization_check_vector(parameters, "finite_difference_gradient")
  if step <= 0.0 {
    abort("finite_difference_gradient: step must be positive")
  }
  let result : Array[Double] = []
  for index in 0..<parameters.length() {
    let plus = parameters.copy()
    let minus = parameters.copy()
    plus[index] = plus[index] + step
    minus[index] = minus[index] - step
    result.push((objective(plus) - objective(minus)) / (2.0 * step))
  }
  result
}

///|
/// Armijo backtracking keeps a proposed gradient step inside a useful local
/// neighborhood. It is also useful to callers that implement their own loop.
pub fn backtracking_step(
  objective : (Array[Double]) -> Double,
  parameters : Array[Double],
  gradient : Array[Double],
  initial_step : Double,
  shrink : Double,
  sufficient_decrease : Double,
) -> Double {
  optimization_check_vector(parameters, "backtracking_step")
  if parameters.length() != gradient.length() {
    abort("backtracking_step: vector lengths must match")
  }
  if initial_step <= 0.0 || shrink <= 0.0 || shrink >= 1.0 {
    abort("backtracking_step: invalid step parameters")
  }
  if sufficient_decrease <= 0.0 || sufficient_decrease >= 1.0 {
    abort("backtracking_step: sufficient decrease must be in (0, 1)")
  }
  let base_loss = objective(parameters)
  let gradient_energy = gradient.fold(init=0.0, (total, value) => {
    total + value * value
  })
  let mut step = initial_step
  let mut accepted = false
  let mut attempts = 0
  while !accepted && attempts < 60 {
    let candidate = optimization_add_scaled(parameters, gradient, -step)
    let candidate_loss = objective(candidate)
    accepted = candidate_loss <=
      base_loss - sufficient_decrease * step * gradient_energy
    if !accepted {
      step = step * shrink
    }
    attempts = attempts + 1
  }
  step
}

///|
/// Batch gradient descent with optional L2 regularization and an immutable
/// trace that can be serialized into experiment metadata.
pub fn gradient_descent(
  objective : (Array[Double]) -> Double,
  gradient : (Array[Double]) -> Array[Double],
  initial : Array[Double],
  config : OptimizationConfig,
) -> OptimizationTrace {
  optimization_check_vector(initial, "gradient_descent")
  let mut parameters = initial.copy()
  let points : Array[OptimizationPoint] = []
  let mut previous_loss = 1.0 / 0.0
  let mut best_loss = 1.0 / 0.0
  let mut stale = 0
  let mut converged = false
  let mut iteration = 0
  while iteration < config.max_iterations && !converged {
    let raw_gradient = gradient(parameters)
    if raw_gradient.length() != parameters.length() {
      abort("gradient_descent: gradient length must match parameters")
    }
    let regularizer = optimization_l2_gradient(parameters, config.l2_penalty)
    let full_gradient = optimization_add_scaled(raw_gradient, regularizer, 1.0)
    let norm = optimization_norm(full_gradient)
    let loss = objective(parameters) +
      optimization_l2(parameters, config.l2_penalty)
    let step = backtracking_step(
      fn(values) {
        objective(values) + optimization_l2(values, config.l2_penalty)
      },
      parameters,
      full_gradient,
      config.learning_rate,
      0.5,
      0.0001,
    )
    points.push({ iteration, loss, gradient_norm: norm, step_size: step })
    if (best_loss - loss).abs() <= config.tolerance {
      stale = stale + 1
    } else {
      stale = 0
    }
    if loss < best_loss {
      best_loss = loss
    }
    let next = optimization_add_scaled(parameters, full_gradient, -step)
    let change = optimization_norm(
      optimization_add_scaled(next, parameters, -1.0),
    )
    parameters = next
    converged = norm <= config.tolerance ||
      change <= config.tolerance ||
      stale >= config.patience
    previous_loss = loss
    iteration = iteration + 1
  }
  let final_loss = objective(parameters) +
    optimization_l2(parameters, config.l2_penalty)
  {
    points,
    parameters,
    loss: final_loss.min(previous_loss),
    iterations: iteration,
    converged: converged && stale < config.patience,
    stopped_by_patience: stale >= config.patience,
  }
}

///|
pub struct AdamConfig {
  learning_rate : Double
  beta1 : Double
  beta2 : Double
  epsilon : Double
  max_iterations : Int
  tolerance : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn AdamConfig::new() -> AdamConfig {
  {
    learning_rate: 0.001,
    beta1: 0.9,
    beta2: 0.999,
    epsilon: 0.000000001,
    max_iterations: 500,
    tolerance: 0.000001,
  }
}

///|
pub fn AdamConfig::with_learning_rate(
  self : AdamConfig,
  value : Double,
) -> AdamConfig {
  if value <= 0.0 {
    abort("AdamConfig: learning rate must be positive")
  }
  { ..self, learning_rate: value }
}

///|
pub fn AdamConfig::with_iterations(
  self : AdamConfig,
  value : Int,
) -> AdamConfig {
  if value <= 0 {
    abort("AdamConfig: iterations must be positive")
  }
  { ..self, max_iterations: value }
}

///|
pub struct AdamState {
  first_moment : Array[Double]
  second_moment : Array[Double]
  step : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn AdamState::new(size : Int) -> AdamState {
  if size <= 0 {
    abort("AdamState: size must be positive")
  }
  {
    first_moment: Array::make(size, 0.0),
    second_moment: Array::make(size, 0.0),
    step: 0,
  }
}

///|
pub fn AdamState::update(
  self : AdamState,
  gradient : Array[Double],
  config : AdamConfig,
) -> (AdamState, Array[Double]) {
  if gradient.length() != self.first_moment.length() {
    abort("AdamState::update: gradient length must match state")
  }
  let step = self.step + 1
  let first = self.first_moment.copy()
  let second = self.second_moment.copy()
  let updates : Array[Double] = []
  let bias1 = 1.0 - @math.pow(config.beta1, step.to_double())
  let bias2 = 1.0 - @math.pow(config.beta2, step.to_double())
  for index in 0..<gradient.length() {
    let value = gradient[index]
    first[index] = config.beta1 * first[index] + (1.0 - config.beta1) * value
    second[index] = config.beta2 * second[index] +
      (1.0 - config.beta2) * value * value
    let first_hat = first[index] / bias1
    let second_hat = second[index] / bias2
    updates.push(
      config.learning_rate * first_hat / (second_hat.sqrt() + config.epsilon),
    )
  }
  ({ first_moment: first, second_moment: second, step }, updates)
}

///|
pub fn adam_optimize(
  objective : (Array[Double]) -> Double,
  gradient : (Array[Double]) -> Array[Double],
  initial : Array[Double],
  config : AdamConfig,
) -> OptimizationTrace {
  optimization_check_vector(initial, "adam_optimize")
  let mut parameters = initial.copy()
  let mut state = AdamState::new(parameters.length())
  let points : Array[OptimizationPoint] = []
  let mut converged = false
  let mut iteration = 0
  while iteration < config.max_iterations && !converged {
    let loss = objective(parameters)
    let gradients = gradient(parameters)
    let norm = optimization_norm(gradients)
    let (next_state, updates) = state.update(gradients, config)
    let next = optimization_add_scaled(parameters, updates, -1.0)
    points.push({
      iteration,
      loss,
      gradient_norm: norm,
      step_size: config.learning_rate,
    })
    converged = norm <= config.tolerance ||
      optimization_norm(optimization_add_scaled(next, parameters, -1.0)) <=
      config.tolerance
    parameters = next
    state = next_state
    iteration = iteration + 1
  }
  {
    points,
    parameters,
    loss: objective(parameters),
    iterations: iteration,
    converged,
    stopped_by_patience: false,
  }
}

///|
pub struct LinearFit {
  coefficients : Array[Double]
  intercept : Double
  loss : Double
  rmse : Double
  observations : Int
  iterations : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn LinearFit::predict(self : LinearFit, features : Array[Double]) -> Double {
  if features.length() != self.coefficients.length() {
    abort("LinearFit::predict: feature count must match")
  }
  self.intercept + dot(self.coefficients, features)
}

///|
pub fn LinearFit::coefficients(self : LinearFit) -> Array[Double] {
  self.coefficients.copy()
}

///|
pub fn LinearFit::intercept(self : LinearFit) -> Double {
  self.intercept
}

///|
pub fn LinearFit::rmse(self : LinearFit) -> Double {
  self.rmse
}

///|
/// Fits an ordinary or ridge-regularized linear model using stable batch
/// gradients. This is intentionally small and deterministic for embedded use.
pub fn fit_linear_model(
  features : Array[Array[Double]],
  targets : Array[Double],
  config : OptimizationConfig,
) -> LinearFit {
  if features.length() == 0 || features.length() != targets.length() {
    abort(
      "fit_linear_model: observations and targets must be non-empty and aligned",
    )
  }
  let width = features[0].length()
  if width == 0 {
    abort("fit_linear_model: features must not be empty")
  }
  for row in features.iter() {
    if row.length() != width {
      abort("fit_linear_model: feature width must be constant")
    }
  }
  let initial = Array::make(width + 1, 0.0)
  let objective : (Array[Double]) -> Double = fn(parameters : Array[Double]) {
    let mut total = 0.0
    for row_index in 0..<features.length() {
      let prediction = parameters[0] +
        dot(optimization_tail(parameters), features[row_index])
      let error = prediction - targets[row_index]
      total = total + error * error / (2.0 * features.length().to_double())
    }
    total
  }
  let gradient : (Array[Double]) -> Array[Double] = fn(
    parameters : Array[Double],
  ) {
    let result = Array::make(width + 1, 0.0)
    for row_index in 0..<features.length() {
      let row = features[row_index]
      let prediction = parameters[0] + dot(optimization_tail(parameters), row)
      let error = prediction - targets[row_index]
      result[0] = result[0] + error / features.length().to_double()
      for column in 0..<width {
        result[column + 1] = result[column + 1] +
          error * row[column] / features.length().to_double()
      }
    }
    result
  }
  let trace = gradient_descent(objective, gradient, initial, config)
  let parameters = trace.parameters
  let mut squared = 0.0
  for index in 0..<features.length() {
    let error = trace.parameters[0] +
      dot(optimization_tail(trace.parameters), features[index]) -
      targets[index]
    squared = squared + error * error
  }
  {
    coefficients: optimization_tail(parameters),
    intercept: parameters[0],
    loss: trace.loss,
    rmse: (squared / features.length().to_double()).sqrt(),
    observations: features.length(),
    iterations: trace.iterations,
  }
}

///|
pub struct CoordinateSearchResult {
  parameters : Array[Double]
  loss : Double
  iterations : Int
  converged : Bool
} derive(Debug, Eq, ToJson, FromJson)

///|
/// Derivative-free coordinate search is useful for small hyperparameter and
/// calibration problems where an analytic gradient is unavailable.
pub fn coordinate_search(
  objective : (Array[Double]) -> Double,
  initial : Array[Double],
  step : Double,
  tolerance : Double,
  max_iterations : Int,
) -> CoordinateSearchResult {
  optimization_check_vector(initial, "coordinate_search")
  if step <= 0.0 || tolerance <= 0.0 || max_iterations <= 0 {
    abort("coordinate_search: invalid search parameters")
  }
  let parameters = initial.copy()
  let mut current = objective(parameters)
  let mut coordinate_step = step
  let mut iterations = 0
  let mut converged = false
  while iterations < max_iterations && !converged {
    let mut improved = false
    for index in 0..<parameters.length() {
      let mut best_value = parameters[index]
      let mut best_loss = current
      let positive = parameters.copy()
      positive[index] = positive[index] + coordinate_step
      let positive_loss = objective(positive)
      if positive_loss < best_loss {
        best_value = positive[index]
        best_loss = positive_loss
      }
      let negative = parameters.copy()
      negative[index] = negative[index] - coordinate_step
      let negative_loss = objective(negative)
      if negative_loss < best_loss {
        best_value = negative[index]
        best_loss = negative_loss
      }
      if best_loss < current {
        parameters[index] = best_value
        current = best_loss
        improved = true
      }
    }
    if !improved {
      coordinate_step = coordinate_step * 0.5
    }
    converged = coordinate_step <= tolerance
    iterations = iterations + 1
  }
  { parameters, loss: current, iterations, converged }
}

///|
pub struct EarlyStopping {
  best : Double
  bad_rounds : Int
  patience : Int
  minimize : Bool
  stopped : Bool
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn EarlyStopping::new(patience : Int, minimize : Bool) -> EarlyStopping {
  if patience <= 0 {
    abort("EarlyStopping: patience must be positive")
  }
  {
    best: if minimize {
      1.0 / 0.0
    } else {
      -1.0 / 0.0
    },
    bad_rounds: 0,
    patience,
    minimize,
    stopped: false,
  }
}

///|
pub fn EarlyStopping::observe(
  self : EarlyStopping,
  value : Double,
) -> EarlyStopping {
  let improved = if self.minimize {
    value < self.best
  } else {
    value > self.best
  }
  if improved {
    { ..self, best: value, bad_rounds: 0 }
  } else {
    let bad = self.bad_rounds + 1
    { ..self, bad_rounds: bad, stopped: bad >= self.patience }
  }
}

///|
pub fn EarlyStopping::best(self : EarlyStopping) -> Double {
  self.best
}

///|
pub fn EarlyStopping::should_stop(self : EarlyStopping) -> Bool {
  self.stopped
}

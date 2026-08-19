///|
/// Discrete Bayesian-network factors and variable-elimination inference.
pub struct DiscreteVariable {
  name : String
  cardinality : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn DiscreteVariable::new(
  name : String,
  cardinality : Int,
) -> DiscreteVariable {
  if name == "" || cardinality <= 0 {
    abort("DiscreteVariable: invalid variable")
  }
  { name, cardinality }
}

///|
pub struct Factor {
  variables : Array[DiscreteVariable]
  values : Array[Double]
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn Factor::constant(value : Double) -> Factor {
  { variables: [], values: [value] }
}

///|
pub fn Factor::new(
  variables : Array[DiscreteVariable],
  values : Array[Double],
) -> Factor {
  let expected = variables.fold(init=1, (size, variable) => {
    size * variable.cardinality
  })
  if values.length() != expected {
    abort("Factor::new: values do not match cardinalities")
  }
  { variables: variables.copy(), values: values.copy() }
}

///|
pub fn Factor::size(self : Factor) -> Int {
  self.values.length()
}

///|
pub fn Factor::contains(self : Factor, name : String) -> Bool {
  self.variables.any(fn(variable) { variable.name == name })
}

///|
pub fn Factor::variable_index(self : Factor, name : String) -> Int {
  for index in 0..<self.variables.length() {
    if self.variables[index].name == name {
      return index
    }
  }
  -1
}

///|
pub fn Factor::stride(self : Factor, variable_index : Int) -> Int {
  let mut result = 1
  for index in (variable_index + 1)..<self.variables.length() {
    result = result * self.variables[index].cardinality
  }
  result
}

///|
pub fn Factor::assignment(self : Factor, flat_index : Int) -> Array[Int] {
  if flat_index < 0 || flat_index >= self.values.length() {
    abort("Factor::assignment: index out of range")
  }
  let result : Array[Int] = []
  for index in 0..<self.variables.length() {
    result.push(
      flat_index / self.stride(index) % self.variables[index].cardinality,
    )
  }
  result
}

///|
pub fn Factor::index_of(self : Factor, assignment : Array[Int]) -> Int {
  if assignment.length() != self.variables.length() {
    abort("Factor::index_of: dimension mismatch")
  }
  let mut result = 0
  for index in 0..<assignment.length() {
    if assignment[index] < 0 ||
      assignment[index] >= self.variables[index].cardinality {
      abort("Factor::index_of: state out of range")
    }
    result = result + assignment[index] * self.stride(index)
  }
  result
}

///|
pub fn Factor::at(self : Factor, assignment : Array[Int]) -> Double {
  self.values[self.index_of(assignment)]
}

///|
pub fn Factor::sum(self : Factor) -> Double {
  self.values.fold(init=0.0, (total, value) => total + value)
}

///|
pub fn Factor::normalize(self : Factor) -> Factor {
  let total = self.sum()
  if total <= 0.0 {
    abort("Factor::normalize: factor mass must be positive")
  }
  { ..self, values: self.values.map(fn(value) { value / total }) }
}

///|
pub fn Factor::map_values(
  self : Factor,
  transform : (Double) -> Double,
) -> Factor {
  { ..self, values: self.values.map(transform) }
}

///|
pub fn Factor::condition(
  self : Factor,
  evidence : Array[(String, Int)],
) -> Factor {
  let result = self.values.copy()
  for flat_index in 0..<result.length() {
    let assignment = self.assignment(flat_index)
    for observation in evidence {
      let variable_index = self.variable_index(observation.0)
      if variable_index >= 0 && assignment[variable_index] != observation.1 {
        result[flat_index] = 0.0
      }
    }
  }
  { ..self, values: result }
}

///|
pub fn Factor::marginalize(self : Factor, variable : String) -> Factor {
  let removed = self.variable_index(variable)
  if removed < 0 {
    return self
  }
  let remaining : Array[DiscreteVariable] = []
  for index in 0..<self.variables.length() {
    if index != removed {
      remaining.push(self.variables[index])
    }
  }
  let result_size = remaining.fold(init=1, (size, item) => {
    size * item.cardinality
  })
  let result : Array[Double] = []
  for _ in 0..<result_size {
    result.push(0.0)
  }
  for flat_index in 0..<self.values.length() {
    let full_assignment = self.assignment(flat_index)
    let reduced : Array[Int] = []
    for index in 0..<full_assignment.length() {
      if index != removed {
        reduced.push(full_assignment[index])
      }
    }
    let reduced_index = if reduced.length() == 0 {
      0
    } else {
      Factor::new(remaining, result).index_of(reduced)
    }
    result[reduced_index] = result[reduced_index] + self.values[flat_index]
  }
  { variables: remaining, values: result }
}

///|
pub fn multiply_factors(left : Factor, right : Factor) -> Factor {
  let variables = left.variables.copy()
  for variable in right.variables.iter() {
    if !variables.any(fn(item) { item.name == variable.name }) {
      variables.push(variable)
    }
  }
  let size = variables.fold(init=1, (total, variable) => {
    total * variable.cardinality
  })
  let result : Array[Double] = []
  for _ in 0..<size {
    result.push(0.0)
  }
  for flat_index in 0..<size {
    let assignment = Factor::new(variables, result).assignment(flat_index)
    let left_assignment : Array[Int] = []
    for variable in left.variables.iter() {
      for index in 0..<variables.length() {
        if variables[index].name == variable.name {
          left_assignment.push(assignment[index])
        }
      }
    }
    let right_assignment : Array[Int] = []
    for variable in right.variables.iter() {
      for index in 0..<variables.length() {
        if variables[index].name == variable.name {
          right_assignment.push(assignment[index])
        }
      }
    }
    result[flat_index] = left.at(left_assignment) * right.at(right_assignment)
  }
  { variables, values: result }
}

///|
pub fn multiply_all(factors : Array[Factor]) -> Factor {
  if factors.length() == 0 {
    return Factor::constant(1.0)
  }
  let mut result = factors[0]
  for index in 1..<factors.length() {
    result = multiply_factors(result, factors[index])
  }
  result
}

///|
pub fn sum_out(factors : Array[Factor], variable : String) -> Array[Factor] {
  factors.map(fn(factor) { factor.marginalize(variable) })
}

///|
pub struct BayesianNetwork {
  variables : Array[DiscreteVariable]
  factors : Array[Factor]
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn BayesianNetwork::new() -> BayesianNetwork {
  { variables: [], factors: [] }
}

///|
pub fn BayesianNetwork::add_variable(
  self : BayesianNetwork,
  variable : DiscreteVariable,
) -> BayesianNetwork {
  if self.variables.any(fn(item) { item.name == variable.name }) {
    abort("BayesianNetwork: duplicate variable")
  }
  let variables = self.variables.copy()
  variables.push(variable)
  { ..self, variables, }
}

///|
pub fn BayesianNetwork::add_factor(
  self : BayesianNetwork,
  factor : Factor,
) -> BayesianNetwork {
  for variable in factor.variables.iter() {
    if !self.variables.any(fn(item) {
        item.name == variable.name && item.cardinality == variable.cardinality
      }) {
      abort("BayesianNetwork: factor references unknown variable")
    }
  }
  let factors = self.factors.copy()
  factors.push(factor)
  { ..self, factors, }
}

///|
pub fn BayesianNetwork::variable(
  self : BayesianNetwork,
  name : String,
) -> DiscreteVariable {
  for variable in self.variables.iter() {
    if variable.name == name {
      return variable
    }
  }
  abort("BayesianNetwork: variable not found")
}

///|
pub fn BayesianNetwork::joint(self : BayesianNetwork) -> Factor {
  multiply_all(self.factors).normalize()
}

///|
pub fn BayesianNetwork::query(
  self : BayesianNetwork,
  target : String,
  evidence : Array[(String, Int)],
) -> Factor {
  let target_variable = self.variable(target)
  let conditioned = self.factors.map(fn(factor) { factor.condition(evidence) })
  let hidden : Array[String] = []
  for variable in self.variables {
    if variable.name != target &&
      !evidence.any(fn(item) { item.0 == variable.name }) {
      hidden.push(variable.name)
    }
  }
  let mut result = multiply_all(conditioned)
  for variable in hidden {
    result = result.marginalize(variable)
  }
  if result.variables.length() == 0 {
    Factor::new([target_variable], [result.sum()]).normalize()
  } else {
    result.normalize()
  }
}

///|
pub fn BayesianNetwork::evidence_probability(
  self : BayesianNetwork,
  evidence : Array[(String, Int)],
) -> Double {
  multiply_all(self.factors.map(fn(factor) { factor.condition(evidence) })).sum()
}

///|
pub fn BayesianNetwork::log_evidence(
  self : BayesianNetwork,
  evidence : Array[(String, Int)],
) -> Double {
  let probability = self.evidence_probability(evidence)
  if probability <= 0.0 {
    -1.0 / 0.0
  } else {
    uncertainty_log(probability)
  }
}

///|
pub struct ConditionalTable {
  child : String
  parents : Array[String]
  cardinalities : Array[Int]
  probabilities : Array[Double]
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn ConditionalTable::new(
  child : String,
  parents : Array[String],
  cardinalities : Array[Int],
  probabilities : Array[Double],
) -> ConditionalTable {
  let parent_configurations = cardinalities.fold(init=1, (total, value) => {
    total * value
  })
  if probabilities.length() !=
    parent_configurations * cardinalities[cardinalities.length() - 1] {
    abort("ConditionalTable: probability shape mismatch")
  }
  { child, parents, cardinalities, probabilities }
}

///|
pub fn ConditionalTable::row_count(self : ConditionalTable) -> Int {
  self.probabilities.length() /
  self.cardinalities[self.cardinalities.length() - 1]
}

///|
pub fn ConditionalTable::validate(self : ConditionalTable) -> Bool {
  let child_cardinality = self.cardinalities[self.cardinalities.length() - 1]
  for row in 0..<self.row_count() {
    let mut total = 0.0
    for state in 0..<child_cardinality {
      total = total + self.probabilities[row * child_cardinality + state]
    }
    if (total - 1.0).abs() > 0.0000001 {
      return false
    }
  }
  true
}

///|
pub fn ConditionalTable::factor(
  self : ConditionalTable,
  variables : Array[DiscreteVariable],
) -> Factor {
  Factor::new(variables, self.probabilities)
}

///|
pub struct PosteriorPredictive {
  probabilities : Array[Double]
  entropy : Double
  most_likely : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn posterior_predictive(
  factor : Factor,
  target : String,
) -> PosteriorPredictive {
  let marginal = factor.marginalize_all_except(target)
  let normalized = marginal.normalize()
  let mut best = 0
  for index in 1..<normalized.values.length() {
    if normalized.values[index] > normalized.values[best] {
      best = index
    }
  }
  let entropy = normalized.values.fold(init=0.0, (total, probability) => {
    if probability <= 0.0 {
      total
    } else {
      total - probability * uncertainty_log(probability)
    }
  })
  { probabilities: normalized.values, entropy, most_likely: best }
}

///|
pub fn Factor::marginalize_all_except(self : Factor, target : String) -> Factor {
  let mut result = self
  for variable in self.variables {
    if variable.name != target {
      result = result.marginalize(variable.name)
    }
  }
  result
}

///|
pub fn factor_kl_divergence(left : Factor, right : Factor) -> Double {
  let aligned = multiply_factors(left, Factor::constant(1.0))
  if aligned.values.length() != right.values.length() {
    abort("factor_kl_divergence: shape mismatch")
  }
  let mut total = 0.0
  for index in 0..<left.values.length() {
    if left.values[index] > 0.0 && right.values[index] > 0.0 {
      total = total +
        left.values[index] *
        uncertainty_log(left.values[index] / right.values[index])
    }
  }
  total
}

///|
pub fn factor_total_variation(left : Factor, right : Factor) -> Double {
  if left.values.length() != right.values.length() {
    abort("factor_total_variation: shape mismatch")
  }
  let mut total = 0.0
  for index in 0..<left.values.length() {
    total = total + (left.values[index] - right.values[index]).abs()
  }
  total / 2.0
}

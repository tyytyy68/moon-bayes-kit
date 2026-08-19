///|
/// Privacy accounting and controlled release utilities for statistical outputs.
pub enum PrivacyMechanism {
  Laplace
  Gaussian
  RandomizedResponse
  Exponential
} derive(Debug, Eq, ToJson, FromJson)

///|
pub struct PrivacyBudget {
  epsilon : Double
  delta : Double
  consumed_epsilon : Double
  consumed_delta : Double
  releases : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn PrivacyBudget::new(epsilon : Double, delta : Double) -> PrivacyBudget {
  if epsilon <= 0.0 || delta < 0.0 || delta >= 1.0 {
    abort("PrivacyBudget: invalid budget")
  }
  { epsilon, delta, consumed_epsilon: 0.0, consumed_delta: 0.0, releases: 0 }
}

///|
pub fn PrivacyBudget::remaining_epsilon(self : PrivacyBudget) -> Double {
  (self.epsilon - self.consumed_epsilon).max(0.0)
}

///|
pub fn PrivacyBudget::remaining_delta(self : PrivacyBudget) -> Double {
  (self.delta - self.consumed_delta).max(0.0)
}

///|
pub fn PrivacyBudget::can_spend(
  self : PrivacyBudget,
  epsilon : Double,
  delta : Double,
) -> Bool {
  epsilon >= 0.0 &&
  delta >= 0.0 &&
  self.consumed_epsilon + epsilon <= self.epsilon &&
  self.consumed_delta + delta <= self.delta
}

///|
pub fn PrivacyBudget::spend(
  self : PrivacyBudget,
  epsilon : Double,
  delta : Double,
) -> PrivacyBudget {
  if !self.can_spend(epsilon, delta) {
    abort("PrivacyBudget: requested release exceeds budget")
  }
  {
    ..self,
    consumed_epsilon: self.consumed_epsilon + epsilon,
    consumed_delta: self.consumed_delta + delta,
    releases: self.releases + 1,
  }
}

///|
pub struct Sensitivity {
  lower : Double
  upper : Double
  adjacency : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn Sensitivity::new(
  lower : Double,
  upper : Double,
  adjacency : Double,
) -> Sensitivity {
  if lower > upper || adjacency < 0.0 {
    abort("Sensitivity: invalid bounds")
  }
  { lower, upper, adjacency }
}

///|
pub fn Sensitivity::range(self : Sensitivity) -> Double {
  self.upper - self.lower
}

///|
pub fn Sensitivity::mean_sensitivity(self : Sensitivity, count : Int) -> Double {
  if count <= 0 {
    abort("Sensitivity: count must be positive")
  }
  self.range() / count.to_double()
}

///|
pub struct PrivateRelease {
  value : Double
  mechanism : PrivacyMechanism
  epsilon : Double
  delta : Double
  scale : Double
  clipped : Bool
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn clip_value(value : Double, lower : Double, upper : Double) -> Double {
  value.max(lower).min(upper)
}

///|
pub fn clip_values(
  values : Array[Double],
  lower : Double,
  upper : Double,
) -> Array[Double] {
  values.map(fn(value) { clip_value(value, lower, upper) })
}

///|
pub fn noisy_count(
  count : Int,
  sensitivity : Double,
  epsilon : Double,
  noise : Double,
) -> PrivateRelease {
  if sensitivity < 0.0 || epsilon <= 0.0 {
    abort("noisy_count: invalid privacy parameters")
  }
  {
    value: count.to_double() + sensitivity / epsilon * noise,
    mechanism: PrivacyMechanism::Laplace,
    epsilon,
    delta: 0.0,
    scale: sensitivity / epsilon,
    clipped: false,
  }
}

///|
pub fn noisy_sum(
  values : Array[Double],
  sensitivity : Sensitivity,
  epsilon : Double,
  noise : Double,
) -> PrivateRelease {
  if epsilon <= 0.0 {
    abort("noisy_sum: epsilon must be positive")
  }
  let clipped = values.any(fn(value) {
    value < sensitivity.lower || value > sensitivity.upper
  })
  let total = clip_values(values, sensitivity.lower, sensitivity.upper).fold(
    init=0.0,
    (sum_value, value) => sum_value + value,
  )
  let scale = sensitivity.adjacency / epsilon
  {
    value: total + scale * noise,
    mechanism: PrivacyMechanism::Laplace,
    epsilon,
    delta: 0.0,
    scale,
    clipped,
  }
}

///|
pub fn noisy_mean(
  values : Array[Double],
  sensitivity : Sensitivity,
  epsilon : Double,
  noise : Double,
) -> PrivateRelease {
  if values.length() == 0 {
    abort("noisy_mean: values cannot be empty")
  }
  let release = noisy_sum(values, sensitivity, epsilon, noise)
  {
    ..release,
    value: release.value / values.length().to_double(),
    scale: release.scale / values.length().to_double(),
  }
}

///|
pub fn noisy_proportion(
  successes : Int,
  trials : Int,
  epsilon : Double,
  noise : Double,
) -> PrivateRelease {
  if trials <= 0 || successes < 0 || successes > trials || epsilon <= 0.0 {
    abort("noisy_proportion: invalid inputs")
  }
  let scale = 1.0 / trials.to_double() / epsilon
  {
    value: successes.to_double() / trials.to_double() + scale * noise,
    mechanism: PrivacyMechanism::Laplace,
    epsilon,
    delta: 0.0,
    scale,
    clipped: false,
  }
}

///|
pub fn gaussian_release(
  value : Double,
  sensitivity : Double,
  epsilon : Double,
  delta : Double,
  noise : Double,
) -> PrivateRelease {
  if sensitivity < 0.0 || epsilon <= 0.0 || delta <= 0.0 || delta >= 1.0 {
    abort("gaussian_release: invalid parameters")
  }
  let scale = sensitivity * (2.0 * (1.0 / delta).sqrt()) / epsilon
  {
    value: value + scale * noise,
    mechanism: PrivacyMechanism::Gaussian,
    epsilon,
    delta,
    scale,
    clipped: false,
  }
}

///|
pub struct PrivacyReport {
  releases : Int
  epsilon : Double
  delta : Double
  consumed_epsilon : Double
  consumed_delta : Double
  utilization : Double
  exhausted : Bool
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn privacy_report(budget : PrivacyBudget) -> PrivacyReport {
  {
    releases: budget.releases,
    epsilon: budget.epsilon,
    delta: budget.delta,
    consumed_epsilon: budget.consumed_epsilon,
    consumed_delta: budget.consumed_delta,
    utilization: budget.consumed_epsilon / budget.epsilon,
    exhausted: budget.remaining_epsilon() <= 0.0 ||
    budget.remaining_delta() <= 0.0,
  }
}

///|
pub fn compose_budgets(budgets : Array[PrivacyBudget]) -> PrivacyBudget {
  if budgets.length() == 0 {
    abort("compose_budgets: no budgets")
  }
  let epsilon = budgets.fold(init=0.0, (total, budget) => total + budget.epsilon)
  let delta = budgets
    .fold(init=0.0, (total, budget) => total + budget.delta)
    .min(0.999999)
  let consumed_epsilon = budgets.fold(init=0.0, (total, budget) => {
    total + budget.consumed_epsilon
  })
  let consumed_delta = budgets.fold(init=0.0, (total, budget) => {
    total + budget.consumed_delta
  })
  {
    epsilon,
    delta,
    consumed_epsilon,
    consumed_delta,
    releases: budgets.fold(init=0, (total, budget) => total + budget.releases),
  }
}

///|
pub enum RedactionPolicy {
  Suppress
  Bucket
  Round
  Hash
  Keep
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn redact_numeric(
  value : Double,
  policy : RedactionPolicy,
  bucket : Double,
) -> Double {
  match policy {
    RedactionPolicy::Suppress => 0.0
    RedactionPolicy::Bucket =>
      if bucket <= 0.0 {
        abort("redact_numeric: bucket must be positive")
      } else {
        (value / bucket).floor() * bucket
      }
    RedactionPolicy::Round => (value * 100.0).round() / 100.0
    RedactionPolicy::Hash => (value * 2654435761.0).abs() % 1000000.0
    RedactionPolicy::Keep => value
  }
}

///|
pub fn k_anonymity_satisfied(group_sizes : Array[Int], k : Int) -> Bool {
  k > 0 && group_sizes.all(fn(size) { size >= k })
}

///|
pub fn suppress_small_groups(
  values : Array[Double],
  group_sizes : Array[Int],
  k : Int,
) -> Array[Double] {
  if values.length() != group_sizes.length() || k <= 0 {
    abort("suppress_small_groups: invalid inputs")
  }
  values.map(fn(value) { value })
}

///|
pub fn privacy_risk_score(
  unique_count : Int,
  total_count : Int,
  epsilon : Double,
) -> Double {
  if total_count <= 0 || unique_count < 0 || epsilon <= 0.0 {
    abort("privacy_risk_score: invalid inputs")
  }
  (unique_count.to_double() / total_count.to_double() * epsilon).min(1.0)
}

///|
pub fn randomized_response(
  value : Bool,
  probability_truthful : Double,
  random_value : Double,
) -> Bool {
  if probability_truthful < 0.0 ||
    probability_truthful > 1.0 ||
    random_value < 0.0 ||
    random_value >= 1.0 {
    abort("randomized_response: invalid inputs")
  }
  if random_value < probability_truthful {
    value
  } else {
    !value
  }
}

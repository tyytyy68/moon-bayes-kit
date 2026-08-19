///|
/// Distribution records and numerical utilities used by simulation and
/// decision layers. These functions use deterministic approximations so the
/// base package stays small and portable across MoonBit backends.
pub struct EmpiricalDistribution {
  values : Array[Double]
  probabilities : Array[Double]
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn EmpiricalDistribution::new(
  values : Array[Double],
  probabilities : Array[Double],
) -> EmpiricalDistribution {
  if values.length() == 0 || values.length() != probabilities.length() {
    abort("EmpiricalDistribution: invalid support")
  }
  {
    values: values.copy(),
    probabilities: normalize_probabilities(probabilities),
  }
}

///|
pub fn EmpiricalDistribution::uniform(
  values : Array[Double],
) -> EmpiricalDistribution {
  if values.length() == 0 {
    abort("EmpiricalDistribution::uniform: empty support")
  }
  EmpiricalDistribution::new(values, Array::make(values.length(), 1.0))
}

///|
pub fn EmpiricalDistribution::values(
  self : EmpiricalDistribution,
) -> Array[Double] {
  self.values.copy()
}

///|
pub fn EmpiricalDistribution::probabilities(
  self : EmpiricalDistribution,
) -> Array[Double] {
  self.probabilities.copy()
}

///|
pub fn EmpiricalDistribution::mean(self : EmpiricalDistribution) -> Double {
  dot(self.values, self.probabilities)
}

///|
pub fn EmpiricalDistribution::variance(self : EmpiricalDistribution) -> Double {
  let center = self.mean()
  self.values.foldi(init=0.0, fn(index, total, value) {
    total + self.probabilities[index] * (value - center) * (value - center)
  })
}

///|
pub fn EmpiricalDistribution::standard_deviation(
  self : EmpiricalDistribution,
) -> Double {
  self.variance().sqrt()
}

///|
pub fn EmpiricalDistribution::cdf(
  self : EmpiricalDistribution,
  value : Double,
) -> Double {
  let mut result = 0.0
  for index, support in self.values {
    if support <= value {
      result = result + self.probabilities[index]
    }
  }
  result
}

///|
pub fn EmpiricalDistribution::quantile(
  self : EmpiricalDistribution,
  probability : Double,
) -> Double {
  if probability < 0.0 || probability > 1.0 {
    abort("EmpiricalDistribution::quantile: probability out of range")
  }
  let mut cumulative = 0.0
  for index, weight in self.probabilities {
    cumulative = cumulative + weight
    if cumulative >= probability {
      return self.values[index]
    }
  }
  self.values[self.values.length() - 1]
}

///|
pub fn EmpiricalDistribution::entropy(self : EmpiricalDistribution) -> Double {
  self.probabilities.fold(init=0.0, (total, probability) => {
    if probability <= 0.0 {
      total
    } else {
      total - probability * probability.sqrt()
    }
  })
}

///|
pub fn EmpiricalDistribution::map_values(
  self : EmpiricalDistribution,
  transform : (Double) -> Double,
) -> EmpiricalDistribution {
  EmpiricalDistribution::new(self.values.map(transform), self.probabilities)
}

///|
pub fn EmpiricalDistribution::mixture(
  self : EmpiricalDistribution,
  other : EmpiricalDistribution,
  weight : Double,
) -> EmpiricalDistribution {
  if weight < 0.0 || weight > 1.0 {
    abort("EmpiricalDistribution::mixture: weight out of range")
  }
  let values = self.values.copy()
  for value in other.values {
    values.push(value)
  }
  let probabilities = self.probabilities.map(fn(value) { value * weight })
  for probability in other.probabilities {
    probabilities.push(probability * (1.0 - weight))
  }
  EmpiricalDistribution::new(values, probabilities)
}

///|
pub struct BernoulliDistribution {
  probability : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn BernoulliDistribution::new(
  probability : Double,
) -> BernoulliDistribution {
  if probability < 0.0 || probability > 1.0 {
    abort("BernoulliDistribution: probability out of range")
  }
  { probability, }
}

///|
pub fn BernoulliDistribution::probability(
  self : BernoulliDistribution,
) -> Double {
  self.probability
}

///|
pub fn BernoulliDistribution::mean(self : BernoulliDistribution) -> Double {
  self.probability
}

///|
pub fn BernoulliDistribution::variance(self : BernoulliDistribution) -> Double {
  self.probability * (1.0 - self.probability)
}

///|
pub fn BernoulliDistribution::pmf(
  self : BernoulliDistribution,
  success : Bool,
) -> Double {
  if success {
    self.probability
  } else {
    1.0 - self.probability
  }
}

///|
pub fn BernoulliDistribution::log_odds(self : BernoulliDistribution) -> Double {
  if self.probability == 0.0 {
    -1000000.0
  } else if self.probability == 1.0 {
    1000000.0
  } else {
    self.probability / (1.0 - self.probability)
  }
}

///|
pub fn BernoulliDistribution::predictive(
  self : BernoulliDistribution,
  trials : Int,
) -> Array[Double] {
  if trials < 0 {
    abort("BernoulliDistribution::predictive: invalid trials")
  }
  let result = []
  for success in 0..<=trials {
    result.push(self.pmf(success > 0))
  }
  result
}

///|
pub struct UniformDistribution {
  lower : Double
  upper : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn UniformDistribution::new(
  lower : Double,
  upper : Double,
) -> UniformDistribution {
  if lower >= upper {
    abort("UniformDistribution: lower must be smaller than upper")
  }
  { lower, upper }
}

///|
pub fn UniformDistribution::mean(self : UniformDistribution) -> Double {
  (self.lower + self.upper) / 2.0
}

///|
pub fn UniformDistribution::variance(self : UniformDistribution) -> Double {
  let width = self.upper - self.lower
  width * width / 12.0
}

///|
pub fn UniformDistribution::pdf(
  self : UniformDistribution,
  value : Double,
) -> Double {
  if value < self.lower || value > self.upper {
    0.0
  } else {
    1.0 / (self.upper - self.lower)
  }
}

///|
pub fn UniformDistribution::cdf(
  self : UniformDistribution,
  value : Double,
) -> Double {
  if value <= self.lower {
    0.0
  } else if value >= self.upper {
    1.0
  } else {
    (value - self.lower) / (self.upper - self.lower)
  }
}

///|
pub fn UniformDistribution::clamp(
  self : UniformDistribution,
  value : Double,
) -> Double {
  value.max(self.lower).min(self.upper)
}

///|
pub struct ExponentialDistribution {
  rate : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn ExponentialDistribution::new(rate : Double) -> ExponentialDistribution {
  if rate <= 0.0 {
    abort("ExponentialDistribution: rate must be positive")
  }
  { rate, }
}

///|
pub fn ExponentialDistribution::mean(self : ExponentialDistribution) -> Double {
  1.0 / self.rate
}

///|
pub fn ExponentialDistribution::variance(
  self : ExponentialDistribution,
) -> Double {
  1.0 / (self.rate * self.rate)
}

///|
pub fn ExponentialDistribution::pdf(
  self : ExponentialDistribution,
  value : Double,
) -> Double {
  if value < 0.0 {
    0.0
  } else {
    self.rate * @math.pow(2.718281828459045, 0.0 - self.rate * value)
  }
}

///|
pub fn ExponentialDistribution::cdf(
  self : ExponentialDistribution,
  value : Double,
) -> Double {
  if value <= 0.0 {
    0.0
  } else {
    1.0 - @math.pow(2.718281828459045, 0.0 - self.rate * value)
  }
}

///|
pub fn ExponentialDistribution::survival(
  self : ExponentialDistribution,
  value : Double,
) -> Double {
  1.0 - self.cdf(value)
}

///|
pub fn ExponentialDistribution::hazard(
  self : ExponentialDistribution,
  _value : Double,
) -> Double {
  self.rate
}

///|
pub struct GeometricDistribution {
  probability : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn GeometricDistribution::new(
  probability : Double,
) -> GeometricDistribution {
  if probability <= 0.0 || probability > 1.0 {
    abort("GeometricDistribution: probability must be in (0, 1]")
  }
  { probability, }
}

///|
pub fn GeometricDistribution::mean(self : GeometricDistribution) -> Double {
  1.0 / self.probability
}

///|
pub fn GeometricDistribution::variance(self : GeometricDistribution) -> Double {
  (1.0 - self.probability) / (self.probability * self.probability)
}

///|
pub fn GeometricDistribution::pmf(
  self : GeometricDistribution,
  failures : Int,
) -> Double {
  if failures < 0 {
    0.0
  } else {
    @math.pow(1.0 - self.probability, failures.to_double()) * self.probability
  }
}

///|
pub fn GeometricDistribution::cdf(
  self : GeometricDistribution,
  failures : Int,
) -> Double {
  if failures < 0 {
    0.0
  } else {
    1.0 - @math.pow(1.0 - self.probability, (failures + 1).to_double())
  }
}

///|
pub fn GeometricDistribution::quantile(
  self : GeometricDistribution,
  probability : Double,
) -> Int {
  if probability <= 0.0 || probability >= 1.0 {
    abort("GeometricDistribution::quantile: probability must be in (0, 1)")
  }
  let mut failures = 0
  while self.cdf(failures) < probability {
    failures = failures + 1
  }
  failures
}

///|
pub struct PoissonDistribution {
  rate : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn PoissonDistribution::new(rate : Double) -> PoissonDistribution {
  if rate < 0.0 {
    abort("PoissonDistribution: rate must be non-negative")
  }
  { rate, }
}

///|
pub fn PoissonDistribution::mean(self : PoissonDistribution) -> Double {
  self.rate
}

///|
pub fn PoissonDistribution::variance(self : PoissonDistribution) -> Double {
  self.rate
}

///|
pub fn PoissonDistribution::pmf(
  self : PoissonDistribution,
  count : Int,
) -> Double {
  if count < 0 {
    0.0
  } else {
    let mut factorial = 1.0
    for index in 1..<=count {
      factorial = factorial * index.to_double()
    }
    @math.pow(2.718281828459045, 0.0 - self.rate) *
    @math.pow(self.rate, count.to_double()) /
    factorial
  }
}

///|
pub fn PoissonDistribution::cdf(
  self : PoissonDistribution,
  count : Int,
) -> Double {
  if count < 0 {
    0.0
  } else {
    let mut total = 0.0
    for index in 0..<=count {
      total = total + self.pmf(index)
    }
    total.min(1.0)
  }
}

///|
pub fn PoissonDistribution::tail(
  self : PoissonDistribution,
  count : Int,
) -> Double {
  1.0 - self.cdf(count)
}

///|
pub struct NegativeBinomialDistribution {
  successes : Int
  probability : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn NegativeBinomialDistribution::new(
  successes : Int,
  probability : Double,
) -> NegativeBinomialDistribution {
  if successes <= 0 || probability <= 0.0 || probability > 1.0 {
    abort("NegativeBinomialDistribution: invalid parameters")
  }
  { successes, probability }
}

///|
pub fn NegativeBinomialDistribution::mean(
  self : NegativeBinomialDistribution,
) -> Double {
  self.successes.to_double() * (1.0 - self.probability) / self.probability
}

///|
pub fn NegativeBinomialDistribution::variance(
  self : NegativeBinomialDistribution,
) -> Double {
  self.successes.to_double() *
  (1.0 - self.probability) /
  (self.probability * self.probability)
}

///|
pub fn NegativeBinomialDistribution::pmf(
  self : NegativeBinomialDistribution,
  failures : Int,
) -> Double {
  if failures < 0 {
    0.0
  } else {
    let mut combinations = 1.0
    for index in 1..<=failures {
      combinations = combinations *
        (self.successes + index - 1).to_double() /
        index.to_double()
    }
    combinations *
    @math.pow(self.probability, self.successes.to_double()) *
    @math.pow(1.0 - self.probability, failures.to_double())
  }
}

///|
pub fn NegativeBinomialDistribution::cdf(
  self : NegativeBinomialDistribution,
  failures : Int,
) -> Double {
  if failures < 0 {
    0.0
  } else {
    let mut total = 0.0
    for index in 0..<=failures {
      total = total + self.pmf(index)
    }
    total.min(1.0)
  }
}

///|
pub fn NegativeBinomialDistribution::quantile(
  self : NegativeBinomialDistribution,
  probability : Double,
) -> Int {
  if probability <= 0.0 || probability >= 1.0 {
    abort(
      "NegativeBinomialDistribution::quantile: probability must be in (0, 1)",
    )
  }
  let mut index = 0
  while self.cdf(index) < probability {
    index = index + 1
  }
  index
}

///|
pub fn distribution_mean(
  values : Array[Double],
  probabilities : Array[Double],
) -> Double {
  EmpiricalDistribution::new(values, probabilities).mean()
}

///|
pub fn distribution_variance(
  values : Array[Double],
  probabilities : Array[Double],
) -> Double {
  EmpiricalDistribution::new(values, probabilities).variance()
}

///|
pub fn distribution_cdf(
  values : Array[Double],
  probabilities : Array[Double],
  value : Double,
) -> Double {
  EmpiricalDistribution::new(values, probabilities).cdf(value)
}

///|
pub fn distribution_quantile(
  values : Array[Double],
  probabilities : Array[Double],
  probability : Double,
) -> Double {
  EmpiricalDistribution::new(values, probabilities).quantile(probability)
}

///|
pub fn kl_divergence(left : Array[Double], right : Array[Double]) -> Double {
  if left.length() != right.length() || left.length() == 0 {
    abort("kl_divergence: distributions must have equal non-empty length")
  }
  let p = normalize_probabilities(left)
  let q = normalize_probabilities(right)
  let mut result = 0.0
  for index in 0..<p.length() {
    if p[index] > 0.0 && q[index] > 0.0 {
      result = result + p[index] * (p[index] / q[index])
    }
  }
  result
}

///|
pub fn js_divergence(left : Array[Double], right : Array[Double]) -> Double {
  if left.length() != right.length() {
    abort("js_divergence: lengths must match")
  }
  let p = normalize_probabilities(left)
  let q = normalize_probabilities(right)
  let midpoint = p.mapi(fn(index, value) { (value + q[index]) / 2.0 })
  (kl_divergence(p, midpoint) + kl_divergence(q, midpoint)) / 2.0
}

///|
pub fn total_variation(left : Array[Double], right : Array[Double]) -> Double {
  if left.length() != right.length() {
    abort("total_variation: lengths must match")
  }
  let p = normalize_probabilities(left)
  let q = normalize_probabilities(right)
  let mut result = 0.0
  for index in 0..<p.length() {
    result = result + (p[index] - q[index]).abs()
  }
  result / 2.0
}

///|
pub fn hellinger_distance(
  left : Array[Double],
  right : Array[Double],
) -> Double {
  if left.length() != right.length() {
    abort("hellinger_distance: lengths must match")
  }
  let p = normalize_probabilities(left)
  let q = normalize_probabilities(right)
  let mut result = 0.0
  for index in 0..<p.length() {
    let delta = p[index].sqrt() - q[index].sqrt()
    result = result + delta * delta
  }
  result.sqrt() / 2.0.sqrt()
}

///|
pub fn entropy_from_probabilities(probabilities : Array[Double]) -> Double {
  normalize_probabilities(probabilities).fold(init=0.0, (total, value) => {
    if value <= 0.0 {
      total
    } else {
      total - value * value.sqrt()
    }
  })
}

///|
pub fn gini_from_probabilities(probabilities : Array[Double]) -> Double {
  let normalized = normalize_probabilities(probabilities)
  1.0 - normalized.fold(init=0.0, (total, value) => total + value * value)
}

///|
pub fn perplexity(probabilities : Array[Double]) -> Double {
  let entropy = entropy_from_probabilities(probabilities)
  @math.pow(2.718281828459045, entropy)
}

///|
pub fn posterior_predictive_check(
  observed : Array[Double],
  simulated : Array[Array[Double]],
  statistic : (Array[Double]) -> Double,
) -> Double {
  if simulated.length() == 0 {
    abort("posterior_predictive_check: simulations required")
  }
  let target = statistic(observed)
  let mut exceed = 0
  for sample in simulated {
    if statistic(sample) >= target {
      exceed = exceed + 1
    }
  }
  exceed.to_double() / simulated.length().to_double()
}

///|
pub fn empirical_quantile(
  values : Array[Double],
  probability : Double,
) -> Double {
  quantile(values, probability)
}

///|
pub fn empirical_cdf(values : Array[Double], value : Double) -> Double {
  if values.length() == 0 {
    abort("empirical_cdf: values must not be empty")
  }
  values
  .fold(init=0, (count, item) => if item <= value { count + 1 } else { count })
  .to_double() /
  values.length().to_double()
}

///|
pub fn bootstrap_distribution(
  rng : DeterministicRng,
  values : Array[Double],
  replicates : Int,
) -> (DeterministicRng, Array[Double]) {
  if values.length() == 0 || replicates <= 0 {
    abort("bootstrap_distribution: invalid inputs")
  }
  let result = Array::make(replicates, 0.0)
  let mut current = rng
  for index in 0..<replicates {
    let (next, selected) = bootstrap_indices(
      current,
      values.length(),
      values.length(),
    )
    current = next
    result[index] = mean(selected.map(fn(item) { values[item] }))
  }
  (current, result)
}

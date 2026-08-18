///|
/// Returns the Beta-Binomial predictive probability mass function for k successes.
/// The recurrence avoids factorial overflow and is suitable for small decision
/// windows such as A/B tests and capacity planning.
pub fn BetaBinomial::predictive_probability(
  self : BetaBinomial,
  successes : Int,
  trials : Int,
) -> Double {
  if trials < 0 || successes < 0 || successes > trials {
    abort("BetaBinomial::predictive_probability: invalid counts")
  }
  let mut probability = beta_ratio(self.alpha, self.beta, trials)
  for index in 0..<successes {
    probability = probability *
      (self.alpha + index.to_double()) /
      (self.beta + trials.to_double() - index.to_double() - 1.0)
  }
  // Choose the combinatorial term using a multiplicative recurrence.
  let mut combinations = 1.0
  for index in 1..<=successes {
    combinations = combinations *
      (trials - index + 1).to_double() /
      index.to_double()
  }
  combinations * probability
}

///|
fn beta_ratio(alpha : Double, beta : Double, trials : Int) -> Double {
  let mut result = 1.0
  for index in 0..<trials {
    result = result *
      (beta + index.to_double()) /
      (alpha + beta + index.to_double())
  }
  result
}

///|
pub fn BetaBinomial::predictive_distribution(
  self : BetaBinomial,
  trials : Int,
) -> Array[Double] {
  if trials < 0 {
    abort("BetaBinomial::predictive_distribution: trials must be non-negative")
  }
  let result = []
  for successes in 0..<=trials {
    result.push(self.predictive_probability(successes, trials))
  }
  normalize_probabilities(result)
}

///|
pub fn BetaBinomial::predictive_quantile(
  self : BetaBinomial,
  trials : Int,
  probability : Double,
) -> Int {
  if probability < 0.0 || probability > 1.0 {
    abort("BetaBinomial::predictive_quantile: probability must be in [0, 1]")
  }
  let distribution = self.predictive_distribution(trials)
  let mut cumulative = 0.0
  for index in 0..<distribution.length() {
    cumulative = cumulative + distribution[index]
    if cumulative >= probability {
      return index
    }
  }
  trials
}

///|
/// Negative-binomial predictive mass for a Gamma-Poisson posterior.
pub fn GammaPoisson::predictive_probability(
  self : GammaPoisson,
  count : Int,
) -> Double {
  if count < 0 {
    abort("GammaPoisson::predictive_probability: count must be non-negative")
  }
  let mut probability = @math.pow(self.rate / (self.rate + 1.0), self.shape)
  for index in 0..<count {
    probability = probability *
      (self.shape + index.to_double()) /
      (index + 1).to_double() /
      (self.rate + 1.0)
  }
  probability
}

///|
pub fn GammaPoisson::predictive_distribution(
  self : GammaPoisson,
  maximum_count : Int,
) -> Array[Double] {
  if maximum_count < 0 {
    abort(
      "GammaPoisson::predictive_distribution: maximum_count must be non-negative",
    )
  }
  let result = []
  for count in 0..<=maximum_count {
    result.push(self.predictive_probability(count))
  }
  result
}

///|
pub fn GammaPoisson::predictive_cdf(
  self : GammaPoisson,
  maximum_count : Int,
) -> Double {
  self
  .predictive_distribution(maximum_count)
  .fold(init=0.0, (total, probability) => total + probability)
}

///|
pub fn DirichletMultinomial::predictive_probability(
  self : DirichletMultinomial,
  category : Int,
) -> Double {
  if category < 0 || category >= self.alpha.length() {
    abort("DirichletMultinomial::predictive_probability: category out of range")
  }
  self.alpha[category] / self.total_concentration()
}

///|
pub fn DirichletMultinomial::predictive_distribution(
  self : DirichletMultinomial,
) -> Array[Double] {
  self.alpha.map(fn(value) { value / self.total_concentration() })
}

///|
pub fn DirichletMultinomial::sample_without_randomness(
  self : DirichletMultinomial,
  observations : Int,
) -> Array[Int] {
  // Largest-remainder allocation is deterministic and useful in reproducible
  // simulations where a random generator is intentionally not a dependency.
  if observations < 0 {
    abort("sample_without_randomness: observations must be non-negative")
  }
  let probabilities = self.predictive_distribution()
  let result = probabilities.map(fn(value) {
    (value * observations.to_double()).floor().to_int()
  })
  let mut assigned = sum_int(result)
  let mut index = 0
  while assigned < observations {
    result[index % result.length()] = result[index % result.length()] + 1
    assigned = assigned + 1
    index = index + 1
  }
  result
}

///|
fn sum_int(values : Array[Int]) -> Int {
  values.fold(init=0, (total, value) => total + value)
}

///|
pub fn NormalNormal::standardized(
  self : NormalNormal,
  value : Double,
) -> Double {
  (value - self.posterior_mean()) / self.posterior_variance().sqrt()
}

///|
pub fn NormalNormal::interval_probability_approx(
  self : NormalNormal,
  lower : Double,
  upper : Double,
) -> Double {
  if lower > upper {
    abort("interval_probability_approx: lower must not exceed upper")
  }
  let width = upper - lower
  let scale = self.posterior_predictive_variance().sqrt()
  if scale == 0.0 {
    if lower <= self.posterior_predictive_mean() &&
      self.posterior_predictive_mean() <= upper {
      1.0
    } else {
      0.0
    }
  } else {
    clamp(width / (2.506628 * scale), 0.0, 1.0)
  }
}

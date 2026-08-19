///|
/// Reproducible Monte Carlo, importance sampling, and chain diagnostics.
pub struct MonteCarloEstimate {
  estimate : Double
  standard_error : Double
  lower_95 : Double
  upper_95 : Double
  samples : Int
  effective_sample_size : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn MonteCarloEstimate::relative_error(self : MonteCarloEstimate) -> Double {
  if self.estimate == 0.0 {
    self.standard_error
  } else {
    self.standard_error / self.estimate.abs()
  }
}

///|
pub fn MonteCarloEstimate::precise(
  self : MonteCarloEstimate,
  tolerance : Double,
) -> Bool {
  self.relative_error() <= tolerance
}

///|
pub struct MonteCarloAccumulator {
  count : Int
  mean : Double
  m2 : Double
  weight_sum : Double
  weight_square_sum : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn MonteCarloAccumulator::new() -> MonteCarloAccumulator {
  { count: 0, mean: 0.0, m2: 0.0, weight_sum: 0.0, weight_square_sum: 0.0 }
}

///|
pub fn MonteCarloAccumulator::push(
  self : MonteCarloAccumulator,
  value : Double,
) -> MonteCarloAccumulator {
  let count = self.count + 1
  let delta = value - self.mean
  let mean = self.mean + delta / count.to_double()
  {
    count,
    mean,
    m2: self.m2 + delta * (value - mean),
    weight_sum: self.weight_sum + 1.0,
    weight_square_sum: self.weight_square_sum + 1.0,
  }
}

///|
pub fn MonteCarloAccumulator::push_weighted(
  self : MonteCarloAccumulator,
  value : Double,
  weight : Double,
) -> MonteCarloAccumulator {
  if weight < 0.0 {
    abort("MonteCarloAccumulator: weight must be non-negative")
  }
  let weight_sum = self.weight_sum + weight
  if weight_sum == 0.0 {
    self
  } else {
    let delta = value - self.mean
    let mean = self.mean + weight * delta / weight_sum
    {
      count: self.count + 1,
      mean,
      m2: self.m2 + weight * delta * (value - mean),
      weight_sum,
      weight_square_sum: self.weight_square_sum + weight * weight,
    }
  }
}

///|
pub fn MonteCarloAccumulator::variance(self : MonteCarloAccumulator) -> Double {
  if self.weight_sum == 0.0 {
    0.0
  } else {
    self.m2 / self.weight_sum
  }
}

///|
pub fn MonteCarloAccumulator::effective_sample_size(
  self : MonteCarloAccumulator,
) -> Double {
  if self.weight_square_sum == 0.0 {
    0.0
  } else {
    self.weight_sum * self.weight_sum / self.weight_square_sum
  }
}

///|
pub fn MonteCarloAccumulator::estimate(
  self : MonteCarloAccumulator,
  confidence : Double,
) -> MonteCarloEstimate {
  if self.count == 0 || confidence <= 0.0 || confidence >= 1.0 {
    abort("MonteCarloAccumulator::estimate: invalid inputs")
  }
  let standard_error = (self.variance() / self.effective_sample_size().max(1.0)).sqrt()
  let margin = normal_quantile((1.0 + confidence) / 2.0) * standard_error
  {
    estimate: self.mean,
    standard_error,
    lower_95: self.mean - margin,
    upper_95: self.mean + margin,
    samples: self.count,
    effective_sample_size: self.effective_sample_size(),
  }
}

///|
pub fn monte_carlo(
  rng : DeterministicRng,
  samples : Int,
  sampler : (DeterministicRng) -> (DeterministicRng, Double),
  statistic : (Double) -> Double,
) -> (DeterministicRng, MonteCarloEstimate) {
  if samples <= 1 {
    abort("monte_carlo: at least two samples required")
  }
  let mut current = rng
  let mut accumulator = MonteCarloAccumulator::new()
  for _ in 0..<samples {
    let (next, value) = sampler(current)
    current = next
    accumulator = accumulator.push(statistic(value))
  }
  (current, accumulator.estimate(0.95))
}

///|
pub fn integrate_uniform(
  rng : DeterministicRng,
  lower : Double,
  upper : Double,
  samples : Int,
  function : (Double) -> Double,
) -> (DeterministicRng, MonteCarloEstimate) {
  if lower >= upper {
    abort("integrate_uniform: invalid interval")
  }
  let sampler = fn(current : DeterministicRng) {
    let (next, value) = current.uniform()
    (next, lower + (upper - lower) * value)
  }
  let (next, estimate) = monte_carlo(rng, samples, sampler, function)
  (
    next,
    {
      ..estimate,
      estimate: estimate.estimate * (upper - lower),
      lower_95: estimate.lower_95 * (upper - lower),
      upper_95: estimate.upper_95 * (upper - lower),
    },
  )
}

///|
pub fn estimate_probability(
  rng : DeterministicRng,
  samples : Int,
  event : (Double) -> Bool,
) -> (DeterministicRng, MonteCarloEstimate) {
  let sampler = fn(current : DeterministicRng) { current.uniform() }
  let statistic = fn(value : Double) { if event(value) { 1.0 } else { 0.0 } }
  monte_carlo(rng, samples, sampler, statistic)
}

///|
pub struct ImportanceSample {
  value : Double
  log_weight : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn importance_estimate(
  samples : Array[ImportanceSample],
  function : (Double) -> Double,
) -> MonteCarloEstimate {
  if samples.length() < 2 {
    abort("importance_estimate: at least two samples required")
  }
  let mut maximum = samples[0].log_weight
  for sample in samples.iter() {
    maximum = maximum.max(sample.log_weight)
  }
  let weights = samples.map(fn(sample) {
    @math.exp(sample.log_weight - maximum)
  })
  let normalizer = weights.fold(init=0.0, (total, weight) => total + weight)
  let effective = normalizer *
    normalizer /
    weights.fold(init=0.0, (total, weight) => total + weight * weight)
  let mut estimate = 0.0
  for index in 0..<samples.length() {
    estimate = estimate + weights[index] * function(samples[index].value)
  }
  estimate = estimate / normalizer
  let mut variance_value = 0.0
  for index in 0..<samples.length() {
    let delta = function(samples[index].value) - estimate
    variance_value = variance_value + weights[index] * delta * delta
  }
  let standard_error = (variance_value / normalizer / effective.max(1.0)).sqrt()
  {
    estimate,
    standard_error,
    lower_95: estimate - 1.96 * standard_error,
    upper_95: estimate + 1.96 * standard_error,
    samples: samples.length(),
    effective_sample_size: effective,
  }
}

///|
pub struct MarkovChainState {
  value : Double
  accepted : Int
  proposals : Int
  samples : Array[Double]
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn MarkovChainState::new(initial : Double) -> MarkovChainState {
  { value: initial, accepted: 0, proposals: 0, samples: [] }
}

///|
pub fn MarkovChainState::acceptance_rate(self : MarkovChainState) -> Double {
  if self.proposals == 0 {
    0.0
  } else {
    self.accepted.to_double() / self.proposals.to_double()
  }
}

///|
pub fn metropolis_step(
  state : MarkovChainState,
  rng : DeterministicRng,
  proposal_scale : Double,
  log_density : (Double) -> Double,
) -> (MarkovChainState, DeterministicRng) {
  if proposal_scale <= 0.0 {
    abort("metropolis_step: proposal scale must be positive")
  }
  let (next_rng, first) = rng.uniform()
  let proposal = state.value + (first - 0.5) * 2.0 * proposal_scale
  let log_ratio = log_density(proposal) - log_density(state.value)
  let (final_rng, second) = next_rng.uniform()
  let accepted = log_ratio >= 0.0 ||
    uncertainty_log(second.max(0.000000000001)) < log_ratio
  let value = if accepted { proposal } else { state.value }
  let accepted_increment = if accepted { 1 } else { 0 }
  let samples = state.samples.copy()
  samples.push(value)
  (
    {
      value,
      accepted: state.accepted + accepted_increment,
      proposals: state.proposals + 1,
      samples,
    },
    final_rng,
  )
}

///|
pub fn metropolis(
  rng : DeterministicRng,
  initial : Double,
  iterations : Int,
  burn_in : Int,
  proposal_scale : Double,
  log_density : (Double) -> Double,
) -> (DeterministicRng, MarkovChainState) {
  if iterations <= 0 || burn_in < 0 || burn_in >= iterations {
    abort("metropolis: invalid iterations")
  }
  let mut current_rng = rng
  let mut state = MarkovChainState::new(initial)
  for iteration in 0..<iterations {
    let (next_state, next_rng) = metropolis_step(
      state, current_rng, proposal_scale, log_density,
    )
    current_rng = next_rng
    state = if iteration < burn_in {
      { ..next_state, samples: [] }
    } else {
      next_state
    }
  }
  (current_rng, state)
}

///|
pub fn chain_autocorrelation(samples : Array[Double], lag : Int) -> Double {
  if samples.length() <= lag || lag < 0 {
    abort("autocorrelation: invalid lag")
  }
  let center = mean(samples)
  let mut denominator = 0.0
  let mut numerator = 0.0
  for index in 0..<samples.length() {
    let delta = samples[index] - center
    denominator = denominator + delta * delta
  }
  for index in lag..<samples.length() {
    numerator = numerator +
      (samples[index] - center) * (samples[index - lag] - center)
  }
  if denominator == 0.0 {
    0.0
  } else {
    numerator / denominator
  }
}

///|
pub fn effective_sample_size(
  samples : Array[Double],
  maximum_lag : Int,
) -> Double {
  if samples.length() < 2 || maximum_lag < 1 {
    abort("effective_sample_size: invalid inputs")
  }
  let mut sum_autocorrelation = 0.0
  for lag in 1..<=maximum_lag.min(samples.length() - 1) {
    let correlation = chain_autocorrelation(samples, lag)
    if correlation <= 0.0 {
      break
    }
    sum_autocorrelation = sum_autocorrelation + correlation
  }
  samples.length().to_double() / (1.0 + 2.0 * sum_autocorrelation)
}

///|
pub struct ChainDiagnostics {
  samples : Int
  acceptance_rate : Double
  effective_sample_size : Double
  mean : Double
  variance : Double
  rhat : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn chain_diagnostics(
  chains : Array[Array[Double]],
  maximum_lag : Int,
) -> ChainDiagnostics {
  if chains.length() == 0 || chains[0].length() < 2 {
    abort("chain_diagnostics: empty chains")
  }
  let flattened : Array[Double] = []
  for chain in chains {
    for value in chain {
      flattened.push(value)
    }
  }
  let within = chains.fold(init=0.0, (total, chain) => total + variance(chain)) /
    chains.length().to_double()
  let means = chains.map(mean)
  let between = variance(means) * chains[0].length().to_double()
  let rhat = if within == 0.0 {
    1.0
  } else {
    ((within + between / chains.length().to_double()) / within).sqrt()
  }
  {
    samples: flattened.length(),
    acceptance_rate: 0.0,
    effective_sample_size: effective_sample_size(flattened, maximum_lag),
    mean: mean(flattened),
    variance: variance(flattened),
    rhat,
  }
}

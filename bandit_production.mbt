///|
/// Contextual bandit policies, regret accounting, and offline evaluation.
pub struct BanditArm {
  name : String
  pulls : Int
  reward_sum : Double
  reward_square_sum : Double
  prior_mean : Double
  prior_strength : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn BanditArm::new(
  name : String,
  prior_mean : Double,
  prior_strength : Double,
) -> BanditArm {
  if prior_strength <= 0.0 {
    abort("BanditArm: prior strength must be positive")
  }
  {
    name,
    pulls: 0,
    reward_sum: 0.0,
    reward_square_sum: 0.0,
    prior_mean,
    prior_strength,
  }
}

///|
pub fn BanditArm::observe(self : BanditArm, reward : Double) -> BanditArm {
  {
    ..self,
    pulls: self.pulls + 1,
    reward_sum: self.reward_sum + reward,
    reward_square_sum: self.reward_square_sum + reward * reward,
  }
}

///|
pub fn BanditArm::mean(self : BanditArm) -> Double {
  (self.reward_sum + self.prior_mean * self.prior_strength) /
  (self.pulls.to_double() + self.prior_strength)
}

///|
pub fn BanditArm::variance(self : BanditArm) -> Double {
  if self.pulls < 2 {
    0.25
  } else {
    (self.reward_square_sum / self.pulls.to_double() -
    self.reward_sum /
    self.pulls.to_double() *
    (self.reward_sum / self.pulls.to_double())).max(0.000000000001)
  }
}

///|
pub fn BanditArm::uncertainty(self : BanditArm) -> Double {
  (self.variance() / (self.pulls + 1).to_double()).sqrt()
}

///|
pub struct BanditContext {
  features : Array[Double]
  arms : Array[BanditArm]
  time : Int
  total_reward : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn BanditContext::new(arms : Array[BanditArm]) -> BanditContext {
  if arms.length() == 0 {
    abort("BanditContext: at least one arm")
  }
  { features: [], arms, time: 0, total_reward: 0.0 }
}

///|
pub fn BanditContext::set_features(
  self : BanditContext,
  features : Array[Double],
) -> BanditContext {
  { ..self, features, }
}

///|
pub fn BanditContext::observe(
  self : BanditContext,
  arm : Int,
  reward : Double,
) -> BanditContext {
  if arm < 0 || arm >= self.arms.length() {
    abort("BanditContext: arm out of range")
  }
  let arms = self.arms.copy()
  arms[arm] = arms[arm].observe(reward)
  {
    ..self,
    arms,
    time: self.time + 1,
    total_reward: self.total_reward + reward,
  }
}

///|
pub fn select_epsilon_greedy(
  context : BanditContext,
  epsilon : Double,
  random_value : Double,
) -> Int {
  if epsilon < 0.0 || epsilon > 1.0 || random_value < 0.0 || random_value >= 1.0 {
    abort("select_epsilon_greedy: invalid inputs")
  }
  if random_value < epsilon {
    (random_value / epsilon * context.arms.length().to_double())
    .floor()
    .to_int()
    .min(context.arms.length() - 1)
  } else {
    argmax_arms(context.arms, fn(arm) { arm.mean() })
  }
}

///|
pub fn select_ucb(context : BanditContext, exploration : Double) -> Int {
  if exploration < 0.0 {
    abort("select_ucb: exploration must be non-negative")
  }
  let mut best = 0
  let mut best_score = -1.0 / 0.0
  for index in 0..<context.arms.length() {
    let arm = context.arms[index]
    let score = if arm.pulls == 0 {
      1.0 / 0.0
    } else {
      arm.mean() +
      exploration *
      (context.time.max(1).to_double() / arm.pulls.to_double()).sqrt()
    }
    if score > best_score {
      best_score = score
      best = index
    }
  }
  best
}

///|
pub fn select_thompson(
  context : BanditContext,
  random_values : Array[Double],
) -> Int {
  if random_values.length() != context.arms.length() {
    abort("select_thompson: random values must match arms")
  }
  let samples : Array[Double] = []
  for index in 0..<context.arms.length() {
    let arm = context.arms[index]
    samples.push(
      arm.mean() + (random_values[index] - 0.5) * 2.0 * arm.uncertainty(),
    )
  }
  let mut best = 0
  for index in 1..<samples.length() {
    if samples[index] > samples[best] {
      best = index
    }
  }
  best
}

///|
fn argmax_arms(arms : Array[BanditArm], score : (BanditArm) -> Double) -> Int {
  let mut best = 0
  for index in 1..<arms.length() {
    if score(arms[index]) > score(arms[best]) {
      best = index
    }
  }
  best
}

///|
pub struct RegretPoint {
  time : Int
  chosen : Int
  reward : Double
  best_expected : Double
  instantaneous : Double
  cumulative : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub struct RegretLedger {
  points : Array[RegretPoint]
  cumulative : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn RegretLedger::new() -> RegretLedger {
  { points: [], cumulative: 0.0 }
}

///|
pub fn RegretLedger::record(
  self : RegretLedger,
  chosen : Int,
  reward : Double,
  arm_means : Array[Double],
) -> RegretLedger {
  if arm_means.length() == 0 {
    abort("RegretLedger: arm means cannot be empty")
  }
  let best = arm_means.fold(init=arm_means[0], (current, value) => {
    current.max(value)
  })
  let instantaneous = best - reward
  let cumulative = self.cumulative + instantaneous
  let points = self.points.copy()
  points.push({
    time: points.length(),
    chosen,
    reward,
    best_expected: best,
    instantaneous,
    cumulative,
  })
  { points, cumulative }
}

///|
pub fn RegretLedger::average_regret(self : RegretLedger) -> Double {
  if self.points.length() == 0 {
    0.0
  } else {
    self.cumulative / self.points.length().to_double()
  }
}

///|
pub fn RegretLedger::max_drawdown(self : RegretLedger) -> Double {
  let mut peak = 0.0
  let mut drawdown = 0.0
  for point in self.points.iter() {
    peak = peak.max(point.cumulative)
    drawdown = drawdown.max(peak - point.cumulative)
  }
  drawdown
}

///|
pub fn off_policy_value(
  rewards : Array[Double],
  actions : Array[Int],
  target_probabilities : Array[Double],
  logging_probabilities : Array[Double],
) -> Double {
  if rewards.length() != actions.length() ||
    rewards.length() != target_probabilities.length() ||
    rewards.length() != logging_probabilities.length() ||
    rewards.length() == 0 {
    abort("off_policy_value: lengths must match")
  }
  let mut total = 0.0
  for index in 0..<rewards.length() {
    if logging_probabilities[index] <= 0.0 {
      abort("off_policy_value: logging probability must be positive")
    }
    total = total +
      rewards[index] *
      target_probabilities[index] /
      logging_probabilities[index]
  }
  total / rewards.length().to_double()
}

///|
pub fn self_normalized_off_policy_value(
  rewards : Array[Double],
  target_probabilities : Array[Double],
  logging_probabilities : Array[Double],
) -> Double {
  if rewards.length() != target_probabilities.length() ||
    rewards.length() != logging_probabilities.length() ||
    rewards.length() == 0 {
    abort("self_normalized_off_policy_value: lengths must match")
  }
  let mut weighted = 0.0
  let mut total_weight = 0.0
  for index in 0..<rewards.length() {
    let weight = target_probabilities[index] /
      logging_probabilities[index].max(0.000000000001)
    weighted = weighted + rewards[index] * weight
    total_weight = total_weight + weight
  }
  weighted / total_weight
}

///|
pub struct BanditEvaluation {
  value : Double
  standard_error : Double
  lower_95 : Double
  upper_95 : Double
  effective_sample_size : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn evaluate_policy(
  rewards : Array[Double],
  weights : Array[Double],
) -> BanditEvaluation {
  if rewards.length() != weights.length() || rewards.length() == 0 {
    abort("evaluate_policy: lengths must match")
  }
  let total_weight = weights.fold(init=0.0, (total, value) => total + value)
  let value = rewards.fold(init=0.0, (total, reward) => total + reward) /
    rewards.length().to_double()
  let weighted_variance = variance(rewards)
  let effective = total_weight *
    total_weight /
    weights
    .fold(init=0.0, (total, weight) => total + weight * weight)
    .max(0.000000000001)
  let error = (weighted_variance / effective.max(1.0)).sqrt()
  {
    value,
    standard_error: error,
    lower_95: value - 1.96 * error,
    upper_95: value + 1.96 * error,
    effective_sample_size: effective,
  }
}

///|
pub struct PolicyAction {
  arm : Int
  probability : Double
  expected_reward : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn policy_distribution(
  context : BanditContext,
  temperature : Double,
) -> Array[PolicyAction] {
  if temperature <= 0.0 {
    abort("policy_distribution: temperature must be positive")
  }
  let scores = context.arms.map(fn(arm) { arm.mean() / temperature })
  let maximum = scores.fold(init=scores[0], (current, value) => {
    current.max(value)
  })
  let exponents = scores.map(fn(value) { @math.exp(value - maximum) })
  let total = exponents.fold(init=0.0, (sum_value, value) => sum_value + value)
  let result : Array[PolicyAction] = []
  for index in 0..<scores.length() {
    result.push({
      arm: index,
      probability: exponents[index] / total,
      expected_reward: context.arms[index].mean(),
    })
  }
  result
}

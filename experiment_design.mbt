///|
/// Sequential experimentation and uplift analysis utilities.
pub enum AssignmentMethod {
  FixedRatio
  EpsilonGreedy
  Stratified
  Blocked
} derive(Debug, Eq, ToJson, FromJson)

///|
pub struct ExperimentArm {
  name : String
  observations : Int
  successes : Int
  sum : Double
  sum_squared : Double
  cost : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn ExperimentArm::new(name : String) -> ExperimentArm {
  { name, observations: 0, successes: 0, sum: 0.0, sum_squared: 0.0, cost: 0.0 }
}

///|
pub fn ExperimentArm::record(
  self : ExperimentArm,
  value : Double,
) -> ExperimentArm {
  let success = if value > 0.5 { 1 } else { 0 }
  {
    ..self,
    observations: self.observations + 1,
    successes: self.successes + success,
    sum: self.sum + value,
    sum_squared: self.sum_squared + value * value,
  }
}

///|
pub fn ExperimentArm::record_cost(
  self : ExperimentArm,
  value : Double,
  cost : Double,
) -> ExperimentArm {
  if cost < 0.0 {
    abort("ExperimentArm: cost must be non-negative")
  }
  { ..self.record(value), cost: self.cost + cost }
}

///|
pub fn ExperimentArm::count(self : ExperimentArm) -> Int {
  self.observations
}

///|
pub fn ExperimentArm::mean(self : ExperimentArm) -> Double {
  if self.observations == 0 {
    0.0
  } else {
    self.sum / self.observations.to_double()
  }
}

///|
pub fn ExperimentArm::variance(self : ExperimentArm) -> Double {
  if self.observations < 2 {
    0.0
  } else {
    ((self.sum_squared - self.sum * self.sum / self.observations.to_double()) /
    (self.observations - 1).to_double()).max(0.0)
  }
}

///|
pub fn ExperimentArm::rate(self : ExperimentArm) -> Double {
  if self.observations == 0 {
    0.0
  } else {
    self.successes.to_double() / self.observations.to_double()
  }
}

///|
pub fn ExperimentArm::standard_error(self : ExperimentArm) -> Double {
  if self.observations == 0 {
    0.0
  } else {
    (self.variance() / self.observations.to_double()).sqrt()
  }
}

///|
pub fn ExperimentArm::average_cost(self : ExperimentArm) -> Double {
  if self.observations == 0 {
    0.0
  } else {
    self.cost / self.observations.to_double()
  }
}

///|
pub struct EffectEstimate {
  control : String
  treatment : String
  difference : Double
  relative : Double
  standard_error : Double
  lower_95 : Double
  upper_95 : Double
  probability_positive : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn EffectEstimate::significant(self : EffectEstimate) -> Bool {
  self.lower_95 > 0.0 || self.upper_95 < 0.0
}

///|
pub fn EffectEstimate::lift(self : EffectEstimate) -> Double {
  self.relative
}

///|
pub fn compare_arms(
  control : ExperimentArm,
  treatment : ExperimentArm,
) -> EffectEstimate {
  let difference = treatment.mean() - control.mean()
  let error = (control.standard_error() * control.standard_error() +
  treatment.standard_error() * treatment.standard_error()).sqrt()
  let margin = 1.96 * error
  let relative = if control.mean() == 0.0 {
    0.0
  } else {
    difference / control.mean()
  }
  let probability = if error == 0.0 {
    if difference > 0.0 {
      1.0
    } else if difference < 0.0 {
      0.0
    } else {
      0.5
    }
  } else {
    normal_cdf(difference / error)
  }
  {
    control: control.name,
    treatment: treatment.name,
    difference,
    relative,
    standard_error: error,
    lower_95: difference - margin,
    upper_95: difference + margin,
    probability_positive: probability,
  }
}

///|
pub struct SequentialBoundary {
  looks : Int
  alpha : Double
  spending : Array[Double]
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn SequentialBoundary::new(
  looks : Int,
  alpha : Double,
) -> SequentialBoundary {
  if looks <= 0 || alpha <= 0.0 || alpha >= 1.0 {
    abort("SequentialBoundary: invalid parameters")
  }
  let spending : Array[Double] = []
  for look in 1..<=looks {
    spending.push(alpha * look.to_double() / looks.to_double())
  }
  { looks, alpha, spending }
}

///|
pub fn SequentialBoundary::critical_z(
  self : SequentialBoundary,
  look : Int,
) -> Double {
  if look <= 0 || look > self.looks {
    abort("SequentialBoundary: look out of range")
  }
  normal_quantile(1.0 - self.spending[look - 1] / 2.0)
}

///|
pub fn SequentialBoundary::can_stop(
  self : SequentialBoundary,
  estimate : EffectEstimate,
  look : Int,
) -> Bool {
  let z = if estimate.standard_error == 0.0 {
    0.0
  } else {
    estimate.difference / estimate.standard_error
  }
  z.abs() >= self.critical_z(look)
}

///|
pub fn normal_cdf(value : Double) -> Double {
  1.0 / (1.0 + @math.exp(-1.702 * value))
}

///|
pub fn normal_quantile(probability : Double) -> Double {
  if probability <= 0.0 || probability >= 1.0 {
    abort("normal_quantile: probability must be in (0, 1)")
  }
  let mut low = -12.0
  let mut high = 12.0
  for _ in 0..<80 {
    let middle = (low + high) / 2.0
    if normal_cdf(middle) < probability {
      low = middle
    } else {
      high = middle
    }
  }
  (low + high) / 2.0
}

///|
pub struct SampleRatioReport {
  expected_treatment : Double
  observed_treatment : Double
  z_score : Double
  p_value : Double
  suspicious : Bool
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn sample_ratio_check(
  control : Int,
  treatment : Int,
  allocation : Double,
  alpha : Double,
) -> SampleRatioReport {
  if control < 0 || treatment < 0 || allocation <= 0.0 || allocation >= 1.0 {
    abort("sample_ratio_check: invalid inputs")
  }
  let total = (control + treatment).to_double()
  let expected = total * allocation
  let observed = treatment.to_double()
  let standard_error = (total * allocation * (1.0 - allocation)).sqrt()
  let z = if standard_error == 0.0 {
    0.0
  } else {
    (observed - expected) / standard_error
  }
  let p = 2.0 * (1.0 - normal_cdf(z.abs()))
  {
    expected_treatment: expected,
    observed_treatment: observed,
    z_score: z,
    p_value: p,
    suspicious: p < alpha,
  }
}

///|
pub struct CovariateAdjustment {
  raw_mean : Double
  adjusted_mean : Double
  coefficient : Double
  covariate_mean : Double
  variance_reduction : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn cuped_adjust(
  outcomes : Array[Double],
  covariates : Array[Double],
  target_covariate_mean : Double,
) -> CovariateAdjustment {
  if outcomes.length() != covariates.length() || outcomes.length() < 2 {
    abort("cuped_adjust: arrays must match and contain two observations")
  }
  let outcome_mean = mean(outcomes)
  let covariate_mean = mean(covariates)
  let mut covariance = 0.0
  let mut covariate_variance = 0.0
  for index in 0..<outcomes.length() {
    covariance = covariance +
      (outcomes[index] - outcome_mean) * (covariates[index] - covariate_mean)
    covariate_variance = covariate_variance +
      (covariates[index] - covariate_mean) *
      (covariates[index] - covariate_mean)
  }
  let coefficient = if covariate_variance == 0.0 {
    0.0
  } else {
    covariance / covariate_variance
  }
  let adjusted = outcome_mean -
    coefficient * (covariate_mean - target_covariate_mean)
  let raw_variance = variance(outcomes)
  let residuals : Array[Double] = []
  for index in 0..<outcomes.length() {
    residuals.push(outcomes[index] - coefficient * covariates[index])
  }
  let reduction = if raw_variance == 0.0 {
    0.0
  } else {
    1.0 - variance(residuals) / raw_variance
  }
  {
    raw_mean: outcome_mean,
    adjusted_mean: adjusted,
    coefficient,
    covariate_mean,
    variance_reduction: reduction,
  }
}

///|
pub enum MultipleTestingMethod {
  Bonferroni
  Holm
  BenjaminiHochberg
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn adjust_p_values(
  p_values : Array[Double],
  strategy : MultipleTestingMethod,
) -> Array[Double] {
  let n = p_values.length()
  let result : Array[Double] = []
  if n == 0 {
    return result
  }
  for value in p_values.iter() {
    if value < 0.0 || value > 1.0 {
      abort("adjust_p_values: p-values must be in [0, 1]")
    }
  }
  match strategy {
    MultipleTestingMethod::Bonferroni =>
      for value in p_values.iter() {
        result.push((value * n.to_double()).min(1.0))
      }
    MultipleTestingMethod::Holm => {
      let order : Array[Int] = []
      for index in 0..<n {
        order.push(index)
      }
      for left in 0..<n {
        for right in (left + 1)..<n {
          if p_values[order[right]] < p_values[order[left]] {
            let temp = order[left]
            order[left] = order[right]
            order[right] = temp
          }
        }
      }
      for _ in 0..<n {
        result.push(0.0)
      }
      let mut previous = 0.0
      for rank in 0..<n {
        let adjusted = ((n - rank).to_double() * p_values[order[rank]])
          .max(previous)
          .min(1.0)
        result[order[rank]] = adjusted
        previous = adjusted
      }
    }
    MultipleTestingMethod::BenjaminiHochberg => {
      for _ in 0..<n {
        result.push(0.0)
      }
      let order : Array[Int] = []
      for index in 0..<n {
        order.push(index)
      }
      for left in 0..<n {
        for right in (left + 1)..<n {
          if p_values[order[right]] > p_values[order[left]] {
            let temp = order[left]
            order[left] = order[right]
            order[right] = temp
          }
        }
      }
      let mut previous = 1.0
      for rank in 0..<n {
        let adjusted = (p_values[order[rank]] *
          n.to_double() /
          (n - rank).to_double())
          .min(previous)
          .min(1.0)
        result[order[rank]] = adjusted
        previous = adjusted
      }
    }
  }
  result
}

///|
pub struct UpliftSegment {
  label : String
  count : Int
  treatment_mean : Double
  control_mean : Double
  uplift : Double
  standard_error : Double
  priority : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn uplift_segment(
  label : String,
  treatment : Array[Double],
  control : Array[Double],
  value_per_unit : Double,
) -> UpliftSegment {
  if treatment.length() == 0 || control.length() == 0 {
    abort("uplift_segment: empty arm")
  }
  let t = mean(treatment)
  let c = mean(control)
  let error = (variance(treatment) / treatment.length().to_double() +
  variance(control) / control.length().to_double()).sqrt()
  let uplift = t - c
  {
    label,
    count: treatment.length() + control.length(),
    treatment_mean: t,
    control_mean: c,
    uplift,
    standard_error: error,
    priority: uplift * value_per_unit,
  }
}

///|
pub fn rank_segments(segments : Array[UpliftSegment]) -> Array[UpliftSegment] {
  let result = segments.copy()
  for left in 0..<result.length() {
    for right in (left + 1)..<result.length() {
      if result[right].priority > result[left].priority {
        let temp = result[left]
        result[left] = result[right]
        result[right] = temp
      }
    }
  }
  result
}

///|
pub struct PowerEstimate {
  effect : Double
  alpha : Double
  power : Double
  required_per_arm : Int
  achieved_power : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn sample_size_for_proportion(
  baseline : Double,
  absolute_effect : Double,
  alpha : Double,
  power : Double,
) -> Int {
  if baseline <= 0.0 ||
    baseline >= 1.0 ||
    absolute_effect == 0.0 ||
    alpha <= 0.0 ||
    power <= 0.0 ||
    power >= 1.0 {
    abort("sample_size_for_proportion: invalid inputs")
  }
  let target = (baseline + absolute_effect).max(0.0001).min(0.9999)
  let z_alpha = normal_quantile(1.0 - alpha / 2.0)
  let z_power = normal_quantile(power)
  let pooled = (2.0 * baseline * (1.0 - baseline)).sqrt()
  let separate = (baseline * (1.0 - baseline) + target * (1.0 - target)).sqrt()
  let numerator = (z_alpha * pooled + z_power * separate) *
    (z_alpha * pooled + z_power * separate)
  (numerator / (absolute_effect * absolute_effect)).ceil().to_int()
}

///|
pub fn achieved_power(
  baseline : Double,
  treatment : Double,
  per_arm : Int,
  alpha : Double,
) -> PowerEstimate {
  if per_arm <= 0 {
    abort("achieved_power: sample size must be positive")
  }
  let effect = treatment - baseline
  let error = ((baseline * (1.0 - baseline) + treatment * (1.0 - treatment)) /
  per_arm.to_double()).sqrt()
  let critical = normal_quantile(1.0 - alpha / 2.0)
  let noncentral = if error == 0.0 { 0.0 } else { effect.abs() / error }
  let power = normal_cdf(noncentral - critical) +
    normal_cdf(-noncentral - critical)
  {
    effect,
    alpha,
    power,
    required_per_arm: sample_size_for_proportion(
      baseline,
      effect,
      alpha,
      power.max(0.5001).min(0.9999),
    ),
    achieved_power: power,
  }
}

///|
pub struct ExperimentDecision {
  winner : String
  confidence : Double
  stop : Bool
  reason : String
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn decide_experiment(
  control : ExperimentArm,
  treatment : ExperimentArm,
  boundary : SequentialBoundary,
  look : Int,
) -> ExperimentDecision {
  let effect = compare_arms(control, treatment)
  let stop = boundary.can_stop(effect, look)
  let winner = if effect.difference > 0.0 {
    treatment.name
  } else {
    control.name
  }
  let reason = if stop {
    "sequential boundary crossed"
  } else {
    "continue collecting evidence"
  }
  {
    winner,
    confidence: if winner == treatment.name {
      effect.probability_positive
    } else {
      1.0 - effect.probability_positive
    },
    stop,
    reason,
  }
}

///|
pub fn allocate_fixed_ratio(
  total : Int,
  treatment_fraction : Double,
) -> (Int, Int) {
  if total < 0 || treatment_fraction < 0.0 || treatment_fraction > 1.0 {
    abort("allocate_fixed_ratio: invalid inputs")
  }
  let treatment = (total.to_double() * treatment_fraction).round().to_int()
  (total - treatment, treatment)
}

///|
pub fn allocate_epsilon_greedy(
  arms : Array[ExperimentArm],
  total : Int,
  epsilon : Double,
) -> Array[Int] {
  if total < 0 || epsilon < 0.0 || epsilon > 1.0 {
    abort("allocate_epsilon_greedy: invalid inputs")
  }
  let result : Array[Int] = []
  for _ in 0..<arms.length() {
    result.push(0)
  }
  if arms.length() == 0 {
    return result
  }
  let mut best = 0
  for index in 1..<arms.length() {
    if arms[index].mean() > arms[best].mean() {
      best = index
    }
  }
  let exploration = (total.to_double() * epsilon).round().to_int()
  for index in 0..<arms.length() {
    result[index] = exploration / arms.length()
  }
  result[best] = result[best] + total - exploration
  result
}

///|
pub fn treatment_effect_by_stratum(
  labels : Array[String],
  treatment : Array[Bool],
  outcomes : Array[Double],
) -> Array[UpliftSegment] {
  if labels.length() != treatment.length() ||
    labels.length() != outcomes.length() {
    abort("treatment_effect_by_stratum: lengths must match")
  }
  let groups : Array[String] = []
  for label in labels.iter() {
    if !groups.contains(label) {
      groups.push(label)
    }
  }
  let result : Array[UpliftSegment] = []
  for group in groups.iter() {
    let treated : Array[Double] = []
    let control : Array[Double] = []
    for index in 0..<labels.length() {
      if labels[index] == group {
        if treatment[index] {
          treated.push(outcomes[index])
        } else {
          control.push(outcomes[index])
        }
      }
    }
    if treated.length() > 0 && control.length() > 0 {
      result.push(uplift_segment(group, treated, control, 1.0))
    }
  }
  result
}

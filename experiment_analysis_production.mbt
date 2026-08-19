///|
/// Operational experiment analysis: variance reduction, allocation checks,
/// sequential guardrails, power planning, and metric attribution. The module
/// complements the lower-level experiment design APIs with reports suitable
/// for release reviews and automated decision gates.
pub struct AnalysisArm {
  name : String
  values : Array[Double]
  covariate : Array[Double]
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn AnalysisArm::new(name : String) -> AnalysisArm {
  if name == "" {
    abort("AnalysisArm: name is required")
  }
  { name, values: [], covariate: [] }
}

///|
pub fn AnalysisArm::record(self : AnalysisArm, value : Double) -> AnalysisArm {
  let values = self.values.copy()
  values.push(value)
  { ..self, values, }
}

///|
pub fn AnalysisArm::with_covariate(
  self : AnalysisArm,
  covariate : Array[Double],
) -> AnalysisArm {
  { ..self, covariate, }
}

///|
pub fn AnalysisArm::count(self : AnalysisArm) -> Int {
  self.values.length()
}

///|
pub fn AnalysisArm::mean(self : AnalysisArm) -> Double {
  if self.values.length() == 0 {
    0.0
  } else {
    mean(self.values)
  }
}

///|
pub fn AnalysisArm::variance(self : AnalysisArm) -> Double {
  if self.values.length() < 2 {
    0.0
  } else {
    variance(self.values)
  }
}

///|
pub fn AnalysisArm::standard_error(self : AnalysisArm) -> Double {
  if self.values.length() == 0 {
    0.0
  } else {
    (self.variance() / self.values.length().to_double()).sqrt()
  }
}

///|
fn analysis_join(left : Array[Double], right : Array[Double]) -> Array[Double] {
  let result = left.copy()
  for value in right.iter() {
    result.push(value)
  }
  result
}

///|
pub struct AnalysisContrast {
  control : String
  treatment : String
  estimate : Double
  standard_error : Double
  lower_95 : Double
  upper_95 : Double
  relative_uplift : Double
  observations : Int
  significant : Bool
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn compare_analysis_arms(
  control : AnalysisArm,
  treatment : AnalysisArm,
) -> AnalysisContrast {
  if control.values.length() < 2 || treatment.values.length() < 2 {
    abort(
      "compare_analysis_arms: at least two observations per arm are required",
    )
  }
  let estimate = treatment.mean() - control.mean()
  let standard_error = (control.variance() / control.count().to_double() +
  treatment.variance() / treatment.count().to_double()).sqrt()
  let margin = 1.96 * standard_error
  let relative_uplift = if control.mean() == 0.0 {
    0.0
  } else {
    estimate / control.mean()
  }
  {
    control: control.name,
    treatment: treatment.name,
    estimate,
    standard_error,
    lower_95: estimate - margin,
    upper_95: estimate + margin,
    relative_uplift,
    observations: control.count() + treatment.count(),
    significant: estimate - margin > 0.0 || estimate + margin < 0.0,
  }
}

///|
pub struct OperationalCovariateAdjustment {
  raw_effect : Double
  adjusted_effect : Double
  coefficient : Double
  variance_reduction : Double
  usable_pairs : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
/// Applies a CUPED-style linear adjustment using a shared pre-period metric.
pub fn adjust_analysis_covariate(
  control : AnalysisArm,
  treatment : AnalysisArm,
) -> OperationalCovariateAdjustment {
  if control.values.length() != control.covariate.length() ||
    treatment.values.length() != treatment.covariate.length() {
    abort(
      "adjust_analysis_covariate: each arm needs aligned outcomes and covariates",
    )
  }
  if control.count() < 2 || treatment.count() < 2 {
    abort(
      "adjust_analysis_covariate: at least two observations per arm are required",
    )
  }
  let all_outcomes = analysis_join(control.values, treatment.values)
  let all_covariates = analysis_join(control.covariate, treatment.covariate)
  let coefficient = covariance(all_outcomes, all_covariates) /
    variance(all_covariates).max(0.000000000001)
  let adjusted_control = control.values.map(fn(value) {
    value - coefficient * (mean(control.covariate) - mean(all_covariates))
  })
  let adjusted_treatment = treatment.values.map(fn(value) {
    value - coefficient * (mean(treatment.covariate) - mean(all_covariates))
  })
  let raw_effect = treatment.mean() - control.mean()
  let adjusted_effect = mean(adjusted_treatment) - mean(adjusted_control)
  let raw_variance = variance(all_outcomes)
  let adjusted_variance = variance(
    analysis_join(adjusted_control, adjusted_treatment),
  )
  {
    raw_effect,
    adjusted_effect,
    coefficient,
    variance_reduction: if raw_variance == 0.0 {
      0.0
    } else {
      1.0 - adjusted_variance / raw_variance
    },
    usable_pairs: all_outcomes.length(),
  }
}

///|
pub struct AllocationCheck {
  expected_control : Double
  observed_control : Double
  ratio_error : Double
  sample_ratio_mismatch : Bool
  control_count : Int
  treatment_count : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn check_analysis_allocation(
  control_count : Int,
  treatment_count : Int,
  expected_control : Double,
  tolerance : Double,
) -> AllocationCheck {
  if control_count < 0 ||
    treatment_count < 0 ||
    control_count + treatment_count == 0 ||
    expected_control <= 0.0 ||
    expected_control >= 1.0 ||
    tolerance < 0.0 {
    abort("check_analysis_allocation: invalid counts or policy")
  }
  let observed_control = control_count.to_double() /
    (control_count + treatment_count).to_double()
  let ratio_error = observed_control - expected_control
  {
    expected_control,
    observed_control,
    ratio_error,
    sample_ratio_mismatch: ratio_error.abs() > tolerance,
    control_count,
    treatment_count,
  }
}

///|
pub struct OperationalSequentialBoundary {
  looks : Int
  alpha : Double
  spending : Array[Double]
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn OperationalSequentialBoundary::new(
  looks : Int,
  alpha : Double,
) -> OperationalSequentialBoundary {
  if looks <= 0 || alpha <= 0.0 || alpha >= 1.0 {
    abort("SequentialBoundary: invalid looks or alpha")
  }
  let spending : Array[Double] = []
  for look in 1..<=looks {
    spending.push(alpha * (look.to_double() / looks.to_double()).sqrt())
  }
  { looks, alpha, spending }
}

///|
pub fn OperationalSequentialBoundary::critical_value(
  self : OperationalSequentialBoundary,
  look : Int,
) -> Double {
  if look <= 0 || look > self.looks {
    abort("SequentialBoundary::critical_value: look is out of range")
  }
  let alpha = self.spending[look - 1]
  let tail = 1.0 - alpha / 2.0
  // A monotone approximation is sufficient for a deterministic monitoring
  // gate and avoids requiring a special-function dependency.
  0.0 - 2.0 * normal_quantile(tail)
}

///|
pub struct SequentialDecision {
  look : Int
  z_score : Double
  p_value_proxy : Double
  boundary : Double
  stop_for_efficacy : Bool
  stop_for_futility : Bool
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn evaluate_sequential_look(
  boundary : OperationalSequentialBoundary,
  look : Int,
  estimate : Double,
  standard_error : Double,
  futility_z : Double,
) -> SequentialDecision {
  if standard_error <= 0.0 || futility_z < 0.0 {
    abort("evaluate_sequential_look: invalid standard error or futility bound")
  }
  let z_score = estimate / standard_error
  let critical = boundary.critical_value(look).abs()
  {
    look,
    z_score,
    p_value_proxy: normal_cdf(0.0 - z_score),
    boundary: critical,
    stop_for_efficacy: z_score.abs() >= critical,
    stop_for_futility: z_score.abs() <= futility_z,
  }
}

///|
pub struct PowerPlan {
  baseline_rate : Double
  minimum_effect : Double
  alpha : Double
  power : Double
  required_per_arm : Int
  detectable_effect : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn plan_binary_experiment(
  baseline_rate : Double,
  minimum_effect : Double,
  alpha : Double,
  power : Double,
) -> PowerPlan {
  if baseline_rate <= 0.0 ||
    baseline_rate >= 1.0 ||
    minimum_effect <= 0.0 ||
    alpha <= 0.0 ||
    alpha >= 1.0 ||
    power <= 0.0 ||
    power >= 1.0 {
    abort("plan_binary_experiment: invalid rates or probabilities")
  }
  let z_alpha = normal_quantile(1.0 - alpha / 2.0).abs()
  let z_power = normal_quantile(power).abs()
  let treated_rate = (baseline_rate + minimum_effect).min(0.999999)
  let pooled = baseline_rate * (1.0 - baseline_rate) +
    treated_rate * (1.0 - treated_rate)
  let required = @math.pow(
      (z_alpha + z_power) * (2.0 * pooled).sqrt() / minimum_effect,
      2.0,
    )
    .ceil()
    .to_int()
  {
    baseline_rate,
    minimum_effect,
    alpha,
    power,
    required_per_arm: required.max(2),
    detectable_effect: treated_rate - baseline_rate,
  }
}

///|
pub struct GuardrailMetric {
  name : String
  control : Double
  treatment : Double
  minimum_ratio : Double
  maximum_drop : Double
  ratio : Double
  passed : Bool
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn GuardrailMetric::new(
  name : String,
  control : Double,
  treatment : Double,
  minimum_ratio : Double,
  maximum_drop : Double,
) -> GuardrailMetric {
  if name == "" || minimum_ratio < 0.0 || maximum_drop < 0.0 {
    abort("GuardrailMetric: invalid metric or policy")
  }
  let ratio = if control == 0.0 { 1.0 } else { treatment / control }
  {
    name,
    control,
    treatment,
    minimum_ratio,
    maximum_drop,
    ratio,
    passed: ratio >= minimum_ratio && control - treatment <= maximum_drop,
  }
}

///|
pub struct GuardrailReport {
  metrics : Array[GuardrailMetric]
  passed : Bool
  blocking_failures : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn evaluate_guardrails(metrics : Array[GuardrailMetric]) -> GuardrailReport {
  let failures = metrics.filter(fn(metric) { !metric.passed }).length()
  { metrics, passed: failures == 0, blocking_failures: failures }
}

///|
pub struct AttributionEntry {
  source : String
  contribution : Double
  share : Double
  cumulative : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub struct AttributionLedger {
  entries : Array[AttributionEntry]
  total : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn AttributionLedger::new() -> AttributionLedger {
  { entries: [], total: 0.0 }
}

///|
pub fn AttributionLedger::record(
  self : AttributionLedger,
  source : String,
  contribution : Double,
) -> AttributionLedger {
  if source == "" || contribution < 0.0 {
    abort("AttributionLedger::record: invalid source or contribution")
  }
  let total = self.total + contribution
  let entries = self.entries.copy()
  entries.push({
    source,
    contribution,
    share: if total == 0.0 {
      0.0
    } else {
      contribution / total
    },
    cumulative: total,
  })
  { entries, total }
}

///|
pub fn AttributionLedger::normalize(
  self : AttributionLedger,
) -> Array[AttributionEntry] {
  if self.total == 0.0 {
    return self.entries
  }
  self.entries.map(fn(entry) {
    {
      ..entry,
      share: entry.contribution / self.total,
      cumulative: entry.cumulative / self.total,
    }
  })
}

///|
pub fn AttributionLedger::top_source(
  self : AttributionLedger,
) -> AttributionEntry? {
  if self.entries.length() == 0 {
    return None
  }
  let mut best = self.entries[0]
  for entry in self.entries.iter() {
    if entry.contribution > best.contribution {
      best = entry
    }
  }
  Some(best)
}

///|
pub struct BayesianExperimentDecision {
  control_mean : Double
  treatment_mean : Double
  probability_treatment_better : Double
  expected_lift : Double
  recommendation : String
} derive(Debug, Eq, ToJson, FromJson)

///|
/// Uses a normal posterior approximation for a quick release decision. The
/// caller supplies prior means and standard errors so the decision remains
/// transparent and reproducible.
pub fn bayesian_experiment_decision(
  control_mean : Double,
  control_error : Double,
  treatment_mean : Double,
  treatment_error : Double,
  required_probability : Double,
) -> BayesianExperimentDecision {
  if control_error <= 0.0 ||
    treatment_error <= 0.0 ||
    required_probability <= 0.5 ||
    required_probability >= 1.0 {
    abort("bayesian_experiment_decision: invalid uncertainty or probability")
  }
  let difference = treatment_mean - control_mean
  let error = (control_error * control_error + treatment_error * treatment_error).sqrt()
  let probability = normal_cdf(difference / error)
  let recommendation = if probability >= required_probability {
    "ship"
  } else if probability <= 1.0 - required_probability {
    "rollback"
  } else {
    "continue"
  }
  {
    control_mean,
    treatment_mean,
    probability_treatment_better: probability,
    expected_lift: difference,
    recommendation,
  }
}

///|
pub struct ExperimentQuality {
  sample_ratio_ok : Bool
  guardrails_ok : Bool
  sequential_ok : Bool
  complete : Bool
  ready_for_decision : Bool
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn experiment_quality(
  allocation : AllocationCheck,
  guardrails : GuardrailReport,
  sequential : SequentialDecision,
  expected_observations : Int,
  observed_observations : Int,
) -> ExperimentQuality {
  if expected_observations <= 0 || observed_observations < 0 {
    abort("experiment_quality: invalid observation counts")
  }
  let complete = observed_observations >= expected_observations
  {
    sample_ratio_ok: !allocation.sample_ratio_mismatch,
    guardrails_ok: guardrails.passed,
    sequential_ok: !sequential.stop_for_futility,
    complete,
    ready_for_decision: !allocation.sample_ratio_mismatch &&
    guardrails.passed &&
    complete,
  }
}

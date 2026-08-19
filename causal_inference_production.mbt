///|
/// Practical causal-effect estimators and sensitivity diagnostics.
pub struct CausalObservation {
  treatment : Bool
  outcome : Double
  propensity : Double
  weight : Double
  stratum : String
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn CausalObservation::new(
  treatment : Bool,
  outcome : Double,
  propensity : Double,
) -> CausalObservation {
  if propensity <= 0.0 || propensity >= 1.0 {
    abort("CausalObservation: propensity must be in (0, 1)")
  }
  {
    treatment,
    outcome,
    propensity,
    weight: if treatment {
      1.0 / propensity
    } else {
      1.0 / (1.0 - propensity)
    },
    stratum: "",
  }
}

///|
pub fn CausalObservation::with_stratum(
  self : CausalObservation,
  stratum : String,
) -> CausalObservation {
  { ..self, stratum, }
}

///|
pub struct CausalEffect {
  estimate : Double
  standard_error : Double
  lower_95 : Double
  upper_95 : Double
  treated : Int
  control : Int
  estimator : String
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn CausalEffect::significant(self : CausalEffect) -> Bool {
  self.lower_95 > 0.0 || self.upper_95 < 0.0
}

///|
pub fn difference_in_means(
  treated : Array[Double],
  control : Array[Double],
) -> CausalEffect {
  if treated.length() < 2 || control.length() < 2 {
    abort("difference_in_means: at least two observations per arm")
  }
  let estimate = mean(treated) - mean(control)
  let error = (variance(treated) / treated.length().to_double() +
  variance(control) / control.length().to_double()).sqrt()
  {
    estimate,
    standard_error: error,
    lower_95: estimate - 1.96 * error,
    upper_95: estimate + 1.96 * error,
    treated: treated.length(),
    control: control.length(),
    estimator: "difference_in_means",
  }
}

///|
pub fn inverse_probability_effect(
  observations : Array[CausalObservation],
) -> CausalEffect {
  let mut treated_sum = 0.0
  let mut control_sum = 0.0
  let mut treated_weight = 0.0
  let mut control_weight = 0.0
  let treated_values : Array[Double] = []
  let control_values : Array[Double] = []
  for observation in observations.iter() {
    if observation.treatment {
      treated_sum = treated_sum + observation.outcome * observation.weight
      treated_weight = treated_weight + observation.weight
      treated_values.push(observation.outcome)
    } else {
      control_sum = control_sum + observation.outcome * observation.weight
      control_weight = control_weight + observation.weight
      control_values.push(observation.outcome)
    }
  }
  if treated_weight == 0.0 || control_weight == 0.0 {
    abort("inverse_probability_effect: both arms are required")
  }
  let estimate = treated_sum / treated_weight - control_sum / control_weight
  let error = (variance(treated_values) /
  treated_values.length().max(1).to_double() +
  variance(control_values) / control_values.length().max(1).to_double()).sqrt()
  {
    estimate,
    standard_error: error,
    lower_95: estimate - 1.96 * error,
    upper_95: estimate + 1.96 * error,
    treated: treated_values.length(),
    control: control_values.length(),
    estimator: "inverse_probability_weighting",
  }
}

///|
pub fn propensity_overlap(observations : Array[CausalObservation]) -> Double {
  if observations.length() == 0 {
    return 0.0
  }
  let mut overlap = 0
  for observation in observations.iter() {
    if observation.propensity >= 0.1 && observation.propensity <= 0.9 {
      overlap = overlap + 1
    }
  }
  overlap.to_double() / observations.length().to_double()
}

///|
pub struct SensitivityCurve {
  bias_factor : Double
  adjusted_effect : Double
  adjusted_lower : Double
  adjusted_upper : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn sensitivity_curve(
  effect : CausalEffect,
  factors : Array[Double],
) -> Array[SensitivityCurve] {
  let result : Array[SensitivityCurve] = []
  for factor in factors.iter() {
    if factor < 0.0 {
      abort("sensitivity_curve: bias factor must be non-negative")
    }
    let adjustment = effect.standard_error * factor
    result.push({
      bias_factor: factor,
      adjusted_effect: effect.estimate - adjustment,
      adjusted_lower: effect.lower_95 - adjustment,
      adjusted_upper: effect.upper_95 - adjustment,
    })
  }
  result
}

///|
pub struct MediationResult {
  total_effect : Double
  direct_effect : Double
  indirect_effect : Double
  mediated_fraction : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn mediation_decomposition(
  total : CausalEffect,
  direct : CausalEffect,
) -> MediationResult {
  let indirect = total.estimate - direct.estimate
  {
    total_effect: total.estimate,
    direct_effect: direct.estimate,
    indirect_effect: indirect,
    mediated_fraction: if total.estimate == 0.0 {
      0.0
    } else {
      indirect / total.estimate
    },
  }
}

///|
pub fn standardize_effect(
  effect : CausalEffect,
  outcome_standard_deviation : Double,
) -> CausalEffect {
  if outcome_standard_deviation <= 0.0 {
    abort("standardize_effect: standard deviation must be positive")
  }
  {
    ..effect,
    estimate: effect.estimate / outcome_standard_deviation,
    standard_error: effect.standard_error / outcome_standard_deviation,
    lower_95: effect.lower_95 / outcome_standard_deviation,
    upper_95: effect.upper_95 / outcome_standard_deviation,
    estimator: effect.estimator + "_standardized",
  }
}

///|
pub struct StratumEffect {
  stratum : String
  effect : CausalEffect
  weight : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn stratified_effect(
  observations : Array[CausalObservation],
) -> Array[StratumEffect] {
  let labels : Array[String] = []
  for observation in observations.iter() {
    if !labels.contains(observation.stratum) {
      labels.push(observation.stratum)
    }
  }
  let result : Array[StratumEffect] = []
  for label in labels.iter() {
    let treated : Array[Double] = []
    let control : Array[Double] = []
    for observation in observations.iter() {
      if observation.stratum == label {
        if observation.treatment {
          treated.push(observation.outcome)
        } else {
          control.push(observation.outcome)
        }
      }
    }
    if treated.length() >= 2 && control.length() >= 2 {
      result.push({
        stratum: label,
        effect: difference_in_means(treated, control),
        weight: (treated.length() + control.length()).to_double(),
      })
    }
  }
  result
}

///|
pub fn aggregate_stratified_effect(
  effects : Array[StratumEffect],
) -> CausalEffect {
  if effects.length() == 0 {
    abort("aggregate_stratified_effect: no strata")
  }
  let total_weight = effects.fold(init=0.0, (total, item) => total + item.weight)
  let estimate = effects.fold(init=0.0, (total, item) => {
      total + item.effect.estimate * item.weight
    }) /
    total_weight
  let error = effects.fold(init=0.0, (total, item) => {
      total +
      item.effect.standard_error * item.effect.standard_error * item.weight
    }) /
    total_weight
  {
    estimate,
    standard_error: error.sqrt(),
    lower_95: estimate - 1.96 * error.sqrt(),
    upper_95: estimate + 1.96 * error.sqrt(),
    treated: effects.fold(init=0, (total, item) => total + item.effect.treated),
    control: effects.fold(init=0, (total, item) => total + item.effect.control),
    estimator: "stratified",
  }
}

///|
pub struct BalanceReport {
  standardized_difference : Double
  treated_mean : Double
  control_mean : Double
  treated_variance : Double
  control_variance : Double
  balanced : Bool
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn covariate_balance(
  treated : Array[Double],
  control : Array[Double],
  threshold : Double,
) -> BalanceReport {
  if treated.length() < 2 || control.length() < 2 || threshold < 0.0 {
    abort("covariate_balance: invalid inputs")
  }
  let treated_mean = mean(treated)
  let control_mean = mean(control)
  let pooled = ((variance(treated) + variance(control)) / 2.0)
    .sqrt()
    .max(0.000000000001)
  let standardized = (treated_mean - control_mean) / pooled
  {
    standardized_difference: standardized,
    treated_mean,
    control_mean,
    treated_variance: variance(treated),
    control_variance: variance(control),
    balanced: standardized.abs() <= threshold,
  }
}

///|
pub fn balance_table(
  treated : Array[Array[Double]],
  control : Array[Array[Double]],
  threshold : Double,
) -> Array[BalanceReport] {
  if treated.length() != control.length() {
    abort("balance_table: feature counts must match")
  }
  let result : Array[BalanceReport] = []
  for index in 0..<treated.length() {
    result.push(covariate_balance(treated[index], control[index], threshold))
  }
  result
}

///|
pub struct TreatmentPolicyValue {
  treated_value : Double
  control_value : Double
  policy_value : Double
  treatment_rate : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn policy_value(
  observations : Array[CausalObservation],
  policy_treat : Array[Bool],
) -> TreatmentPolicyValue {
  if observations.length() != policy_treat.length() ||
    observations.length() == 0 {
    abort("policy_value: lengths must match")
  }
  let mut treated = 0.0
  let mut control = 0.0
  let mut treated_weight = 0.0
  let mut control_weight = 0.0
  let mut policy_sum = 0.0
  let mut policy_weight = 0.0
  for index in 0..<observations.length() {
    let observation = observations[index]
    if observation.treatment {
      treated = treated + observation.outcome * observation.weight
      treated_weight = treated_weight + observation.weight
    } else {
      control = control + observation.outcome * observation.weight
      control_weight = control_weight + observation.weight
    }
    let treated_contribution = if observation.treatment {
      observation.outcome / observation.propensity
    } else {
      0.0
    }
    let control_contribution = if observation.treatment {
      0.0
    } else {
      observation.outcome / (1.0 - observation.propensity)
    }
    let treated_weight_contribution = if observation.treatment {
      1.0 / observation.propensity
    } else {
      0.0
    }
    let control_weight_contribution = if observation.treatment {
      0.0
    } else {
      1.0 / (1.0 - observation.propensity)
    }
    if policy_treat[index] {
      policy_sum = policy_sum + treated_contribution
      policy_weight = policy_weight + treated_weight_contribution
    } else {
      policy_sum = policy_sum + control_contribution
      policy_weight = policy_weight + control_weight_contribution
    }
  }
  let treatment_count = policy_treat.filter(fn(value) { value }).length()
  {
    treated_value: treated / treated_weight,
    control_value: control / control_weight,
    policy_value: policy_sum / policy_weight,
    treatment_rate: treatment_count.to_double() /
    policy_treat.length().to_double(),
  }
}

///|
pub fn treatment_on_treated(
  effect : CausalEffect,
  treatment_rate : Double,
) -> Double {
  if treatment_rate <= 0.0 || treatment_rate > 1.0 {
    abort("treatment_on_treated: invalid treatment rate")
  }
  effect.estimate / treatment_rate
}

///|
pub fn effect_heterogeneity(effects : Array[CausalEffect]) -> Double {
  if effects.length() < 2 {
    return 0.0
  }
  variance(effects.map(fn(effect) { effect.estimate }))
}

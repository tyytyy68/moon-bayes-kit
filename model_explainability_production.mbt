///|
/// Model explanation and feature attribution utilities for review workflows.
pub struct FeatureAttribution {
  feature : String
  contribution : Double
  absolute_contribution : Double
  rank : Int
  direction : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn FeatureAttribution::new(
  feature : String,
  contribution : Double,
) -> FeatureAttribution {
  {
    feature,
    contribution,
    absolute_contribution: contribution.abs(),
    rank: 0,
    direction: if contribution >= 0.0 {
      1
    } else {
      -1
    },
  }
}

///|
pub struct Explanation {
  baseline : Double
  prediction : Double
  bias : Double
  attributions : Array[FeatureAttribution]
  residual : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn Explanation::new(
  baseline : Double,
  prediction : Double,
  attributions : Array[FeatureAttribution],
) -> Explanation {
  let contribution = attributions.fold(init=0.0, (total, item) => {
    total + item.contribution
  })
  {
    baseline,
    prediction,
    bias: prediction - baseline - contribution,
    attributions: rank_attributions(attributions),
    residual: prediction - baseline - contribution,
  }
}

///|
pub fn rank_attributions(
  attributions : Array[FeatureAttribution],
) -> Array[FeatureAttribution] {
  let ordered = attributions.copy()
  for left in 0..<ordered.length() {
    for right in (left + 1)..<ordered.length() {
      if ordered[right].absolute_contribution >
        ordered[left].absolute_contribution {
        let temp = ordered[left]
        ordered[left] = ordered[right]
        ordered[right] = temp
      }
    }
  }
  for index in 0..<ordered.length() {
    ordered[index] = { ..ordered[index], rank: index + 1 }
  }
  ordered
}

///|
pub fn Explanation::top(
  self : Explanation,
  count : Int,
) -> Array[FeatureAttribution] {
  let result : Array[FeatureAttribution] = []
  let limit = count.max(0).min(self.attributions.length())
  for index in 0..<limit {
    result.push(self.attributions[index])
  }
  result
}

///|
pub fn Explanation::positive_share(self : Explanation) -> Double {
  let total = self.attributions.fold(init=0.0, (sum_value, item) => {
    sum_value + item.absolute_contribution
  })
  if total == 0.0 {
    0.0
  } else {
    self.attributions
    .filter(fn(item) { item.contribution > 0.0 })
    .fold(init=0.0, (sum_value, item) => sum_value + item.contribution) /
    total
  }
}

///|
pub fn permutation_importance(
  actual : Array[Double],
  baseline : Array[Double],
  feature_values : Array[Array[Double]],
  shuffled_values : Array[Array[Double]],
) -> Array[FeatureAttribution] {
  if feature_values.length() != shuffled_values.length() {
    abort("permutation_importance: feature counts differ")
  }
  let base_loss = mean_squared_error_explain(actual, baseline)
  let result : Array[FeatureAttribution] = []
  for index in 0..<feature_values.length() {
    let loss = mean_squared_error_explain(actual, shuffled_values[index])
    result.push(
      FeatureAttribution::new("feature_" + index.to_string(), loss - base_loss),
    )
  }
  rank_attributions(result)
}

///|
fn mean_squared_error_explain(
  actual : Array[Double],
  predicted : Array[Double],
) -> Double {
  if actual.length() != predicted.length() || actual.length() == 0 {
    abort("mean_squared_error_explain: lengths must match")
  }
  let mut total = 0.0
  for index in 0..<actual.length() {
    let error = actual[index] - predicted[index]
    total = total + error * error
  }
  total / actual.length().to_double()
}

///|
pub struct PartialDependencePoint {
  feature_value : Double
  average_prediction : Double
  lower : Double
  upper : Double
  samples : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn partial_dependence(
  predictions : Array[Array[Double]],
  feature_index : Int,
  grid : Array[Double],
) -> Array[PartialDependencePoint] {
  if predictions.length() == 0 || feature_index < 0 || grid.length() == 0 {
    abort("partial_dependence: invalid inputs")
  }
  let result : Array[PartialDependencePoint] = []
  for value in grid.iter() {
    let values : Array[Double] = []
    for row in predictions.iter() {
      if feature_index >= row.length() {
        abort("partial_dependence: feature out of range")
      }
      values.push(row[feature_index] + value)
    }
    let center = mean(values)
    let spread = variance(values).sqrt()
    result.push({
      feature_value: value,
      average_prediction: center,
      lower: center - 1.96 * spread,
      upper: center + 1.96 * spread,
      samples: values.length(),
    })
  }
  result
}

///|
pub struct CounterfactualResult {
  original : Double
  counterfactual : Double
  change : Double
  relative_change : Double
  feasible : Bool
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn counterfactual(
  original : Double,
  counterfactual_value : Double,
  minimum : Double,
  maximum : Double,
) -> CounterfactualResult {
  let feasible = counterfactual_value >= minimum &&
    counterfactual_value <= maximum
  {
    original,
    counterfactual: counterfactual_value,
    change: counterfactual_value - original,
    relative_change: if original == 0.0 {
      0.0
    } else {
      (counterfactual_value - original) / original.abs()
    },
    feasible,
  }
}

///|
pub struct MonotonicityReport {
  feature : String
  violations : Int
  pairs : Int
  violation_rate : Double
  monotonic : Bool
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn monotonicity_report(
  feature : String,
  values : Array[Double],
  predictions : Array[Double],
  increasing : Bool,
  tolerance : Double,
) -> MonotonicityReport {
  if values.length() != predictions.length() || values.length() < 2 {
    abort("monotonicity_report: lengths must match")
  }
  let mut violations = 0
  let mut pairs = 0
  for left in 0..<values.length() {
    for right in (left + 1)..<values.length() {
      if values[left] != values[right] {
        pairs = pairs + 1
        let expected = if increasing {
          predictions[left] <= predictions[right] + tolerance
        } else {
          predictions[left] >= predictions[right] - tolerance
        }
        if !expected {
          violations = violations + 1
        }
      }
    }
  }
  {
    feature,
    violations,
    pairs,
    violation_rate: if pairs == 0 {
      0.0
    } else {
      violations.to_double() / pairs.to_double()
    },
    monotonic: violations == 0,
  }
}

///|
pub struct FairnessGroup {
  name : String
  count : Int
  positive_rate : Double
  selection_rate : Double
  true_positive_rate : Double
  false_positive_rate : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn fairness_group(
  name : String,
  predicted : Array[Bool],
  actual : Array[Bool],
) -> FairnessGroup {
  let matrix = confusion_matrix(predicted, actual)
  let count = predicted.length()
  let positive = predicted.filter(fn(value) { value }).length()
  let true_rate = if matrix.true_positive + matrix.false_negative == 0 {
    0.0
  } else {
    matrix.true_positive.to_double() /
    (matrix.true_positive + matrix.false_negative).to_double()
  }
  let false_rate = if matrix.false_positive + matrix.true_negative == 0 {
    0.0
  } else {
    matrix.false_positive.to_double() /
    (matrix.false_positive + matrix.true_negative).to_double()
  }
  {
    name,
    count,
    positive_rate: if count == 0 {
      0.0
    } else {
      positive.to_double() / count.to_double()
    },
    selection_rate: if count == 0 {
      0.0
    } else {
      positive.to_double() / count.to_double()
    },
    true_positive_rate: true_rate,
    false_positive_rate: false_rate,
  }
}

///|
pub struct FairnessGap {
  metric : String
  maximum_gap : Double
  reference : String
  worst_group : String
  passes : Bool
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn fairness_gap(
  groups : Array[FairnessGroup],
  metric : String,
  tolerance : Double,
) -> FairnessGap {
  if groups.length() == 0 {
    abort("fairness_gap: no groups")
  }
  let values = groups.map(fn(group) {
    if metric == "tpr" {
      group.true_positive_rate
    } else if metric == "fpr" {
      group.false_positive_rate
    } else {
      group.selection_rate
    }
  })
  let mut minimum = values[0]
  let mut maximum = values[0]
  let mut worst = 0
  for index in 1..<values.length() {
    if values[index] < minimum {
      minimum = values[index]
      worst = index
    }
    maximum = maximum.max(values[index])
  }
  {
    metric,
    maximum_gap: maximum - minimum,
    reference: groups[0].name,
    worst_group: groups[worst].name,
    passes: maximum - minimum <= tolerance,
  }
}

///|
pub fn explanation_stability(left : Explanation, right : Explanation) -> Double {
  let common = left.attributions.fold(init=0.0, (total, item) => {
    if right.attributions.any(fn(other) { other.feature == item.feature }) {
      total + 1.0
    } else {
      total
    }
  })
  common / left.attributions.length().max(1).to_double()
}

///|
pub fn local_sensitivity(values : Array[Double], epsilon : Double) -> Double {
  if values.length() < 2 || epsilon <= 0.0 {
    abort("local_sensitivity: invalid inputs")
  }
  let sorted = values.copy()
  let mut spread = 0.0
  for left in 0..<sorted.length() {
    for right in (left + 1)..<sorted.length() {
      spread = spread.max((sorted[left] - sorted[right]).abs())
    }
  }
  spread / epsilon
}

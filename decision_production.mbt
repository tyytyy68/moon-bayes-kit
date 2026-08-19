///|
/// Decision analysis, threshold policies, and cost-sensitive evaluation.
pub struct DecisionCost {
  false_positive : Double
  false_negative : Double
  true_positive : Double
  true_negative : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn DecisionCost::new(
  false_positive : Double,
  false_negative : Double,
) -> DecisionCost {
  if false_positive < 0.0 || false_negative < 0.0 {
    abort("DecisionCost: costs must be non-negative")
  }
  { false_positive, false_negative, true_positive: 0.0, true_negative: 0.0 }
}

///|
pub fn DecisionCost::expected(
  self : DecisionCost,
  probabilities : Array[Double],
  actual : Array[Bool],
  threshold : Double,
) -> Double {
  if probabilities.length() != actual.length() ||
    probabilities.length() == 0 ||
    threshold < 0.0 ||
    threshold > 1.0 {
    abort("DecisionCost: invalid inputs")
  }
  let mut total = 0.0
  for index in 0..<actual.length() {
    let predicted = probabilities[index] >= threshold
    if predicted && !actual[index] {
      total = total + self.false_positive
    } else if !predicted && actual[index] {
      total = total + self.false_negative
    }
  }
  total / actual.length().to_double()
}

///|
pub struct ThresholdReport {
  threshold : Double
  expected_cost : Double
  accuracy : Double
  precision : Double
  recall : Double
  f1 : Double
  selected_rate : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn threshold_report(
  probabilities : Array[Double],
  actual : Array[Bool],
  threshold : Double,
  cost : DecisionCost,
) -> ThresholdReport {
  if probabilities.length() != actual.length() ||
    probabilities.length() == 0 ||
    threshold < 0.0 ||
    threshold > 1.0 {
    abort("threshold_report: invalid inputs")
  }
  let mut tp = 0
  let mut fp = 0
  let mut fn_count = 0
  let mut correct = 0
  let mut selected = 0
  for index in 0..<actual.length() {
    let predicted = probabilities[index] >= threshold
    if predicted {
      selected = selected + 1
    }
    if predicted && actual[index] {
      tp = tp + 1
    } else if predicted && !actual[index] {
      fp = fp + 1
    } else if !predicted && actual[index] {
      fn_count = fn_count + 1
    }
    if predicted == actual[index] {
      correct = correct + 1
    }
  }
  let precision = if tp + fp == 0 {
    0.0
  } else {
    tp.to_double() / (tp + fp).to_double()
  }
  let recall = if tp + fn_count == 0 {
    0.0
  } else {
    tp.to_double() / (tp + fn_count).to_double()
  }
  let f1 = if precision + recall == 0.0 {
    0.0
  } else {
    2.0 * precision * recall / (precision + recall)
  }
  {
    threshold,
    expected_cost: cost.expected(probabilities, actual, threshold),
    accuracy: correct.to_double() / actual.length().to_double(),
    precision,
    recall,
    f1,
    selected_rate: selected.to_double() / actual.length().to_double(),
  }
}

///|
pub fn optimize_threshold(
  probabilities : Array[Double],
  actual : Array[Bool],
  cost : DecisionCost,
  steps : Int,
) -> ThresholdReport {
  if steps <= 0 {
    abort("optimize_threshold: steps must be positive")
  }
  let mut best = threshold_report(probabilities, actual, 0.0, cost)
  for index in 1..<=steps {
    let candidate = threshold_report(
      probabilities,
      actual,
      index.to_double() / steps.to_double(),
      cost,
    )
    if candidate.expected_cost < best.expected_cost {
      best = candidate
    }
  }
  best
}

///|
pub struct DecisionConfusionMatrix {
  true_positive : Int
  false_positive : Int
  true_negative : Int
  false_negative : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn confusion_matrix(
  predicted : Array[Bool],
  actual : Array[Bool],
) -> DecisionConfusionMatrix {
  if predicted.length() != actual.length() {
    abort("confusion_matrix: lengths must match")
  }
  let mut tp = 0
  let mut fp = 0
  let mut tn = 0
  let mut fn_count = 0
  for index in 0..<actual.length() {
    if predicted[index] && actual[index] {
      tp = tp + 1
    } else if predicted[index] && !actual[index] {
      fp = fp + 1
    } else if !predicted[index] && !actual[index] {
      tn = tn + 1
    } else {
      fn_count = fn_count + 1
    }
  }
  {
    true_positive: tp,
    false_positive: fp,
    true_negative: tn,
    false_negative: fn_count,
  }
}

///|
pub fn cost_from_confusion(
  matrix : DecisionConfusionMatrix,
  cost : DecisionCost,
) -> Double {
  matrix.false_positive.to_double() * cost.false_positive +
  matrix.false_negative.to_double() * cost.false_negative
}

///|
pub fn balanced_accuracy(matrix : DecisionConfusionMatrix) -> Double {
  let sensitivity = if matrix.true_positive + matrix.false_negative == 0 {
    0.0
  } else {
    matrix.true_positive.to_double() /
    (matrix.true_positive + matrix.false_negative).to_double()
  }
  let specificity = if matrix.true_negative + matrix.false_positive == 0 {
    0.0
  } else {
    matrix.true_negative.to_double() /
    (matrix.true_negative + matrix.false_positive).to_double()
  }
  (sensitivity + specificity) / 2.0
}

///|
pub struct UtilityCurvePoint {
  threshold : Double
  net_benefit : Double
  treated : Int
  true_positives : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn utility_curve(
  probabilities : Array[Double],
  actual : Array[Bool],
  harm : Double,
  steps : Int,
) -> Array[UtilityCurvePoint] {
  if probabilities.length() != actual.length() ||
    probabilities.length() == 0 ||
    harm < 0.0 ||
    steps <= 0 {
    abort("utility_curve: invalid inputs")
  }
  let result : Array[UtilityCurvePoint] = []
  for step in 0..<=steps {
    let threshold = step.to_double() / steps.to_double()
    let mut treated = 0
    let mut true_positives = 0
    for index in 0..<actual.length() {
      if probabilities[index] >= threshold {
        treated = treated + 1
        if actual[index] {
          true_positives = true_positives + 1
        }
      }
    }
    let benefit = true_positives.to_double() / actual.length().to_double()
    let burden = (treated - true_positives).to_double() /
      actual.length().to_double() *
      harm
    result.push({
      threshold,
      net_benefit: benefit - burden,
      treated,
      true_positives,
    })
  }
  result
}

///|
pub enum Action {
  Reject
  Review
  Accept
  Escalate
} derive(Debug, Eq, ToJson, FromJson)

///|
pub struct ActionRule {
  lower : Double
  upper : Double
  action : Action
  priority : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn ActionRule::matches(self : ActionRule, score : Double) -> Bool {
  score >= self.lower && score < self.upper
}

///|
pub fn choose_action(
  score : Double,
  rules : Array[ActionRule],
  fallback : Action,
) -> Action {
  let mut chosen = fallback
  let mut priority = -1
  for rule in rules.iter() {
    if rule.matches(score) && rule.priority >= priority {
      chosen = rule.action
      priority = rule.priority
    }
  }
  chosen
}

///|
pub struct DecisionLog {
  id : String
  score : Double
  action : Action
  threshold : Double
  reason : String
  timestamp : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn DecisionLog::new(
  id : String,
  score : Double,
  action : Action,
  threshold : Double,
  timestamp : Int,
) -> DecisionLog {
  { id, score, action, threshold, reason: "", timestamp }
}

///|
pub fn decision_consistency(logs : Array[DecisionLog]) -> Double {
  if logs.length() == 0 {
    return 1.0
  }
  let mut consistent = 0
  for log in logs.iter() {
    if (log.score >= log.threshold && log.action != Action::Reject) ||
      (log.score < log.threshold && log.action == Action::Reject) {
      consistent = consistent + 1
    }
  }
  consistent.to_double() / logs.length().to_double()
}

///|
pub fn expected_value(
  probability : Double,
  benefit : Double,
  cost : Double,
) -> Double {
  probability * benefit - (1.0 - probability) * cost
}

///|
pub fn break_even_probability(benefit : Double, cost : Double) -> Double {
  if benefit + cost == 0.0 {
    0.5
  } else {
    cost / (benefit + cost)
  }
}

///|
pub fn value_of_information(
  current : Double,
  improved : Double,
  information_cost : Double,
) -> Double {
  improved - current - information_cost
}

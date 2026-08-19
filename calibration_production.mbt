///|
/// Probability calibration and threshold-selection tools for production
/// classifiers. The APIs operate on plain arrays so they can be used both in
/// offline evaluation and in a lightweight prediction service.
pub struct ProbabilityCalibrationBin {
  lower : Double
  upper : Double
  count : Int
  positive : Int
  mean_probability : Double
  observed_rate : Double
  gap : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub struct ProbabilityCalibrationReport {
  bins : Array[ProbabilityCalibrationBin]
  brier_score : Double
  expected_calibration_error : Double
  maximum_calibration_error : Double
  log_loss : Double
  observations : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn ProbabilityCalibrationReport::bin_count(
  self : ProbabilityCalibrationReport,
) -> Int {
  self.bins.length()
}

///|
pub fn ProbabilityCalibrationReport::bins(
  self : ProbabilityCalibrationReport,
) -> Array[ProbabilityCalibrationBin] {
  self.bins.copy()
}

///|
pub fn ProbabilityCalibrationReport::is_calibrated(
  self : ProbabilityCalibrationReport,
  tolerance : Double,
) -> Bool {
  if tolerance < 0.0 {
    abort("ProbabilityCalibrationReport: tolerance must be non-negative")
  }
  self.expected_calibration_error <= tolerance
}

///|
fn calibration_validate(
  probabilities : Array[Double],
  outcomes : Array[Bool],
) -> Unit {
  if probabilities.length() == 0 || probabilities.length() != outcomes.length() {
    abort(
      "calibration: probabilities and outcomes must be non-empty and aligned",
    )
  }
  for probability in probabilities.iter() {
    if probability < 0.0 || probability > 1.0 {
      abort("calibration: probabilities must be in [0, 1]")
    }
  }
}

///|
pub fn calibration_brier_score(
  probabilities : Array[Double],
  outcomes : Array[Bool],
) -> Double {
  calibration_validate(probabilities, outcomes)
  let mut total = 0.0
  for index in 0..<probabilities.length() {
    let target = if outcomes[index] { 1.0 } else { 0.0 }
    let error = probabilities[index] - target
    total = total + error * error
  }
  total / probabilities.length().to_double()
}

///|
pub fn binary_log_loss(
  probabilities : Array[Double],
  outcomes : Array[Bool],
) -> Double {
  calibration_validate(probabilities, outcomes)
  let mut total = 0.0
  for index in 0..<probabilities.length() {
    let probability = probabilities[index]
      .max(0.000000000001)
      .min(0.999999999999)
    if outcomes[index] {
      total = total - uncertainty_log(probability)
    } else {
      total = total - uncertainty_log(1.0 - probability)
    }
  }
  total / probabilities.length().to_double()
}

///|
pub fn calibration_report(
  probabilities : Array[Double],
  outcomes : Array[Bool],
  bucket_count : Int,
) -> ProbabilityCalibrationReport {
  calibration_validate(probabilities, outcomes)
  if bucket_count <= 0 {
    abort("calibration_report: bucket count must be positive")
  }
  let actual_count = bucket_count.min(probabilities.length())
  let bins : Array[ProbabilityCalibrationBin] = []
  let mut calibration_error = 0.0
  let mut maximum_error = 0.0
  for bucket in 0..<actual_count {
    let lower = bucket.to_double() / actual_count.to_double()
    let upper = (bucket + 1).to_double() / actual_count.to_double()
    let mut count = 0
    let mut positive = 0
    let mut probability_total = 0.0
    for index in 0..<probabilities.length() {
      let probability = probabilities[index]
      let included = if bucket == actual_count - 1 {
        probability >= lower && probability <= upper
      } else {
        probability >= lower && probability < upper
      }
      if included {
        count = count + 1
        if outcomes[index] {
          positive = positive + 1
        }
        probability_total = probability_total + probability
      }
    }
    let mean_probability = if count == 0 {
      0.0
    } else {
      probability_total / count.to_double()
    }
    let observed_rate = if count == 0 {
      0.0
    } else {
      positive.to_double() / count.to_double()
    }
    let gap = (mean_probability - observed_rate).abs()
    if count > 0 {
      calibration_error = calibration_error +
        gap * count.to_double() / probabilities.length().to_double()
      maximum_error = maximum_error.max(gap)
    }
    bins.push({
      lower,
      upper,
      count,
      positive,
      mean_probability,
      observed_rate,
      gap,
    })
  }
  {
    bins,
    brier_score: calibration_brier_score(probabilities, outcomes),
    expected_calibration_error: calibration_error,
    maximum_calibration_error: maximum_error,
    log_loss: binary_log_loss(probabilities, outcomes),
    observations: probabilities.length(),
  }
}

///|
pub struct ThresholdConfusionMatrix {
  true_positive : Int
  false_positive : Int
  true_negative : Int
  false_negative : Int
  threshold : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn threshold_confusion_matrix(
  scores : Array[Double],
  outcomes : Array[Bool],
  threshold : Double,
) -> ThresholdConfusionMatrix {
  if threshold < 0.0 || threshold > 1.0 {
    abort("threshold_confusion_matrix: threshold must be in [0, 1]")
  }
  calibration_validate(scores, outcomes)
  let mut true_positive = 0
  let mut false_positive = 0
  let mut true_negative = 0
  let mut false_negative = 0
  for index in 0..<scores.length() {
    let predicted = scores[index] >= threshold
    if predicted && outcomes[index] {
      true_positive = true_positive + 1
    }
    if predicted && !outcomes[index] {
      false_positive = false_positive + 1
    }
    if !predicted && !outcomes[index] {
      true_negative = true_negative + 1
    }
    if !predicted && outcomes[index] {
      false_negative = false_negative + 1
    }
  }
  { true_positive, false_positive, true_negative, false_negative, threshold }
}

///|
pub fn ThresholdConfusionMatrix::precision(
  self : ThresholdConfusionMatrix,
) -> Double {
  let denominator = self.true_positive + self.false_positive
  if denominator == 0 {
    0.0
  } else {
    self.true_positive.to_double() / denominator.to_double()
  }
}

///|
pub fn ThresholdConfusionMatrix::recall(
  self : ThresholdConfusionMatrix,
) -> Double {
  let denominator = self.true_positive + self.false_negative
  if denominator == 0 {
    0.0
  } else {
    self.true_positive.to_double() / denominator.to_double()
  }
}

///|
pub fn ThresholdConfusionMatrix::specificity(
  self : ThresholdConfusionMatrix,
) -> Double {
  let denominator = self.true_negative + self.false_positive
  if denominator == 0 {
    0.0
  } else {
    self.true_negative.to_double() / denominator.to_double()
  }
}

///|
pub fn ThresholdConfusionMatrix::f1(self : ThresholdConfusionMatrix) -> Double {
  let precision = self.precision()
  let recall = self.recall()
  if precision + recall == 0.0 {
    0.0
  } else {
    2.0 * precision * recall / (precision + recall)
  }
}

///|
pub fn ThresholdConfusionMatrix::accuracy(
  self : ThresholdConfusionMatrix,
) -> Double {
  let total = self.true_positive +
    self.false_positive +
    self.true_negative +
    self.false_negative
  if total == 0 {
    0.0
  } else {
    (self.true_positive + self.true_negative).to_double() / total.to_double()
  }
}

///|
pub struct ThresholdPoint {
  threshold : Double
  metrics : ThresholdConfusionMatrix
  predicted_positive_rate : Double
  utility : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn threshold_curve(
  scores : Array[Double],
  outcomes : Array[Bool],
  steps : Int,
) -> Array[ThresholdPoint] {
  calibration_validate(scores, outcomes)
  if steps <= 0 {
    abort("threshold_curve: steps must be positive")
  }
  let result : Array[ThresholdPoint] = []
  for step in 0..<=steps {
    let threshold = 1.0 - step.to_double() / steps.to_double()
    let metrics = threshold_confusion_matrix(scores, outcomes, threshold)
    let rate = (metrics.true_positive + metrics.false_positive).to_double() /
      scores.length().to_double()
    result.push({
      threshold,
      metrics,
      predicted_positive_rate: rate,
      utility: metrics.f1(),
    })
  }
  result
}

///|
pub struct ThresholdCost {
  false_positive : Double
  false_negative : Double
  true_positive : Double
  true_negative : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn ThresholdCost::new(
  false_positive : Double,
  false_negative : Double,
  true_positive : Double,
  true_negative : Double,
) -> ThresholdCost {
  if false_positive < 0.0 || false_negative < 0.0 {
    abort("ThresholdCost: error costs must be non-negative")
  }
  { false_positive, false_negative, true_positive, true_negative }
}

///|
pub fn threshold_utility(
  metrics : ThresholdConfusionMatrix,
  cost : ThresholdCost,
) -> Double {
  metrics.true_positive.to_double() * cost.true_positive +
  metrics.true_negative.to_double() * cost.true_negative -
  metrics.false_positive.to_double() * cost.false_positive -
  metrics.false_negative.to_double() * cost.false_negative
}

///|
pub fn best_threshold(
  scores : Array[Double],
  outcomes : Array[Bool],
  cost : ThresholdCost,
  steps : Int,
) -> ThresholdPoint {
  let points = threshold_curve(scores, outcomes, steps)
  let mut best = points[0]
  let mut best_utility = threshold_utility(best.metrics, cost)
  for point in points.iter() {
    let utility = threshold_utility(point.metrics, cost)
    if utility > best_utility {
      best = point
      best_utility = utility
    }
  }
  { ..best, utility: best_utility }
}

///|
pub struct PlattCalibrator {
  slope : Double
  intercept : Double
  iterations : Int
  converged : Bool
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn PlattCalibrator::new() -> PlattCalibrator {
  { slope: 1.0, intercept: 0.0, iterations: 0, converged: false }
}

///|
pub fn PlattCalibrator::apply(self : PlattCalibrator, score : Double) -> Double {
  let linear = self.slope * score + self.intercept
  let probability = if linear >= 0.0 {
    1.0 / (1.0 + @math.pow(2.718281828459045, 0.0 - linear))
  } else {
    let exponential = @math.pow(2.718281828459045, linear)
    exponential / (1.0 + exponential)
  }
  probability.max(0.0).min(1.0)
}

///|
pub fn PlattCalibrator::transform(
  self : PlattCalibrator,
  scores : Array[Double],
) -> Array[Double] {
  scores.map(fn(score) { self.apply(score) })
}

///|
/// Fits a two-parameter logistic calibration map with damped Newton updates.
pub fn fit_platt_calibrator(
  scores : Array[Double],
  outcomes : Array[Bool],
  max_iterations : Int,
  tolerance : Double,
) -> PlattCalibrator {
  if scores.length() == 0 || scores.length() != outcomes.length() {
    abort("fit_platt_calibrator: scores and outcomes must be aligned")
  }
  if max_iterations <= 0 || tolerance <= 0.0 {
    abort("fit_platt_calibrator: invalid optimization settings")
  }
  let mut slope = 1.0
  let mut intercept = 0.0
  let mut iteration = 0
  let mut converged = false
  while iteration < max_iterations && !converged {
    let mut gradient_slope = 0.0
    let mut gradient_intercept = 0.0
    let mut hessian_ss = 0.000001
    let mut hessian_si = 0.0
    let mut hessian_ii = 0.000001
    for index in 0..<scores.length() {
      let score = scores[index]
      let linear = slope * score + intercept
      let probability = if linear >= 0.0 {
        1.0 / (1.0 + @math.pow(2.718281828459045, 0.0 - linear))
      } else {
        let exponential = @math.pow(2.718281828459045, linear)
        exponential / (1.0 + exponential)
      }
      let target = if outcomes[index] { 1.0 } else { 0.0 }
      let residual = probability - target
      let curvature = probability * (1.0 - probability)
      gradient_slope = gradient_slope + residual * score
      gradient_intercept = gradient_intercept + residual
      hessian_ss = hessian_ss + curvature * score * score
      hessian_si = hessian_si + curvature * score
      hessian_ii = hessian_ii + curvature
    }
    let determinant = hessian_ss * hessian_ii - hessian_si * hessian_si
    if determinant <= 0.0 {
      break
    }
    let delta_slope = (
        hessian_ii * gradient_slope - hessian_si * gradient_intercept
      ) /
      determinant
    let delta_intercept = (
        hessian_ss * gradient_intercept - hessian_si * gradient_slope
      ) /
      determinant
    slope = slope - delta_slope
    intercept = intercept - delta_intercept
    converged = delta_slope.abs().max(delta_intercept.abs()) <= tolerance
    iteration = iteration + 1
  }
  { slope, intercept, iterations: iteration, converged }
}

///|
pub struct IsotonicPoint {
  score : Double
  probability : Double
  weight : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
/// Pool-adjacent-violators calibration. It preserves monotonicity and is a
/// good default when scores are already rank-ordered but poorly scaled.
pub fn fit_isotonic_calibrator(
  scores : Array[Double],
  outcomes : Array[Bool],
) -> Array[IsotonicPoint] {
  if scores.length() == 0 || scores.length() != outcomes.length() {
    abort("fit_isotonic_calibrator: scores and outcomes must be aligned")
  }
  let order : Array[Int] = []
  for index in 0..<scores.length() {
    order.push(index)
  }
  for left in 0..<order.length() {
    for right in (left + 1)..<order.length() {
      if scores[order[right]] < scores[order[left]] {
        let swap = order[left]
        order[left] = order[right]
        order[right] = swap
      }
    }
  }
  let blocks : Array[IsotonicPoint] = []
  for position in 0..<order.length() {
    let index = order[position]
    let initial = {
      score: scores[index],
      probability: if outcomes[index] {
        1.0
      } else {
        0.0
      },
      weight: 1,
    }
    blocks.push(initial)
    while blocks.length() >= 2 {
      let right = blocks[blocks.length() - 1]
      let left = blocks[blocks.length() - 2]
      if left.probability <= right.probability {
        break
      }
      ignore(blocks.remove(blocks.length() - 1))
      ignore(blocks.remove(blocks.length() - 1))
      let weight = left.weight + right.weight
      blocks.push({
        score: (
          left.score * left.weight.to_double() +
          right.score * right.weight.to_double()
        ) /
        weight.to_double(),
        probability: (
          left.probability * left.weight.to_double() +
          right.probability * right.weight.to_double()
        ) /
        weight.to_double(),
        weight,
      })
    }
  }
  blocks
}

///|
pub fn apply_isotonic_calibrator(
  calibrator : Array[IsotonicPoint],
  scores : Array[Double],
) -> Array[Double] {
  if calibrator.length() == 0 {
    abort("apply_isotonic_calibrator: calibrator must not be empty")
  }
  scores.map(fn(score) {
    let mut chosen = calibrator[0].probability
    for point in calibrator.iter() {
      if score >= point.score {
        chosen = point.probability
      }
    }
    chosen
  })
}

///|
pub fn roc_auc(scores : Array[Double], outcomes : Array[Bool]) -> Double {
  calibration_validate(scores, outcomes)
  let positives = outcomes.filter(fn(value) { value }).length()
  let negatives = outcomes.length() - positives
  if positives == 0 || negatives == 0 {
    return 0.5
  }
  let mut concordant = 0.0
  let mut ties = 0.0
  for left in 0..<scores.length() {
    if outcomes[left] {
      for right in 0..<scores.length() {
        if !outcomes[right] {
          if scores[left] > scores[right] {
            concordant = concordant + 1.0
          }
          if scores[left] == scores[right] {
            ties = ties + 1.0
          }
        }
      }
    }
  }
  (concordant + ties / 2.0) / (positives * negatives).to_double()
}

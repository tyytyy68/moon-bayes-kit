///|
/// Predictive uncertainty, conformal calibration, and interval diagnostics.
pub enum IntervalMethod {
  Gaussian
  Empirical
  Conformal
  Bootstrap
  Quantile
} derive(Debug, Eq, ToJson, FromJson)

///|
fn uncertainty_log(value : Double) -> Double {
  if value <= 0.0 {
    abort("uncertainty_log: value must be positive")
  }
  let ratio = (value - 1.0) / (value + 1.0)
  let square = ratio * ratio
  let mut term = ratio
  let mut total = 0.0
  for index in 0..<24 {
    total = total + term / (2 * index + 1).to_double()
    term = term * square
  }
  2.0 * total
}

///|
pub struct PredictionInterval {
  prediction : Double
  lower : Double
  upper : Double
  confidence : Double
  interval_method : IntervalMethod
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn PredictionInterval::new(
  prediction : Double,
  lower : Double,
  upper : Double,
  confidence : Double,
  interval_method : IntervalMethod,
) -> PredictionInterval {
  if lower > upper || confidence <= 0.0 || confidence >= 1.0 {
    abort("PredictionInterval: invalid interval")
  }
  { prediction, lower, upper, confidence, interval_method }
}

///|
pub fn PredictionInterval::width(self : PredictionInterval) -> Double {
  self.upper - self.lower
}

///|
pub fn PredictionInterval::contains(
  self : PredictionInterval,
  value : Double,
) -> Bool {
  value >= self.lower && value <= self.upper
}

///|
pub fn PredictionInterval::relative_width(self : PredictionInterval) -> Double {
  if self.prediction == 0.0 {
    self.width()
  } else {
    self.width() / self.prediction.abs()
  }
}

///|
pub fn gaussian_interval(
  prediction : Double,
  standard_error : Double,
  confidence : Double,
) -> PredictionInterval {
  if standard_error < 0.0 {
    abort("gaussian_interval: standard error must be non-negative")
  }
  let z = normal_quantile((1.0 + confidence) / 2.0)
  PredictionInterval::new(
    prediction,
    prediction - z * standard_error,
    prediction + z * standard_error,
    confidence,
    IntervalMethod::Gaussian,
  )
}

///|
pub struct ConformalCalibrator {
  residuals : Array[Double]
  level : Double
  quantile : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn ConformalCalibrator::fit(
  residuals : Array[Double],
  confidence : Double,
) -> ConformalCalibrator {
  if residuals.length() == 0 || confidence <= 0.0 || confidence >= 1.0 {
    abort("ConformalCalibrator: invalid inputs")
  }
  let absolute = residuals.map(fn(value) { value.abs() })
  let quantile = empirical_quantile(absolute, confidence)
  { residuals: absolute, level: confidence, quantile }
}

///|
pub fn ConformalCalibrator::interval(
  self : ConformalCalibrator,
  prediction : Double,
) -> PredictionInterval {
  PredictionInterval::new(
    prediction,
    prediction - self.quantile,
    prediction + self.quantile,
    self.level,
    IntervalMethod::Conformal,
  )
}

///|
pub fn ConformalCalibrator::coverage(
  self : ConformalCalibrator,
  actual : Array[Double],
  predicted : Array[Double],
) -> Double {
  if actual.length() != predicted.length() || actual.length() == 0 {
    abort("ConformalCalibrator: lengths must match")
  }
  let mut covered = 0
  for index in 0..<actual.length() {
    if (actual[index] - predicted[index]).abs() <= self.quantile {
      covered = covered + 1
    }
  }
  covered.to_double() / actual.length().to_double()
}

///|
pub struct UncertaintyCalibrationBin {
  lower : Double
  upper : Double
  count : Int
  predicted_mean : Double
  observed_rate : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn calibration_bins(
  probabilities : Array[Double],
  outcomes : Array[Bool],
  bins : Int,
) -> Array[UncertaintyCalibrationBin] {
  if probabilities.length() != outcomes.length() || bins <= 0 {
    abort("calibration_bins: invalid inputs")
  }
  let result : Array[UncertaintyCalibrationBin] = []
  for bucket in 0..<bins {
    let lower = bucket.to_double() / bins.to_double()
    let upper = (bucket + 1).to_double() / bins.to_double()
    let mut count = 0
    let mut predicted = 0.0
    let mut observed = 0
    for index in 0..<probabilities.length() {
      let last = bucket == bins - 1 && probabilities[index] == upper
      if probabilities[index] >= lower && (probabilities[index] < upper || last) {
        count = count + 1
        predicted = predicted + probabilities[index]
        if outcomes[index] {
          observed = observed + 1
        }
      }
    }
    result.push({
      lower,
      upper,
      count,
      predicted_mean: if count == 0 {
        0.0
      } else {
        predicted / count.to_double()
      },
      observed_rate: if count == 0 {
        0.0
      } else {
        observed.to_double() / count.to_double()
      },
    })
  }
  result
}

///|
pub fn expected_calibration_error(
  bins : Array[UncertaintyCalibrationBin],
) -> Double {
  let total = bins.fold(init=0, (count, bin) => count + bin.count)
  if total == 0 {
    return 0.0
  }
  bins.fold(init=0.0, (error, bin) => {
    error +
    bin.count.to_double() /
    total.to_double() *
    (bin.predicted_mean - bin.observed_rate).abs()
  })
}

///|
pub fn maximum_calibration_error(
  bins : Array[UncertaintyCalibrationBin],
) -> Double {
  bins.fold(init=0.0, (error, bin) => {
    error.max((bin.predicted_mean - bin.observed_rate).abs())
  })
}

///|
pub struct CoverageReport {
  count : Int
  covered : Int
  coverage : Double
  target : Double
  error : Double
  average_width : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn evaluate_intervals(
  intervals : Array[PredictionInterval],
  actual : Array[Double],
  target : Double,
) -> CoverageReport {
  if intervals.length() != actual.length() ||
    intervals.length() == 0 ||
    target <= 0.0 ||
    target >= 1.0 {
    abort("evaluate_intervals: invalid inputs")
  }
  let mut covered = 0
  let mut width = 0.0
  for index in 0..<actual.length() {
    if intervals[index].contains(actual[index]) {
      covered = covered + 1
    }
    width = width + intervals[index].width()
  }
  let coverage = covered.to_double() / actual.length().to_double()
  {
    count: actual.length(),
    covered,
    coverage,
    target,
    error: coverage - target,
    average_width: width / actual.length().to_double(),
  }
}

///|
pub fn interval_score(
  interval : PredictionInterval,
  actual : Double,
  alpha : Double,
) -> Double {
  if alpha <= 0.0 || alpha >= 1.0 {
    abort("interval_score: alpha must be in (0, 1)")
  }
  let penalty_lower = if actual < interval.lower {
    2.0 / alpha * (interval.lower - actual)
  } else {
    0.0
  }
  let penalty_upper = if actual > interval.upper {
    2.0 / alpha * (actual - interval.upper)
  } else {
    0.0
  }
  interval.width() + penalty_lower + penalty_upper
}

///|
pub fn mean_interval_score(
  intervals : Array[PredictionInterval],
  actual : Array[Double],
  alpha : Double,
) -> Double {
  if intervals.length() != actual.length() || intervals.length() == 0 {
    abort("mean_interval_score: lengths must match")
  }
  let mut total = 0.0
  for index in 0..<actual.length() {
    total = total + interval_score(intervals[index], actual[index], alpha)
  }
  total / actual.length().to_double()
}

///|
pub struct QuantileLoss {
  quantile : Double
  mean_loss : Double
  observations : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn quantile_loss(
  actual : Double,
  predicted : Double,
  quantile : Double,
) -> Double {
  if quantile <= 0.0 || quantile >= 1.0 {
    abort("quantile_loss: quantile must be in (0, 1)")
  }
  let error = actual - predicted
  if error >= 0.0 {
    quantile * error
  } else {
    (1.0 - quantile) * error.abs()
  }
}

///|
pub fn evaluate_quantile(
  actual : Array[Double],
  predicted : Array[Double],
  quantile : Double,
) -> QuantileLoss {
  if actual.length() != predicted.length() || actual.length() == 0 {
    abort("evaluate_quantile: lengths must match")
  }
  let mut total = 0.0
  for index in 0..<actual.length() {
    total = total + quantile_loss(actual[index], predicted[index], quantile)
  }
  {
    quantile,
    mean_loss: total / actual.length().to_double(),
    observations: actual.length(),
  }
}

///|
pub struct UncertaintyBootstrapSummary {
  estimate : Double
  standard_error : Double
  lower : Double
  upper : Double
  samples : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn bootstrap_summary(
  estimates : Array[Double],
  confidence : Double,
) -> UncertaintyBootstrapSummary {
  if estimates.length() < 2 || confidence <= 0.0 || confidence >= 1.0 {
    abort("bootstrap_summary: invalid inputs")
  }
  let estimate = mean(estimates)
  let standard_error = variance(estimates).sqrt()
  {
    estimate,
    standard_error,
    lower: empirical_quantile(estimates, (1.0 - confidence) / 2.0),
    upper: empirical_quantile(estimates, (1.0 + confidence) / 2.0),
    samples: estimates.length(),
  }
}

///|
pub fn jackknife_estimates(
  values : Array[Double],
  statistic : (Array[Double]) -> Double,
) -> Array[Double] {
  if values.length() < 2 {
    abort("jackknife_estimates: at least two values required")
  }
  let result : Array[Double] = []
  for removed in 0..<values.length() {
    let sample : Array[Double] = []
    for index in 0..<values.length() {
      if index != removed {
        sample.push(values[index])
      }
    }
    result.push(statistic(sample))
  }
  result
}

///|
pub fn jackknife_bias(
  values : Array[Double],
  statistic : (Array[Double]) -> Double,
) -> Double {
  let full = statistic(values)
  let leave_one_out = jackknife_estimates(values, statistic)
  mean(leave_one_out) - full
}

///|
pub struct ReliabilityReport {
  brier : Double
  log_loss : Double
  ece : Double
  mce : Double
  resolution : Double
  refinement : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn reliability_report(
  probabilities : Array[Double],
  outcomes : Array[Bool],
  bins : Int,
) -> ReliabilityReport {
  if probabilities.length() != outcomes.length() || probabilities.length() == 0 {
    abort("reliability_report: lengths must match")
  }
  let mut brier = 0.0
  let mut log_loss = 0.0
  for index in 0..<probabilities.length() {
    let probability = probabilities[index]
      .max(0.000000000001)
      .min(0.999999999999)
    let outcome = if outcomes[index] { 1.0 } else { 0.0 }
    brier = brier + (probability - outcome) * (probability - outcome)
    log_loss = log_loss -
      outcome * uncertainty_log(probability) -
      (1.0 - outcome) * uncertainty_log(1.0 - probability)
  }
  let grouped = calibration_bins(probabilities, outcomes, bins)
  let base = if outcomes.filter(fn(value) { value }).length() == 0 {
    0.0
  } else {
    outcomes.filter(fn(value) { value }).length().to_double() /
    outcomes.length().to_double()
  }
  let resolution = grouped.fold(init=0.0, (total, bin) => {
    total +
    bin.count.to_double() /
    probabilities.length().to_double() *
    (bin.observed_rate - base) *
    (bin.observed_rate - base)
  })
  let refinement = base * (1.0 - base)
  {
    brier: brier / probabilities.length().to_double(),
    log_loss: log_loss / probabilities.length().to_double(),
    ece: expected_calibration_error(grouped),
    mce: maximum_calibration_error(grouped),
    resolution,
    refinement,
  }
}

///|
pub fn sharpness(probabilities : Array[Double]) -> Double {
  if probabilities.length() == 0 {
    return 0.0
  }
  variance(probabilities)
}

///|
pub fn prediction_variance_decomposition(
  predictions : Array[Array[Double]],
) -> (Double, Double) {
  if predictions.length() == 0 {
    abort("prediction_variance_decomposition: empty ensemble")
  }
  let members = predictions.length()
  let points = predictions[0].length()
  if points == 0 {
    abort("prediction_variance_decomposition: empty predictions")
  }
  let means : Array[Double] = []
  for point in 0..<points {
    let values : Array[Double] = []
    for ensemble_index in 0..<members {
      values.push(predictions[ensemble_index][point])
    }
    means.push(mean(values))
  }
  let mut epistemic = 0.0
  for ensemble_index in 0..<members {
    for point in 0..<points {
      let difference = predictions[ensemble_index][point] - means[point]
      epistemic = epistemic + difference * difference
    }
  }
  epistemic = epistemic / (members * points).to_double()
  let aleatoric = variance(means)
  (epistemic, aleatoric)
}

///|
pub fn conformal_quantile(
  residuals : Array[Double],
  confidence : Double,
) -> Double {
  if residuals.length() == 0 {
    abort("conformal_quantile: residuals cannot be empty")
  }
  empirical_quantile(residuals.map(fn(value) { value.abs() }), confidence)
}

///|
pub fn calibrate_scale(
  predicted : Array[Double],
  actual : Array[Double],
  target : Double,
) -> Double {
  if predicted.length() != actual.length() || predicted.length() == 0 {
    abort("calibrate_scale: lengths must match")
  }
  let mut squared = 0.0
  for index in 0..<predicted.length() {
    squared = squared +
      (actual[index] - predicted[index]) * (actual[index] - predicted[index])
  }
  let root_mean_squared = (squared / predicted.length().to_double()).sqrt()
  if target <= 0.0 {
    root_mean_squared
  } else {
    target / root_mean_squared.max(0.000000000001)
  }
}

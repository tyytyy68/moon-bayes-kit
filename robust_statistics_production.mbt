///|
/// Robust estimators for telemetry and noisy scientific data. They provide
/// bounded-influence alternatives to ordinary moments and return the
/// diagnostics needed to decide whether an observation should be reviewed.
pub struct RobustLocation {
  estimate : Double
  scale : Double
  observations : Int
  retained : Int
  estimator : String
} derive(Debug, Eq, ToJson, FromJson)

///|
pub struct RobustObservation {
  value : Double
  score : Double
  outlier : Bool
  lower_fence : Double
  upper_fence : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
fn robust_sorted(values : Array[Double]) -> Array[Double] {
  if values.length() == 0 {
    abort("robust_sorted: values must not be empty")
  }
  let result = values.copy()
  result.sort()
  result
}

///|
fn robust_subarray(
  values : Array[Double],
  start : Int,
  end : Int,
) -> Array[Double] {
  if start < 0 || end < start || end > values.length() {
    abort("robust_subarray: invalid bounds")
  }
  let result : Array[Double] = []
  for index in start..<end {
    result.push(values[index])
  }
  result
}

///|
pub fn robust_median(values : Array[Double]) -> Double {
  let sorted = robust_sorted(values)
  let middle = sorted.length() / 2
  if sorted.length() % 2 == 0 {
    (sorted[middle - 1] + sorted[middle]) / 2.0
  } else {
    sorted[middle]
  }
}

///|
pub fn robust_mad(values : Array[Double]) -> Double {
  let center = robust_median(values)
  let deviations = values.map(fn(value) { (value - center).abs() })
  robust_median(deviations) * 1.4826
}

///|
pub fn robust_trimmed_mean(
  values : Array[Double],
  trim_fraction : Double,
) -> RobustLocation {
  if trim_fraction < 0.0 || trim_fraction >= 0.5 {
    abort("trimmed_mean: trim fraction must be in [0, 0.5)")
  }
  let sorted = robust_sorted(values)
  let trim = (sorted.length().to_double() * trim_fraction).floor().to_int()
  let end = sorted.length() - trim
  let retained = robust_subarray(sorted, trim, end)
  {
    estimate: mean(retained),
    scale: if retained.length() < 2 {
      0.0
    } else {
      variance(retained).sqrt()
    },
    observations: values.length(),
    retained: retained.length(),
    estimator: "trimmed_mean",
  }
}

///|
pub fn winsorized_mean(
  values : Array[Double],
  tail_fraction : Double,
) -> RobustLocation {
  if tail_fraction < 0.0 || tail_fraction >= 0.5 {
    abort("winsorized_mean: tail fraction must be in [0, 0.5)")
  }
  let sorted = robust_sorted(values)
  let tail = (sorted.length().to_double() * tail_fraction).floor().to_int()
  let lower = sorted[tail]
  let upper = sorted[sorted.length() - tail - 1]
  let adjusted = values.map(fn(value) { value.max(lower).min(upper) })
  {
    estimate: mean(adjusted),
    scale: if adjusted.length() < 2 {
      0.0
    } else {
      variance(adjusted).sqrt()
    },
    observations: values.length(),
    retained: adjusted.length(),
    estimator: "winsorized_mean",
  }
}

///|
pub fn huber_location(
  values : Array[Double],
  tuning : Double,
  tolerance : Double,
  max_iterations : Int,
) -> RobustLocation {
  if values.length() == 0 ||
    tuning <= 0.0 ||
    tolerance <= 0.0 ||
    max_iterations <= 0 {
    abort("huber_location: invalid data or convergence settings")
  }
  let mut location = robust_median(values)
  let scale = robust_mad(values).max(0.000000000001)
  let mut iterations = 0
  let mut converged = false
  while iterations < max_iterations && !converged {
    let mut numerator = 0.0
    let mut denominator = 0.0
    for value in values.iter() {
      let standardized = (value - location) / scale
      let weight = if standardized.abs() <= tuning {
        1.0
      } else {
        tuning / standardized.abs()
      }
      numerator = numerator + weight * value
      denominator = denominator + weight
    }
    let next = numerator / denominator
    converged = (next - location).abs() <= tolerance
    location = next
    iterations = iterations + 1
  }
  {
    estimate: location,
    scale,
    observations: values.length(),
    retained: values.length(),
    estimator: "huber",
  }
}

///|
pub fn tukey_fences(
  values : Array[Double],
  multiplier : Double,
) -> (Double, Double) {
  if multiplier < 0.0 {
    abort("tukey_fences: multiplier must be non-negative")
  }
  let sorted = robust_sorted(values)
  let middle = sorted.length() / 2
  let lower_half = robust_subarray(sorted, 0, middle)
  let upper_half = if sorted.length() % 2 == 0 {
    robust_subarray(sorted, middle, sorted.length())
  } else {
    robust_subarray(sorted, middle + 1, sorted.length())
  }
  let q1 = robust_median(lower_half)
  let q3 = robust_median(upper_half)
  let spread = q3 - q1
  (q1 - multiplier * spread, q3 + multiplier * spread)
}

///|
pub fn robust_observations(
  values : Array[Double],
  multiplier : Double,
) -> Array[RobustObservation] {
  let (lower, upper) = tukey_fences(values, multiplier)
  let center = robust_median(values)
  let scale = robust_mad(values).max(0.000000000001)
  values.map(fn(value) {
    {
      value,
      score: (value - center).abs() / scale,
      outlier: value < lower || value > upper,
      lower_fence: lower,
      upper_fence: upper,
    }
  })
}

///|
pub struct RobustScaler {
  center : Double
  scale : Double
  clip : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn RobustScaler::fit(values : Array[Double], clip : Double) -> RobustScaler {
  if clip <= 0.0 {
    abort("RobustScaler: clip must be positive")
  }
  {
    center: robust_median(values),
    scale: robust_mad(values).max(0.000000000001),
    clip,
  }
}

///|
pub fn RobustScaler::transform(self : RobustScaler, value : Double) -> Double {
  ((value - self.center) / self.scale).max(0.0 - self.clip).min(self.clip)
}

///|
pub fn RobustScaler::transform_all(
  self : RobustScaler,
  values : Array[Double],
) -> Array[Double] {
  values.map(fn(value) { self.transform(value) })
}

///|
pub fn RobustScaler::inverse(self : RobustScaler, value : Double) -> Double {
  value * self.scale + self.center
}

///|
pub struct RobustCorrelation {
  correlation : Double
  covariance : Double
  left_scale : Double
  right_scale : Double
  valid_pairs : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn robust_correlation(
  left : Array[Double],
  right : Array[Double],
) -> RobustCorrelation {
  if left.length() != right.length() || left.length() < 2 {
    abort("robust_correlation: aligned pairs are required")
  }
  let left_center = robust_median(left)
  let right_center = robust_median(right)
  let left_scale = robust_mad(left).max(0.000000000001)
  let right_scale = robust_mad(right).max(0.000000000001)
  let mut covariance_value = 0.0
  for index in 0..<left.length() {
    let left_weight = 1.0 /
      (1.0 + ((left[index] - left_center) / left_scale).abs())
    let right_weight = 1.0 /
      (1.0 + ((right[index] - right_center) / right_scale).abs())
    covariance_value = covariance_value +
      left_weight *
      right_weight *
      (left[index] - left_center) *
      (right[index] - right_center)
  }
  covariance_value = covariance_value / left.length().to_double()
  {
    correlation: covariance_value / (left_scale * right_scale),
    covariance: covariance_value,
    left_scale,
    right_scale,
    valid_pairs: left.length(),
  }
}

///|
pub struct RobustWindow {
  capacity : Int
  values : Array[Double]
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn RobustWindow::new(capacity : Int) -> RobustWindow {
  if capacity <= 0 {
    abort("RobustWindow: capacity must be positive")
  }
  { capacity, values: [] }
}

///|
pub fn RobustWindow::push(self : RobustWindow, value : Double) -> RobustWindow {
  let values = self.values.copy()
  values.push(value)
  if values.length() > self.capacity {
    ignore(values.remove(0))
  }
  { ..self, values, }
}

///|
pub fn RobustWindow::location(self : RobustWindow) -> RobustLocation {
  if self.values.length() == 0 {
    abort("RobustWindow::location: no observations")
  }
  huber_location(self.values, 1.345, 0.000001, 50)
}

///|
pub fn RobustWindow::outlier_rate(
  self : RobustWindow,
  multiplier : Double,
) -> Double {
  if self.values.length() == 0 {
    return 0.0
  }
  let outliers = robust_observations(self.values, multiplier)
    .filter(fn(item) { item.outlier })
    .length()
  outliers.to_double() / self.values.length().to_double()
}

///|
pub struct RobustDrift {
  baseline : RobustLocation
  current : RobustLocation
  location_shift : Double
  scale_ratio : Double
  drifted : Bool
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn compare_robust_windows(
  baseline : Array[Double],
  current : Array[Double],
  shift_tolerance : Double,
  scale_ratio_tolerance : Double,
) -> RobustDrift {
  if shift_tolerance < 0.0 || scale_ratio_tolerance < 0.0 {
    abort("compare_robust_windows: tolerances must be non-negative")
  }
  let baseline_summary = huber_location(baseline, 1.345, 0.000001, 50)
  let current_summary = huber_location(current, 1.345, 0.000001, 50)
  let scale_ratio = if baseline_summary.scale == 0.0 {
    1.0
  } else {
    current_summary.scale / baseline_summary.scale
  }
  let drifted = (current_summary.estimate - baseline_summary.estimate).abs() >
    shift_tolerance ||
    (scale_ratio - 1.0).abs() > scale_ratio_tolerance
  {
    baseline: baseline_summary,
    current: current_summary,
    location_shift: current_summary.estimate - baseline_summary.estimate,
    scale_ratio,
    drifted,
  }
}

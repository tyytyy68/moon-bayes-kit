///|
/// Result of a deterministic train/test split.
pub struct SplitResult {
  train_indices : Array[Int]
  test_indices : Array[Int]
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn SplitResult::train_indices(self : SplitResult) -> Array[Int] {
  self.train_indices.copy()
}

///|
pub fn SplitResult::test_indices(self : SplitResult) -> Array[Int] {
  self.test_indices.copy()
}

///|
pub fn SplitResult::train_size(self : SplitResult) -> Int {
  self.train_indices.length()
}

///|
pub fn SplitResult::test_size(self : SplitResult) -> Int {
  self.test_indices.length()
}

///|
/// Splits indices in their original order. This is preferable for time series
/// data where random shuffling would leak future observations.
pub fn chronological_split(size : Int, test_fraction : Double) -> SplitResult {
  if size < 0 || test_fraction < 0.0 || test_fraction >= 1.0 {
    abort("chronological_split: invalid size or fraction")
  }
  let test_size = (size.to_double() * test_fraction).ceil().to_int()
  let split = size - test_size
  let train = []
  let test_values : Array[Int] = []
  for index in 0..<size {
    if index < split {
      train.push(index)
    } else {
      test_values.push(index)
    }
  }
  { train_indices: train, test_indices: test_values }
}

///|
/// Creates contiguous folds for walk-forward validation.
pub fn walk_forward_folds(size : Int, folds : Int) -> Array[SplitResult] {
  if size <= 0 || folds <= 0 || folds >= size {
    abort("walk_forward_folds: invalid size or folds")
  }
  let result = []
  let step = size / folds
  for fold in 1..<=folds {
    let test_start = fold * step
    let test_end = if fold == folds { size } else { (fold + 1) * step }
    let train = []
    let test_values : Array[Int] = []
    for index in 0..<size {
      if index < test_start {
        train.push(index)
      } else if index < test_end {
        test_values.push(index)
      }
    }
    result.push({ train_indices: train, test_indices: test_values })
  }
  result
}

///|
pub struct RegressionReport {
  count : Int
  mae : Double
  rmse : Double
  mean_actual : Double
  mean_prediction : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn RegressionReport::from_predictions(
  predicted : Array[Double],
  actual : Array[Double],
) -> RegressionReport {
  if predicted.length() != actual.length() {
    abort("RegressionReport: lengths must match")
  }
  {
    count: predicted.length(),
    mae: mean_absolute_error(predicted, actual),
    rmse: root_mean_squared_error(predicted, actual),
    mean_actual: mean(actual),
    mean_prediction: mean(predicted),
  }
}

///|
pub fn RegressionReport::count(self : RegressionReport) -> Int {
  self.count
}

///|
pub fn RegressionReport::mae(self : RegressionReport) -> Double {
  self.mae
}

///|
pub fn RegressionReport::rmse(self : RegressionReport) -> Double {
  self.rmse
}

///|
pub fn RegressionReport::bias(self : RegressionReport) -> Double {
  self.mean_prediction - self.mean_actual
}

///|
pub fn calibration_error(
  probabilities : Array[Double],
  observed : Array[Bool],
  bins : Int,
) -> Double {
  if bins <= 0 || probabilities.length() != observed.length() {
    abort("calibration_error: invalid inputs")
  }
  if probabilities.length() == 0 {
    return 0.0
  }
  let counts = Array::make(bins, 0)
  let predicted = Array::make(bins, 0.0)
  let actual = Array::make(bins, 0.0)
  for index in 0..<probabilities.length() {
    if probabilities[index] < 0.0 || probabilities[index] > 1.0 {
      abort("calibration_error: probability out of range")
    }
    let bin = (probabilities[index] * bins.to_double())
      .floor()
      .to_int()
      .min(bins - 1)
    counts[bin] = counts[bin] + 1
    predicted[bin] = predicted[bin] + probabilities[index]
    if observed[index] {
      actual[bin] = actual[bin] + 1.0
    }
  }
  let mut error = 0.0
  for bin in 0..<bins {
    if counts[bin] > 0 {
      error = error +
        (predicted[bin] - actual[bin]).abs() /
        probabilities.length().to_double()
    }
  }
  error
}

///|
pub fn rank_descending(values : Array[Double]) -> Array[Int] {
  let indices = []
  for index in 0..<values.length() {
    indices.push(index)
  }
  for i in 0..<indices.length() {
    for j in (i + 1)..<indices.length() {
      if values[indices[j]] > values[indices[i]] {
        let temporary = indices[i]
        indices[i] = indices[j]
        indices[j] = temporary
      }
    }
  }
  indices
}

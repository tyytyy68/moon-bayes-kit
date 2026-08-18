///|
/// A confusion matrix for binary decisions.
pub struct ConfusionMatrix {
  true_positive : Int
  true_negative : Int
  false_positive : Int
  false_negative : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn ConfusionMatrix::new() -> ConfusionMatrix {
  { true_positive: 0, true_negative: 0, false_positive: 0, false_negative: 0 }
}

///|
pub fn ConfusionMatrix::add(
  self : ConfusionMatrix,
  actual : Bool,
  predicted : Bool,
) -> ConfusionMatrix {
  if actual && predicted {
    { ..self, true_positive: self.true_positive + 1 }
  } else if !actual && !predicted {
    { ..self, true_negative: self.true_negative + 1 }
  } else if predicted {
    { ..self, false_positive: self.false_positive + 1 }
  } else {
    { ..self, false_negative: self.false_negative + 1 }
  }
}

///|
pub fn ConfusionMatrix::add_all(
  self : ConfusionMatrix,
  actual : Array[Bool],
  predicted : Array[Bool],
) -> ConfusionMatrix {
  if actual.length() != predicted.length() {
    abort("ConfusionMatrix: lengths must match")
  }
  let mut result = self
  for i in 0..<actual.length() {
    result = result.add(actual[i], predicted[i])
  }
  result
}

///|
pub fn ConfusionMatrix::total(self : ConfusionMatrix) -> Int {
  self.true_positive +
  self.true_negative +
  self.false_positive +
  self.false_negative
}

///|
pub fn ConfusionMatrix::accuracy(self : ConfusionMatrix) -> Double {
  if self.total() == 0 {
    0.0
  } else {
    (self.true_positive + self.true_negative).to_double() /
    self.total().to_double()
  }
}

///|
pub fn ConfusionMatrix::precision(self : ConfusionMatrix) -> Double {
  let denominator = self.true_positive + self.false_positive
  if denominator == 0 {
    0.0
  } else {
    self.true_positive.to_double() / denominator.to_double()
  }
}

///|
pub fn ConfusionMatrix::recall(self : ConfusionMatrix) -> Double {
  let denominator = self.true_positive + self.false_negative
  if denominator == 0 {
    0.0
  } else {
    self.true_positive.to_double() / denominator.to_double()
  }
}

///|
pub fn ConfusionMatrix::f1(self : ConfusionMatrix) -> Double {
  let p = self.precision()
  let r = self.recall()
  if p + r == 0.0 {
    0.0
  } else {
    2.0 * p * r / (p + r)
  }
}

///|
pub struct CalibrationBin {
  lower : Double
  upper : Double
  count : Int
  predicted_sum : Double
  observed_sum : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn CalibrationBin::new(lower : Double, upper : Double) -> CalibrationBin {
  if lower < 0.0 || upper > 1.0 || lower >= upper {
    abort("CalibrationBin: invalid interval")
  }
  { lower, upper, count: 0, predicted_sum: 0.0, observed_sum: 0.0 }
}

///|
pub fn CalibrationBin::add(
  self : CalibrationBin,
  probability : Double,
  observed : Bool,
) -> CalibrationBin {
  if probability < self.lower || probability > self.upper {
    abort("CalibrationBin: probability outside interval")
  }
  let observed_value = if observed { 1.0 } else { 0.0 }
  {
    ..self,
    count: self.count + 1,
    predicted_sum: self.predicted_sum + probability,
    observed_sum: self.observed_sum + observed_value,
  }
}

///|
pub fn CalibrationBin::count(self : CalibrationBin) -> Int {
  self.count
}

///|
pub fn CalibrationBin::predicted_mean(self : CalibrationBin) -> Double {
  if self.count == 0 {
    0.0
  } else {
    self.predicted_sum / self.count.to_double()
  }
}

///|
pub fn CalibrationBin::observed_rate(self : CalibrationBin) -> Double {
  if self.count == 0 {
    0.0
  } else {
    self.observed_sum / self.count.to_double()
  }
}

///|
pub fn CalibrationBin::gap(self : CalibrationBin) -> Double {
  (self.predicted_mean() - self.observed_rate()).abs()
}

///|
pub fn brier_score(
  probabilities : Array[Double],
  observed : Array[Bool],
) -> Double {
  if probabilities.length() != observed.length() {
    abort("brier_score: lengths must match")
  }
  if probabilities.length() == 0 {
    return 0.0
  }
  let mut total = 0.0
  for i in 0..<probabilities.length() {
    if probabilities[i] < 0.0 || probabilities[i] > 1.0 {
      abort("brier_score: probabilities must be in [0, 1]")
    }
    let target = if observed[i] { 1.0 } else { 0.0 }
    let error = probabilities[i] - target
    total = total + error * error
  }
  total / probabilities.length().to_double()
}

///|
pub fn mean_absolute_error(
  predicted : Array[Double],
  actual : Array[Double],
) -> Double {
  if predicted.length() != actual.length() {
    abort("mean_absolute_error: lengths must match")
  }
  if predicted.length() == 0 {
    return 0.0
  }
  let mut total = 0.0
  for i in 0..<predicted.length() {
    total = total + (predicted[i] - actual[i]).abs()
  }
  total / predicted.length().to_double()
}

///|
pub fn root_mean_squared_error(
  predicted : Array[Double],
  actual : Array[Double],
) -> Double {
  if predicted.length() != actual.length() {
    abort("root_mean_squared_error: lengths must match")
  }
  if predicted.length() == 0 {
    return 0.0
  }
  let mut total = 0.0
  for i in 0..<predicted.length() {
    let error = predicted[i] - actual[i]
    total = total + error * error
  }
  (total / predicted.length().to_double()).sqrt()
}

///|
pub fn log_loss(
  probabilities : Array[Double],
  observed : Array[Bool],
  epsilon? : Double = 0.000000000001,
) -> Double {
  // Uses a bounded natural-log approximation so the package stays dependency-free.
  if probabilities.length() != observed.length() {
    abort("log_loss: lengths must match")
  }
  if epsilon <= 0.0 || epsilon >= 0.5 {
    abort("log_loss: epsilon must be in (0, 0.5)")
  }
  if probabilities.length() == 0 {
    return 0.0
  }
  let mut total = 0.0
  for i in 0..<probabilities.length() {
    let probability = clamp(probabilities[i], epsilon, 1.0 - epsilon)
    let target = if observed[i] { probability } else { 1.0 - probability }
    total = total + negative_log_approx(target)
  }
  total / probabilities.length().to_double()
}

///|
fn negative_log_approx(value : Double) -> Double {
  // atanh series around one: -log(x) = -2 * (z + z^3/3 + ...), z=(x-1)/(x+1)
  let z = (value - 1.0) / (value + 1.0)
  let z2 = z * z
  let mut term = z
  let mut total = term
  for denominator in 3..<=25 {
    term = term * z2
    total = total + term / denominator.to_double()
  }
  -2.0 * total
}

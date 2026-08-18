///|
/// Exponentially weighted drift detector for an online metric.
pub struct EwmaDetector {
  decay : Double
  threshold : Double
  level : Double
  initialized : Bool
  updates : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn EwmaDetector::new(decay : Double, threshold : Double) -> EwmaDetector {
  if decay <= 0.0 || decay > 1.0 || threshold <= 0.0 {
    abort("EwmaDetector: invalid decay or threshold")
  }
  { decay, threshold, level: 0.0, initialized: false, updates: 0 }
}

///|
pub fn EwmaDetector::update(
  self : EwmaDetector,
  value : Double,
) -> EwmaDetector {
  let level = if self.initialized {
    self.decay * value + (1.0 - self.decay) * self.level
  } else {
    value
  }
  { ..self, level, initialized: true, updates: self.updates + 1 }
}

///|
pub fn EwmaDetector::level(self : EwmaDetector) -> Double {
  self.level
}

///|
pub fn EwmaDetector::updates(self : EwmaDetector) -> Int {
  self.updates
}

///|
pub fn EwmaDetector::deviation(self : EwmaDetector, value : Double) -> Double {
  (value - self.level).abs()
}

///|
pub fn EwmaDetector::is_drift(self : EwmaDetector, value : Double) -> Bool {
  self.deviation(value) > self.threshold
}

///|
pub fn EwmaDetector::reset(self : EwmaDetector) -> EwmaDetector {
  { ..self, level: 0.0, initialized: false, updates: 0 }
}

///|
/// CUSUM detector for a mean shift with a configurable allowance.
pub struct CusumDetector {
  target : Double
  allowance : Double
  threshold : Double
  positive : Double
  negative : Double
  updates : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn CusumDetector::new(
  target : Double,
  allowance : Double,
  threshold : Double,
) -> CusumDetector {
  if allowance < 0.0 || threshold <= 0.0 {
    abort("CusumDetector: invalid allowance or threshold")
  }
  { target, allowance, threshold, positive: 0.0, negative: 0.0, updates: 0 }
}

///|
pub fn CusumDetector::update(
  self : CusumDetector,
  value : Double,
) -> CusumDetector {
  let delta = value - self.target
  let positive = (self.positive + delta - self.allowance).max(0.0)
  let negative = (self.negative - delta - self.allowance).max(0.0)
  { ..self, positive, negative, updates: self.updates + 1 }
}

///|
pub fn CusumDetector::positive_score(self : CusumDetector) -> Double {
  self.positive
}

///|
pub fn CusumDetector::negative_score(self : CusumDetector) -> Double {
  self.negative
}

///|
pub fn CusumDetector::is_drift(self : CusumDetector) -> Bool {
  self.positive >= self.threshold || self.negative >= self.threshold
}

///|
pub fn CusumDetector::direction(self : CusumDetector) -> Int {
  if self.positive >= self.threshold {
    1
  } else if self.negative >= self.threshold {
    -1
  } else {
    0
  }
}

///|
pub fn CusumDetector::reset(self : CusumDetector) -> CusumDetector {
  { ..self, positive: 0.0, negative: 0.0, updates: 0 }
}

///|
pub fn detect_step(
  values : Array[Double],
  baseline : Double,
  threshold : Double,
) -> Int? {
  let detector = CusumDetector::new(baseline, 0.0, threshold)
  let mut current = detector
  for index, value in values {
    current = current.update(value)
    if current.is_drift() {
      return Some(index)
    }
  }
  None
}

///|
pub fn rolling_z_scores(values : Array[Double], window : Int) -> Array[Double] {
  if window <= 0 {
    abort("rolling_z_scores: window must be positive")
  }
  let result = Array::make(values.length(), 0.0)
  let mut rolling = RollingWindow::new(window)
  for index, value in values {
    rolling = rolling.push(value)
    let deviation = rolling.variance().sqrt()
    result[index] = if deviation == 0.0 {
      0.0
    } else {
      (value - rolling.mean()) / deviation
    }
  }
  result
}

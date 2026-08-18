///|
/// Fixed-capacity rolling numeric window for dashboards and online validation.
pub struct RollingWindow {
  capacity : Int
  values : Array[Double]
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn RollingWindow::new(capacity : Int) -> RollingWindow {
  if capacity <= 0 {
    abort("RollingWindow: capacity must be positive")
  }
  { capacity, values: [] }
}

///|
pub fn RollingWindow::capacity(self : RollingWindow) -> Int {
  self.capacity
}

///|
pub fn RollingWindow::len(self : RollingWindow) -> Int {
  self.values.length()
}

///|
pub fn RollingWindow::is_full(self : RollingWindow) -> Bool {
  self.len() == self.capacity
}

///|
pub fn RollingWindow::push(
  self : RollingWindow,
  value : Double,
) -> RollingWindow {
  let next = self.values.copy()
  next.push(value)
  if next.length() > self.capacity {
    ignore(next.remove(0))
  }
  { ..self, values: next }
}

///|
pub fn RollingWindow::push_all(
  self : RollingWindow,
  values : Array[Double],
) -> RollingWindow {
  values.fold(init=self, (window, value) => window.push(value))
}

///|
pub fn RollingWindow::values(self : RollingWindow) -> Array[Double] {
  self.values.copy()
}

///|
pub fn RollingWindow::stats(self : RollingWindow) -> OnlineStats {
  OnlineStats::new().push_all(self.values)
}

///|
pub fn RollingWindow::mean(self : RollingWindow) -> Double {
  self.stats().mean()
}

///|
pub fn RollingWindow::variance(self : RollingWindow) -> Double {
  self.stats().variance()
}

///|
pub fn RollingWindow::trend(self : RollingWindow) -> Double {
  if self.values.length() < 2 {
    0.0
  } else {
    self.values[self.values.length() - 1] - self.values[0]
  }
}

///|
pub fn RollingWindow::min(self : RollingWindow) -> Double {
  self.stats().min()
}

///|
pub fn RollingWindow::max(self : RollingWindow) -> Double {
  self.stats().max()
}

///|
pub fn RollingWindow::quantile(
  self : RollingWindow,
  probability : Double,
) -> Double {
  quantile(self.values, probability)
}

///|
pub fn RollingWindow::map(
  self : RollingWindow,
  transform : (Double) -> Double,
) -> RollingWindow {
  { ..self, values: self.values.map(transform) }
}

///|
pub fn RollingWindow::clear(self : RollingWindow) -> RollingWindow {
  { ..self, values: [] }
}

///|
pub fn exponential_moving_average(
  values : Array[Double],
  decay : Double,
) -> Array[Double] {
  if decay <= 0.0 || decay > 1.0 {
    abort("exponential_moving_average: decay must be in (0, 1]")
  }
  if values.length() == 0 {
    return []
  }
  let result = Array::make(values.length(), 0.0)
  result[0] = values[0]
  for index in 1..<values.length() {
    result[index] = decay * values[index] + (1.0 - decay) * result[index - 1]
  }
  result
}

///|
pub fn exponentially_weighted_variance(
  values : Array[Double],
  decay : Double,
) -> Array[Double] {
  if decay <= 0.0 || decay > 1.0 {
    abort("exponentially_weighted_variance: invalid decay")
  }
  if values.length() == 0 {
    return []
  }
  let result = Array::make(values.length(), 0.0)
  let averages = exponential_moving_average(values, decay)
  for index in 1..<values.length() {
    let error = values[index] - averages[index - 1]
    result[index] = (1.0 - decay) * (result[index - 1] + decay * error * error)
  }
  result
}

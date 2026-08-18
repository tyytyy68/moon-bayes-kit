///|
/// Reproducible experiment records for comparing posterior updates.
pub struct ExperimentPoint {
  step : Int
  metric : Double
  baseline : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn ExperimentPoint::step(self : ExperimentPoint) -> Int {
  self.step
}

///|
pub fn ExperimentPoint::metric(self : ExperimentPoint) -> Double {
  self.metric
}

///|
pub fn ExperimentPoint::error(self : ExperimentPoint) -> Double {
  self.metric - self.baseline
}

///|
pub struct ExperimentLog {
  name : String
  points : Array[ExperimentPoint]
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn ExperimentLog::new(name : String) -> ExperimentLog {
  { name, points: [] }
}

///|
pub fn ExperimentLog::record(
  self : ExperimentLog,
  metric : Double,
  baseline : Double,
) -> ExperimentLog {
  let points = self.points.copy()
  points.push({ step: points.length(), metric, baseline })
  { ..self, points, }
}

///|
pub fn ExperimentLog::name(self : ExperimentLog) -> String {
  self.name
}

///|
pub fn ExperimentLog::len(self : ExperimentLog) -> Int {
  self.points.length()
}

///|
pub fn ExperimentLog::points(self : ExperimentLog) -> Array[ExperimentPoint] {
  self.points.copy()
}

///|
pub fn ExperimentLog::metrics(self : ExperimentLog) -> Array[Double] {
  self.points.map(fn(point) { point.metric() })
}

///|
pub fn ExperimentLog::errors(self : ExperimentLog) -> Array[Double] {
  self.points.map(fn(point) { point.error() })
}

///|
pub fn ExperimentLog::mean_metric(self : ExperimentLog) -> Double {
  mean(self.metrics())
}

///|
pub fn ExperimentLog::metric_variance(self : ExperimentLog) -> Double {
  variance(self.metrics())
}

///|
pub fn ExperimentLog::best_step(self : ExperimentLog) -> Int {
  if self.points.length() == 0 {
    abort("ExperimentLog: no points")
  }
  let mut best = 0
  for index in 1..<self.points.length() {
    if self.points[index].metric() < self.points[best].metric() {
      best = index
    }
  }
  best
}

///|
pub fn ExperimentLog::last(self : ExperimentLog) -> ExperimentPoint {
  if self.points.length() == 0 {
    abort("ExperimentLog: no points")
  }
  self.points[self.points.length() - 1]
}

///|
pub fn ExperimentLog::improvement(self : ExperimentLog) -> Double {
  if self.points.length() < 2 {
    0.0
  } else {
    self.points[0].metric() - self.last().metric()
  }
}

///|
pub fn ExperimentLog::merge(
  self : ExperimentLog,
  other : ExperimentLog,
) -> ExperimentLog {
  let result = { ..self, points: self.points.copy() }
  other.points.fold(init=result, (log, point) => {
    log.record(point.metric(), point.baseline)
  })
}

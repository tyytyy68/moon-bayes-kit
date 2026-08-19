///|
/// Stateful monitoring primitives represented as immutable snapshots. These
/// types support service metrics, quality gates, alerting, and SLO review.
pub enum MetricKind {
  Gauge
  Counter
  Rate
  Histogram
} derive(Debug, Eq, ToJson, FromJson)

///|
pub struct MetricSample {
  timestamp : Int
  value : Double
  weight : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn MetricSample::new(timestamp : Int, value : Double) -> MetricSample {
  { timestamp, value, weight: 1.0 }
}

///|
pub fn MetricSample::weighted(
  timestamp : Int,
  value : Double,
  weight : Double,
) -> MetricSample {
  if weight < 0.0 {
    abort("MetricSample: weight must be non-negative")
  }
  { timestamp, value, weight }
}

///|
pub fn MetricSample::timestamp(self : MetricSample) -> Int {
  self.timestamp
}

///|
pub fn MetricSample::value(self : MetricSample) -> Double {
  self.value
}

///|
pub fn MetricSample::weight(self : MetricSample) -> Double {
  self.weight
}

///|
pub struct MetricStream {
  name : String
  kind : MetricKind
  samples : Array[MetricSample]
  total : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn MetricStream::new(name : String, kind : MetricKind) -> MetricStream {
  { name, kind, samples: [], total: 0.0 }
}

///|
pub fn MetricStream::name(self : MetricStream) -> String {
  self.name
}

///|
pub fn MetricStream::kind(self : MetricStream) -> MetricKind {
  self.kind
}

///|
pub fn MetricStream::len(self : MetricStream) -> Int {
  self.samples.length()
}

///|
pub fn MetricStream::samples(self : MetricStream) -> Array[MetricSample] {
  self.samples.copy()
}

///|
pub fn MetricStream::push(
  self : MetricStream,
  sample : MetricSample,
) -> MetricStream {
  if self.len() > 0 &&
    sample.timestamp() < self.samples[self.len() - 1].timestamp() {
    abort("MetricStream: samples must be ordered")
  }
  let samples = self.samples.copy()
  samples.push(sample)
  { ..self, samples, total: self.total + sample.value() * sample.weight() }
}

///|
pub fn MetricStream::push_value(
  self : MetricStream,
  timestamp : Int,
  value : Double,
) -> MetricStream {
  self.push(MetricSample::new(timestamp, value))
}

///|
pub fn MetricStream::push_all(
  self : MetricStream,
  samples : Array[MetricSample],
) -> MetricStream {
  samples.fold(init=self, (stream, sample) => stream.push(sample))
}

///|
pub fn MetricStream::values(self : MetricStream) -> Array[Double] {
  self.samples.map(fn(sample) { sample.value() })
}

///|
pub fn MetricStream::window(
  self : MetricStream,
  start : Int,
  finish : Int,
) -> MetricStream {
  let samples = self.samples.filter(fn(sample) {
    sample.timestamp() >= start && sample.timestamp() <= finish
  })
  MetricStream::new(self.name, self.kind).push_all(samples)
}

///|
pub fn MetricStream::summary(self : MetricStream) -> OnlineStats {
  OnlineStats::new().push_all(self.values())
}

///|
pub fn MetricStream::weighted_mean(self : MetricStream) -> Double {
  let denominator = self.samples.fold(init=0.0, (total, sample) => {
    total + sample.weight()
  })
  if denominator == 0.0 {
    0.0
  } else {
    self.total / denominator
  }
}

///|
pub fn MetricStream::latest(self : MetricStream) -> Double {
  if self.len() == 0 {
    0.0
  } else {
    self.samples[self.len() - 1].value()
  }
}

///|
pub fn MetricStream::first(self : MetricStream) -> Double {
  if self.len() == 0 {
    0.0
  } else {
    self.samples[0].value()
  }
}

///|
pub fn MetricStream::change(self : MetricStream) -> Double {
  self.latest() - self.first()
}

///|
pub fn MetricStream::rate(self : MetricStream, duration : Double) -> Double {
  if duration <= 0.0 {
    abort("MetricStream::rate: duration must be positive")
  }
  self.total / duration
}

///|
pub fn MetricStream::quantile(
  self : MetricStream,
  probability : Double,
) -> Double {
  quantile(self.values(), probability)
}

///|
pub fn MetricStream::histogram(
  self : MetricStream,
  lower : Double,
  upper : Double,
  bins : Int,
) -> Array[Int] {
  histogram(self.values(), lower, upper, bins)
}

///|
pub struct HistogramBucket {
  lower : Double
  upper : Double
  count : Int
  weight : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn HistogramBucket::new(lower : Double, upper : Double) -> HistogramBucket {
  if lower >= upper {
    abort("HistogramBucket: invalid interval")
  }
  { lower, upper, count: 0, weight: 0.0 }
}

///|
pub fn HistogramBucket::add(
  self : HistogramBucket,
  value : Double,
  weight : Double,
) -> HistogramBucket {
  if value < self.lower || value > self.upper || weight < 0.0 {
    abort("HistogramBucket::add: invalid sample")
  }
  { ..self, count: self.count + 1, weight: self.weight + weight }
}

///|
pub fn HistogramBucket::contains(
  self : HistogramBucket,
  value : Double,
) -> Bool {
  value >= self.lower && value <= self.upper
}

///|
pub fn HistogramBucket::count(self : HistogramBucket) -> Int {
  self.count
}

///|
pub fn HistogramBucket::weight(self : HistogramBucket) -> Double {
  self.weight
}

///|
pub fn HistogramBucket::midpoint(self : HistogramBucket) -> Double {
  (self.lower + self.upper) / 2.0
}

///|
pub struct HistogramAccumulator {
  lower : Double
  upper : Double
  buckets : Array[HistogramBucket]
  total : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn HistogramAccumulator::new(
  lower : Double,
  upper : Double,
  bins : Int,
) -> HistogramAccumulator {
  if lower >= upper || bins <= 0 {
    abort("HistogramAccumulator: invalid range")
  }
  let width = (upper - lower) / bins.to_double()
  let buckets = []
  for index in 0..<bins {
    buckets.push(
      HistogramBucket::new(
        lower + index.to_double() * width,
        lower + (index + 1).to_double() * width,
      ),
    )
  }
  { lower, upper, buckets, total: 0 }
}

///|
pub fn HistogramAccumulator::add(
  self : HistogramAccumulator,
  value : Double,
) -> HistogramAccumulator {
  if value < self.lower || value > self.upper {
    return self
  }
  let index = if value == self.upper {
    self.buckets.length() - 1
  } else {
    ((value - self.lower) /
    (self.upper - self.lower) *
    self.buckets.length().to_double())
    .floor()
    .to_int()
  }
  let buckets = self.buckets.copy()
  buckets[index] = buckets[index].add(value, 1.0)
  { ..self, buckets, total: self.total + 1 }
}

///|
pub fn HistogramAccumulator::add_all(
  self : HistogramAccumulator,
  values : Array[Double],
) -> HistogramAccumulator {
  values.fold(init=self, (histogram, value) => histogram.add(value))
}

///|
pub fn HistogramAccumulator::counts(self : HistogramAccumulator) -> Array[Int] {
  self.buckets.map(fn(bucket) { bucket.count() })
}

///|
pub fn HistogramAccumulator::cdf(self : HistogramAccumulator) -> Array[Double] {
  let result = []
  let mut cumulative = 0.0
  for bucket in self.buckets {
    cumulative = cumulative + bucket.count().to_double()
    result.push(
      if self.total == 0 {
        0.0
      } else {
        cumulative / self.total.to_double()
      },
    )
  }
  result
}

///|
pub fn HistogramAccumulator::total(self : HistogramAccumulator) -> Int {
  self.total
}

///|
pub enum Comparator {
  LessThan
  LessOrEqual
  GreaterThan
  GreaterOrEqual
  Equal
  NotEqual
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn compare_value(
  comparator : Comparator,
  actual : Double,
  expected : Double,
  tolerance : Double,
) -> Bool {
  match comparator {
    LessThan => actual < expected
    LessOrEqual => actual <= expected
    GreaterThan => actual > expected
    GreaterOrEqual => actual >= expected
    Equal => (actual - expected).abs() <= tolerance
    NotEqual => (actual - expected).abs() > tolerance
  }
}

///|
pub struct AlertRule {
  name : String
  comparator : Comparator
  threshold : Double
  tolerance : Double
  consecutive : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn AlertRule::new(
  name : String,
  comparator : Comparator,
  threshold : Double,
) -> AlertRule {
  { name, comparator, threshold, tolerance: 0.0, consecutive: 1 }
}

///|
pub fn AlertRule::with_tolerance(
  self : AlertRule,
  tolerance : Double,
) -> AlertRule {
  if tolerance < 0.0 {
    abort("AlertRule: tolerance must be non-negative")
  }
  { ..self, tolerance, }
}

///|
pub fn AlertRule::with_consecutive(self : AlertRule, count : Int) -> AlertRule {
  if count <= 0 {
    abort("AlertRule: consecutive count must be positive")
  }
  { ..self, consecutive: count }
}

///|
pub fn AlertRule::name(self : AlertRule) -> String {
  self.name
}

///|
pub fn AlertRule::matches(self : AlertRule, value : Double) -> Bool {
  compare_value(self.comparator, value, self.threshold, self.tolerance)
}

///|
pub fn AlertRule::required_consecutive(self : AlertRule) -> Int {
  self.consecutive
}

///|
pub struct AlertEvent {
  rule : String
  timestamp : Int
  value : Double
  active : Bool
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn AlertEvent::rule(self : AlertEvent) -> String {
  self.rule
}

///|
pub fn AlertEvent::timestamp(self : AlertEvent) -> Int {
  self.timestamp
}

///|
pub fn AlertEvent::value(self : AlertEvent) -> Double {
  self.value
}

///|
pub fn AlertEvent::active(self : AlertEvent) -> Bool {
  self.active
}

///|
pub struct AlertEvaluator {
  rule : AlertRule
  streak : Int
  events : Array[AlertEvent]
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn AlertEvaluator::new(rule : AlertRule) -> AlertEvaluator {
  { rule, streak: 0, events: [] }
}

///|
pub fn AlertEvaluator::evaluate(
  self : AlertEvaluator,
  timestamp : Int,
  value : Double,
) -> AlertEvaluator {
  let streak = if self.rule.matches(value) { self.streak + 1 } else { 0 }
  let active = streak >= self.rule.required_consecutive()
  let events = self.events.copy()
  events.push({ rule: self.rule.name(), timestamp, value, active })
  { ..self, streak, events }
}

///|
pub fn AlertEvaluator::is_active(self : AlertEvaluator) -> Bool {
  self.streak >= self.rule.required_consecutive()
}

///|
pub fn AlertEvaluator::streak(self : AlertEvaluator) -> Int {
  self.streak
}

///|
pub fn AlertEvaluator::events(self : AlertEvaluator) -> Array[AlertEvent] {
  self.events.copy()
}

///|
pub fn AlertEvaluator::reset(self : AlertEvaluator) -> AlertEvaluator {
  { ..self, streak: 0 }
}

///|
pub struct SloTarget {
  name : String
  target : Double
  window : Int
  good : Int
  total : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn SloTarget::new(
  name : String,
  target : Double,
  window : Int,
) -> SloTarget {
  if target < 0.0 || target > 1.0 || window <= 0 {
    abort("SloTarget: invalid target or window")
  }
  { name, target, window, good: 0, total: 0 }
}

///|
pub fn SloTarget::record(self : SloTarget, good : Bool) -> SloTarget {
  let increment = if good { 1 } else { 0 }
  { ..self, good: self.good + increment, total: self.total + 1 }
}

///|
pub fn SloTarget::name(self : SloTarget) -> String {
  self.name
}

///|
pub fn SloTarget::target(self : SloTarget) -> Double {
  self.target
}

///|
pub fn SloTarget::attainment(self : SloTarget) -> Double {
  if self.total == 0 {
    0.0
  } else {
    self.good.to_double() / self.total.to_double()
  }
}

///|
pub fn SloTarget::is_met(self : SloTarget) -> Bool {
  self.attainment() >= self.target
}

///|
pub fn SloTarget::error_budget(self : SloTarget) -> Double {
  (self.target - self.attainment()).max(0.0)
}

///|
pub fn SloTarget::remaining_budget(self : SloTarget) -> Int {
  let allowed = ((1.0 - self.target) * self.total.to_double()).floor().to_int()
  (allowed - (self.total - self.good)).max(0)
}

///|
pub fn SloTarget::good(self : SloTarget) -> Int {
  self.good
}

///|
pub fn SloTarget::total(self : SloTarget) -> Int {
  self.total
}

///|
pub struct MonitorReport {
  name : String
  count : Int
  mean : Double
  deviation : Double
  latest : Double
  min : Double
  max : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn MonitorReport::from_stream(stream : MetricStream) -> MonitorReport {
  let summary = stream.summary()
  {
    name: stream.name(),
    count: summary.count(),
    mean: summary.mean(),
    deviation: summary.standard_deviation(),
    latest: stream.latest(),
    min: summary.min(),
    max: summary.max(),
  }
}

///|
pub fn MonitorReport::name(self : MonitorReport) -> String {
  self.name
}

///|
pub fn MonitorReport::count(self : MonitorReport) -> Int {
  self.count
}

///|
pub fn MonitorReport::mean(self : MonitorReport) -> Double {
  self.mean
}

///|
pub fn MonitorReport::deviation(self : MonitorReport) -> Double {
  self.deviation
}

///|
pub fn MonitorReport::latest(self : MonitorReport) -> Double {
  self.latest
}

///|
pub fn MonitorReport::min(self : MonitorReport) -> Double {
  self.min
}

///|
pub fn MonitorReport::max(self : MonitorReport) -> Double {
  self.max
}

///|
pub fn MonitorReport::z_score(self : MonitorReport) -> Double {
  if self.deviation == 0.0 {
    0.0
  } else {
    (self.latest - self.mean) / self.deviation
  }
}

///|
pub fn monitor_drift(
  stream : MetricStream,
  baseline : OnlineStats,
  threshold : Double,
) -> Bool {
  if threshold < 0.0 {
    abort("monitor_drift: threshold must be non-negative")
  }
  let deviation = baseline.standard_deviation()
  if deviation == 0.0 {
    stream.latest() != baseline.mean()
  } else {
    (stream.latest() - baseline.mean()).abs() > threshold * deviation
  }
}

///|
pub fn monitor_outliers(
  stream : MetricStream,
  z_threshold : Double,
) -> Array[MetricSample] {
  if z_threshold <= 0.0 {
    abort("monitor_outliers: threshold must be positive")
  }
  let summary = stream.summary()
  stream
  .samples()
  .filter(fn(sample) {
    if summary.standard_deviation() == 0.0 {
      false
    } else {
      ((sample.value() - summary.mean()) / summary.standard_deviation()).abs() >
      z_threshold
    }
  })
}

///|
pub fn aggregate_streams(streams : Array[MetricStream]) -> MetricStream {
  if streams.length() == 0 {
    abort("aggregate_streams: streams must not be empty")
  }
  let result = MetricStream::new(streams[0].name(), streams[0].kind())
  streams.fold(init=result, (current, stream) => {
    current.push_all(stream.samples())
  })
}

///|
pub fn metric_snapshot(streams : Array[MetricStream]) -> Array[MonitorReport] {
  streams.map(fn(stream) { MonitorReport::from_stream(stream) })
}

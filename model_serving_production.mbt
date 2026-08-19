///|
/// Runtime-facing records and guards for serving probabilistic predictions.
/// The package remains model-agnostic: inference is performed by the caller,
/// while this layer handles validation, interval policy, rollout accounting,
/// and auditable service health signals.
pub struct ServingRequest {
  request_id : String
  entity_id : String
  features : Array[Double]
  received_at : Int
  schema_version : String
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn ServingRequest::new(
  request_id : String,
  entity_id : String,
  features : Array[Double],
  received_at : Int,
) -> ServingRequest {
  if request_id == "" ||
    entity_id == "" ||
    features.length() == 0 ||
    received_at < 0 {
    abort("ServingRequest: invalid request identity, features, or timestamp")
  }
  for value in features.iter() {
    if value != value || value.is_inf() {
      abort("ServingRequest: features must be finite")
    }
  }
  { request_id, entity_id, features, received_at, schema_version: "" }
}

///|
pub fn ServingRequest::with_schema(
  self : ServingRequest,
  schema_version : String,
) -> ServingRequest {
  { ..self, schema_version, }
}

///|
pub struct ServingPrediction {
  request_id : String
  value : Double
  lower : Double
  upper : Double
  model_name : String
  model_version : String
  latency_ms : Int
  produced_at : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn ServingPrediction::new(
  request_id : String,
  value : Double,
  model_name : String,
  model_version : String,
  latency_ms : Int,
  produced_at : Int,
) -> ServingPrediction {
  if request_id == "" ||
    model_name == "" ||
    model_version == "" ||
    latency_ms < 0 ||
    produced_at < 0 {
    abort("ServingPrediction: invalid identity, latency, or timestamp")
  }
  if value != value || value.is_inf() {
    abort("ServingPrediction: value must be finite")
  }
  {
    request_id,
    value,
    lower: value,
    upper: value,
    model_name,
    model_version,
    latency_ms,
    produced_at,
  }
}

///|
pub fn ServingPrediction::with_interval(
  self : ServingPrediction,
  lower : Double,
  upper : Double,
) -> ServingPrediction {
  if lower > upper || self.value < lower || self.value > upper {
    abort("ServingPrediction: interval must contain the prediction")
  }
  { ..self, lower, upper }
}

///|
pub fn ServingPrediction::interval_width(self : ServingPrediction) -> Double {
  self.upper - self.lower
}

///|
pub struct ServingFailure {
  request_id : String
  code : String
  message : String
  retryable : Bool
  at : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn ServingFailure::new(
  request_id : String,
  code : String,
  message : String,
  retryable : Bool,
  at : Int,
) -> ServingFailure {
  if request_id == "" || code == "" || at < 0 {
    abort("ServingFailure: request, code and timestamp are required")
  }
  { request_id, code, message, retryable, at }
}

///|
pub struct PredictionBounds {
  minimum : Double
  maximum : Double
  reject_outside : Bool
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn PredictionBounds::new(
  minimum : Double,
  maximum : Double,
) -> PredictionBounds {
  if minimum > maximum {
    abort("PredictionBounds: minimum exceeds maximum")
  }
  { minimum, maximum, reject_outside: false }
}

///|
pub fn PredictionBounds::reject(
  self : PredictionBounds,
  value : Bool,
) -> PredictionBounds {
  { ..self, reject_outside: value }
}

///|
pub fn PredictionBounds::apply(
  self : PredictionBounds,
  prediction : ServingPrediction,
) -> ServingPrediction? {
  if prediction.value < self.minimum || prediction.value > self.maximum {
    if self.reject_outside {
      None
    } else {
      Some({
        ..prediction,
        value: prediction.value.max(self.minimum).min(self.maximum),
        lower: prediction.lower.max(self.minimum),
        upper: prediction.upper.min(self.maximum),
      })
    }
  } else {
    Some(prediction)
  }
}

///|
pub struct ServingBatchReport {
  predictions : Array[ServingPrediction]
  failures : Array[ServingFailure]
  total : Int
  success_rate : Double
  mean_latency_ms : Double
  p95_latency_ms : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn build_batch_report(
  predictions : Array[ServingPrediction],
  failures : Array[ServingFailure],
  total : Int,
) -> ServingBatchReport {
  if total < predictions.length() + failures.length() {
    abort("build_batch_report: total cannot be smaller than observed outcomes")
  }
  let latencies = predictions.map(fn(item) { item.latency_ms.to_double() })
  let mean_latency_ms = if latencies.length() == 0 {
    0.0
  } else {
    mean(latencies)
  }
  let p95_latency_ms = if latencies.length() == 0 {
    0.0
  } else {
    quantile(latencies, 0.95)
  }
  let success_rate = if total == 0 {
    0.0
  } else {
    predictions.length().to_double() / total.to_double()
  }
  {
    predictions,
    failures,
    total,
    success_rate,
    mean_latency_ms,
    p95_latency_ms,
  }
}

///|
pub struct ModelRoute {
  model_name : String
  stable_version : String
  canary_version : String
  canary_percent : Int
  enabled : Bool
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn ModelRoute::new(
  model_name : String,
  stable_version : String,
) -> ModelRoute {
  if model_name == "" || stable_version == "" {
    abort("ModelRoute: model and stable version are required")
  }
  {
    model_name,
    stable_version,
    canary_version: "",
    canary_percent: 0,
    enabled: true,
  }
}

///|
pub fn ModelRoute::canary(
  self : ModelRoute,
  version : String,
  percent : Int,
) -> ModelRoute {
  if version == "" || percent < 0 || percent > 100 {
    abort("ModelRoute: invalid canary configuration")
  }
  { ..self, canary_version: version, canary_percent: percent }
}

///|
pub fn ModelRoute::disable(self : ModelRoute) -> ModelRoute {
  { ..self, enabled: false }
}

///|
pub fn ModelRoute::enable(self : ModelRoute) -> ModelRoute {
  { ..self, enabled: true }
}

///|
pub fn ModelRoute::select(self : ModelRoute, request_id : String) -> String {
  if !self.enabled {
    abort("ModelRoute::select: route is disabled")
  }
  if self.canary_version == "" || self.canary_percent == 0 {
    return self.stable_version
  }
  let bucket = request_id.length() % 100
  if bucket < self.canary_percent {
    self.canary_version
  } else {
    self.stable_version
  }
}

///|
pub struct RolloutCounter {
  stable_requests : Int
  canary_requests : Int
  stable_errors : Int
  canary_errors : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn RolloutCounter::new() -> RolloutCounter {
  { stable_requests: 0, canary_requests: 0, stable_errors: 0, canary_errors: 0 }
}

///|
pub fn RolloutCounter::record(
  self : RolloutCounter,
  version : String,
  error : Bool,
  canary_version : String,
) -> RolloutCounter {
  let is_canary = version == canary_version && canary_version != ""
  let error_count = if error { 1 } else { 0 }
  if is_canary {
    {
      ..self,
      canary_requests: self.canary_requests + 1,
      canary_errors: self.canary_errors + error_count,
    }
  } else {
    {
      ..self,
      stable_requests: self.stable_requests + 1,
      stable_errors: self.stable_errors + error_count,
    }
  }
}

///|
pub fn RolloutCounter::stable_error_rate(self : RolloutCounter) -> Double {
  if self.stable_requests == 0 {
    0.0
  } else {
    self.stable_errors.to_double() / self.stable_requests.to_double()
  }
}

///|
pub fn RolloutCounter::canary_error_rate(self : RolloutCounter) -> Double {
  if self.canary_requests == 0 {
    0.0
  } else {
    self.canary_errors.to_double() / self.canary_requests.to_double()
  }
}

///|
pub fn RolloutCounter::canary_is_healthy(
  self : RolloutCounter,
  maximum_error_rate : Double,
  minimum_requests : Int,
) -> Bool {
  if maximum_error_rate < 0.0 ||
    maximum_error_rate > 1.0 ||
    minimum_requests < 0 {
    abort("RolloutCounter::canary_is_healthy: invalid policy")
  }
  self.canary_requests >= minimum_requests &&
  self.canary_error_rate() <= maximum_error_rate
}

///|
pub struct TokenBudget {
  capacity : Double
  refill_per_second : Double
  tokens : Double
  last_at : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn TokenBudget::new(
  capacity : Double,
  refill_per_second : Double,
  at : Int,
) -> TokenBudget {
  if capacity <= 0.0 || refill_per_second < 0.0 || at < 0 {
    abort("TokenBudget: invalid capacity, refill, or timestamp")
  }
  { capacity, refill_per_second, tokens: capacity, last_at: at }
}

///|
pub fn TokenBudget::try_acquire(
  self : TokenBudget,
  amount : Double,
  at : Int,
) -> (TokenBudget, Bool) {
  if amount <= 0.0 || amount > self.capacity || at < self.last_at {
    abort("TokenBudget::try_acquire: invalid amount or timestamp")
  }
  let elapsed = (at - self.last_at).to_double()
  let available = (self.tokens + elapsed * self.refill_per_second).min(
    self.capacity,
  )
  if available < amount {
    ({ ..self, tokens: available, last_at: at }, false)
  } else {
    ({ ..self, tokens: available - amount, last_at: at }, true)
  }
}

///|
pub fn TokenBudget::remaining(self : TokenBudget, at : Int) -> Double {
  if at < self.last_at {
    abort("TokenBudget::remaining: timestamp moved backwards")
  }
  (self.tokens + (at - self.last_at).to_double() * self.refill_per_second).min(
    self.capacity,
  )
}

///|
pub struct ServiceHealth {
  window_start : Int
  window_end : Int
  requests : Int
  successes : Int
  errors : Int
  latency_ms : Array[Double]
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn ServiceHealth::new(start : Int) -> ServiceHealth {
  if start < 0 {
    abort("ServiceHealth: start must be non-negative")
  }
  {
    window_start: start,
    window_end: start,
    requests: 0,
    successes: 0,
    errors: 0,
    latency_ms: [],
  }
}

///|
pub fn ServiceHealth::record(
  self : ServiceHealth,
  at : Int,
  latency_ms : Double,
  success : Bool,
) -> ServiceHealth {
  if at < self.window_end || latency_ms < 0.0 {
    abort("ServiceHealth::record: invalid time or latency")
  }
  let latencies = self.latency_ms.copy()
  latencies.push(latency_ms)
  let success_count = if success { 1 } else { 0 }
  let error_count = if success { 0 } else { 1 }
  {
    ..self,
    window_end: at,
    requests: self.requests + 1,
    successes: self.successes + success_count,
    errors: self.errors + error_count,
    latency_ms: latencies,
  }
}

///|
pub fn ServiceHealth::availability(self : ServiceHealth) -> Double {
  if self.requests == 0 {
    1.0
  } else {
    self.successes.to_double() / self.requests.to_double()
  }
}

///|
pub fn ServiceHealth::error_rate(self : ServiceHealth) -> Double {
  if self.requests == 0 {
    0.0
  } else {
    self.errors.to_double() / self.requests.to_double()
  }
}

///|
pub fn ServiceHealth::p95_latency(self : ServiceHealth) -> Double {
  if self.latency_ms.length() == 0 {
    0.0
  } else {
    quantile(self.latency_ms, 0.95)
  }
}

///|
pub fn ServiceHealth::meets_slo(
  self : ServiceHealth,
  minimum_availability : Double,
  maximum_p95_ms : Double,
) -> Bool {
  if minimum_availability < 0.0 ||
    minimum_availability > 1.0 ||
    maximum_p95_ms < 0.0 {
    abort("ServiceHealth::meets_slo: invalid SLO")
  }
  self.availability() >= minimum_availability &&
  self.p95_latency() <= maximum_p95_ms
}

///|
pub struct PredictionAuditEntry {
  request_id : String
  entity_id : String
  model_version : String
  value : Double
  interval_width : Double
  latency_ms : Int
  at : Int
  outcome : Double?
} derive(Debug, Eq, ToJson, FromJson)

///|
pub struct PredictionAuditLog {
  capacity : Int
  entries : Array[PredictionAuditEntry]
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn PredictionAuditLog::new(capacity : Int) -> PredictionAuditLog {
  if capacity <= 0 {
    abort("PredictionAuditLog: capacity must be positive")
  }
  { capacity, entries: [] }
}

///|
pub fn PredictionAuditLog::append(
  self : PredictionAuditLog,
  request : ServingRequest,
  prediction : ServingPrediction,
) -> PredictionAuditLog {
  let entries = self.entries.copy()
  entries.push({
    request_id: request.request_id,
    entity_id: request.entity_id,
    model_version: prediction.model_version,
    value: prediction.value,
    interval_width: prediction.interval_width(),
    latency_ms: prediction.latency_ms,
    at: prediction.produced_at,
    outcome: None,
  })
  if entries.length() > self.capacity {
    ignore(entries.remove(0))
  }
  { ..self, entries, }
}

///|
pub fn PredictionAuditLog::attach_outcome(
  self : PredictionAuditLog,
  request_id : String,
  outcome : Double,
) -> PredictionAuditLog {
  let entries = self.entries.copy()
  for index in 0..<entries.length() {
    if entries[index].request_id == request_id {
      entries[index] = { ..entries[index], outcome: Some(outcome) }
      break
    }
  }
  { ..self, entries, }
}

///|
pub fn PredictionAuditLog::entry_count(self : PredictionAuditLog) -> Int {
  self.entries.length()
}

///|
pub fn PredictionAuditLog::observed_error(
  self : PredictionAuditLog,
  absolute_threshold : Double,
) -> Double {
  if absolute_threshold < 0.0 {
    abort("PredictionAuditLog::observed_error: threshold must be non-negative")
  }
  let observed = self.entries.filter(fn(entry) { entry.outcome is Some(_) })
  if observed.length() == 0 {
    return 0.0
  }
  let mut errors = 0.0
  for entry in observed.iter() {
    match entry.outcome {
      Some(outcome) =>
        if (entry.value - outcome).abs() > absolute_threshold {
          errors = errors + 1.0
        }
      None => ()
    }
  }
  errors / observed.length().to_double()
}

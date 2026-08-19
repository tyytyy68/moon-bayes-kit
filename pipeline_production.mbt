///|
/// Deterministic batch pipeline planning and execution records.
pub enum StageKind {
  Source
  Map
  Filter
  Join
  Aggregate
  Window
  Sink
  Validate
} derive(Debug, Eq, ToJson, FromJson)

///|
pub enum PipelineStatus {
  Pending
  Running
  Succeeded
  Failed
  Skipped
  Cancelled
} derive(Debug, Eq, ToJson, FromJson)

///|
pub struct PipelineStage {
  name : String
  kind : StageKind
  dependencies : Array[String]
  retries : Int
  timeout_ms : Int
  enabled : Bool
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn PipelineStage::new(name : String, kind : StageKind) -> PipelineStage {
  if name == "" {
    abort("PipelineStage: name cannot be empty")
  }
  { name, kind, dependencies: [], retries: 0, timeout_ms: 0, enabled: true }
}

///|
pub fn PipelineStage::depends_on(
  self : PipelineStage,
  dependency : String,
) -> PipelineStage {
  let dependencies = self.dependencies.copy()
  if !dependencies.contains(dependency) {
    dependencies.push(dependency)
  }
  { ..self, dependencies, }
}

///|
pub fn PipelineStage::with_retries(
  self : PipelineStage,
  retries : Int,
) -> PipelineStage {
  if retries < 0 {
    abort("PipelineStage: retries must be non-negative")
  }
  { ..self, retries, }
}

///|
pub fn PipelineStage::with_timeout(
  self : PipelineStage,
  timeout_ms : Int,
) -> PipelineStage {
  if timeout_ms < 0 {
    abort("PipelineStage: timeout must be non-negative")
  }
  { ..self, timeout_ms, }
}

///|
pub fn PipelineStage::disabled(self : PipelineStage) -> PipelineStage {
  { ..self, enabled: false }
}

///|
pub struct PipelinePlan {
  name : String
  version : String
  stages : Array[PipelineStage]
  schedule : Array[String]
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn PipelinePlan::new(name : String, version : String) -> PipelinePlan {
  { name, version, stages: [], schedule: [] }
}

///|
pub fn PipelinePlan::add(
  self : PipelinePlan,
  stage : PipelineStage,
) -> PipelinePlan {
  if self.stages.any(fn(item) { item.name == stage.name }) {
    abort("PipelinePlan: duplicate stage")
  }
  let stages = self.stages.copy()
  stages.push(stage)
  { ..self, stages, }
}

///|
pub fn PipelinePlan::stage(self : PipelinePlan, name : String) -> PipelineStage {
  for stage in self.stages.iter() {
    if stage.name == name {
      return stage
    }
  }
  abort("PipelinePlan: stage not found")
}

///|
pub fn PipelinePlan::validate(self : PipelinePlan) -> Array[String] {
  let errors : Array[String] = []
  for stage in self.stages.iter() {
    for dependency in stage.dependencies.iter() {
      if !self.stages.any(fn(item) { item.name == dependency }) {
        errors.push(stage.name + ": missing dependency " + dependency)
      }
    }
  }
  let visiting : Array[String] = []
  let visited : Array[String] = []
  for stage in self.stages.iter() {
    if visiting.contains(stage.name) {
      errors.push("cycle detected at " + stage.name)
    }
    if !visited.contains(stage.name) {
      visiting.push(stage.name)
      for dependency in stage.dependencies.iter() {
        if visiting.contains(dependency) {
          errors.push("cycle detected through " + dependency)
        }
      }
      let _ = visiting.pop()
      visited.push(stage.name)
    }
  }
  errors
}

///|
pub fn PipelinePlan::topological_order(self : PipelinePlan) -> Array[String] {
  let errors = self.validate()
  if errors.length() > 0 {
    abort("PipelinePlan: invalid graph")
  }
  let pending = self.stages
    .filter(fn(stage) { stage.enabled })
    .map(fn(stage) { stage.name })
  let result : Array[String] = []
  while pending.length() > 0 {
    let mut selected = -1
    for index in 0..<pending.length() {
      let stage = self.stage(pending[index])
      let ready = stage.dependencies.all(fn(dependency) {
        result.contains(dependency) ||
        !self.stages.any(fn(item) { item.name == dependency && item.enabled })
      })
      if ready && selected < 0 {
        selected = index
      }
    }
    if selected < 0 {
      abort("PipelinePlan: cyclic dependency")
    }
    result.push(pending[selected])
    ignore(pending.remove(selected))
  }
  result
}

///|
pub struct StageResult {
  name : String
  status : PipelineStatus
  input_rows : Int
  output_rows : Int
  duration_ms : Int
  attempts : Int
  error : String
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn StageResult::success(
  name : String,
  input_rows : Int,
  output_rows : Int,
  duration_ms : Int,
  attempts : Int,
) -> StageResult {
  {
    name,
    status: PipelineStatus::Succeeded,
    input_rows,
    output_rows,
    duration_ms,
    attempts,
    error: "",
  }
}

///|
pub fn StageResult::failure(
  name : String,
  input_rows : Int,
  duration_ms : Int,
  attempts : Int,
  error : String,
) -> StageResult {
  {
    name,
    status: PipelineStatus::Failed,
    input_rows,
    output_rows: 0,
    duration_ms,
    attempts,
    error,
  }
}

///|
pub fn StageResult::selectivity(self : StageResult) -> Double {
  if self.input_rows == 0 {
    0.0
  } else {
    self.output_rows.to_double() / self.input_rows.to_double()
  }
}

///|
pub struct PipelineRun {
  pipeline : String
  run_id : String
  status : PipelineStatus
  results : Array[StageResult]
  started_at : Int
  ended_at : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn PipelineRun::new(
  pipeline : String,
  run_id : String,
  started_at : Int,
) -> PipelineRun {
  {
    pipeline,
    run_id,
    status: PipelineStatus::Running,
    results: [],
    started_at,
    ended_at: 0,
  }
}

///|
pub fn PipelineRun::record(
  self : PipelineRun,
  result : StageResult,
) -> PipelineRun {
  let results = self.results.copy()
  results.push(result)
  let status = if result.status == PipelineStatus::Failed {
    PipelineStatus::Failed
  } else {
    self.status
  }
  { ..self, results, status }
}

///|
pub fn PipelineRun::finish(self : PipelineRun, ended_at : Int) -> PipelineRun {
  let status = if self.status == PipelineStatus::Failed {
    PipelineStatus::Failed
  } else {
    PipelineStatus::Succeeded
  }
  { ..self, status, ended_at }
}

///|
pub fn PipelineRun::failed(self : PipelineRun) -> Bool {
  self.status == PipelineStatus::Failed
}

///|
pub fn PipelineRun::duration(self : PipelineRun) -> Int {
  (self.ended_at - self.started_at).max(0)
}

///|
pub fn PipelineRun::row_counts(self : PipelineRun) -> Array[(String, Int, Int)] {
  self.results.map(fn(result) {
    (result.name, result.input_rows, result.output_rows)
  })
}

///|
pub fn PipelineRun::total_input(self : PipelineRun) -> Int {
  self.results.fold(init=0, (total, result) => total + result.input_rows)
}

///|
pub fn PipelineRun::total_output(self : PipelineRun) -> Int {
  self.results.fold(init=0, (total, result) => total + result.output_rows)
}

///|
pub struct WindowSpec {
  size : Int
  slide : Int
  offset : Int
  timestamp_column : String
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn WindowSpec::tumbling(size : Int) -> WindowSpec {
  if size <= 0 {
    abort("WindowSpec: size must be positive")
  }
  { size, slide: size, offset: 0, timestamp_column: "timestamp" }
}

///|
pub fn WindowSpec::sliding(size : Int, slide : Int) -> WindowSpec {
  if size <= 0 || slide <= 0 || slide > size {
    abort("WindowSpec: invalid sliding window")
  }
  { size, slide, offset: 0, timestamp_column: "timestamp" }
}

///|
pub fn WindowSpec::with_offset(self : WindowSpec, offset : Int) -> WindowSpec {
  { ..self, offset, }
}

///|
pub fn WindowSpec::window_id(self : WindowSpec, timestamp : Int) -> Int {
  (timestamp - self.offset) / self.slide * self.slide + self.offset
}

///|
pub fn group_window_ids(
  timestamps : Array[Int],
  window : WindowSpec,
) -> Array[Int] {
  timestamps.map(fn(timestamp) { window.window_id(timestamp) })
}

///|
pub struct NumericAggregate {
  count : Int
  sum : Double
  minimum : Double
  maximum : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn NumericAggregate::new() -> NumericAggregate {
  { count: 0, sum: 0.0, minimum: 0.0, maximum: 0.0 }
}

///|
pub fn NumericAggregate::push(
  self : NumericAggregate,
  value : Double,
) -> NumericAggregate {
  if self.count == 0 {
    { count: 1, sum: value, minimum: value, maximum: value }
  } else {
    {
      count: self.count + 1,
      sum: self.sum + value,
      minimum: self.minimum.min(value),
      maximum: self.maximum.max(value),
    }
  }
}

///|
pub fn NumericAggregate::mean(self : NumericAggregate) -> Double {
  if self.count == 0 {
    0.0
  } else {
    self.sum / self.count.to_double()
  }
}

///|
pub fn NumericAggregate::range(self : NumericAggregate) -> Double {
  self.maximum - self.minimum
}

///|
pub fn window_aggregate(
  timestamps : Array[Int],
  values : Array[Double],
  window : WindowSpec,
) -> Array[(Int, NumericAggregate)] {
  if timestamps.length() != values.length() {
    abort("window_aggregate: lengths must match")
  }
  let keys : Array[Int] = []
  let aggregates : Array[NumericAggregate] = []
  for index in 0..<timestamps.length() {
    let key = window.window_id(timestamps[index])
    let mut position = -1
    for candidate in 0..<keys.length() {
      if keys[candidate] == key {
        position = candidate
      }
    }
    if position < 0 {
      keys.push(key)
      aggregates.push(NumericAggregate::new().push(values[index]))
    } else {
      aggregates[position] = aggregates[position].push(values[index])
    }
  }
  let result : Array[(Int, NumericAggregate)] = []
  for index in 0..<keys.length() {
    result.push((keys[index], aggregates[index]))
  }
  result
}

///|
pub enum JoinType {
  Inner
  Left
  Right
  Full
} derive(Debug, Eq, ToJson, FromJson)

///|
pub struct JoinRow {
  key : String
  left_index : Int
  right_index : Int
  matched : Bool
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn plan_join(
  left_keys : Array[String],
  right_keys : Array[String],
  join_type : JoinType,
) -> Array[JoinRow] {
  let result : Array[JoinRow] = []
  let used : Array[Bool] = []
  for _ in 0..<right_keys.length() {
    used.push(false)
  }
  for left in 0..<left_keys.length() {
    let mut found = false
    for right in 0..<right_keys.length() {
      if left_keys[left] == right_keys[right] {
        result.push({
          key: left_keys[left],
          left_index: left,
          right_index: right,
          matched: true,
        })
        used[right] = true
        found = true
      }
    }
    if !found && (join_type == JoinType::Left || join_type == JoinType::Full) {
      result.push({
        key: left_keys[left],
        left_index: left,
        right_index: -1,
        matched: false,
      })
    }
  }
  if join_type == JoinType::Right || join_type == JoinType::Full {
    for right in 0..<right_keys.length() {
      if !used[right] {
        result.push({
          key: right_keys[right],
          left_index: -1,
          right_index: right,
          matched: false,
        })
      }
    }
  }
  result
}

///|
pub struct BackpressurePolicy {
  capacity : Int
  drop_oldest : Bool
  block_on_full : Bool
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn BackpressurePolicy::bounded(capacity : Int) -> BackpressurePolicy {
  if capacity <= 0 {
    abort("BackpressurePolicy: capacity must be positive")
  }
  { capacity, drop_oldest: false, block_on_full: true }
}

///|
pub fn BackpressurePolicy::lossy(
  self : BackpressurePolicy,
) -> BackpressurePolicy {
  { ..self, drop_oldest: true, block_on_full: false }
}

///|
pub fn throughput(rows : Int, duration_ms : Int) -> Double {
  if rows < 0 || duration_ms <= 0 {
    abort("throughput: invalid inputs")
  }
  rows.to_double() * 1000.0 / duration_ms.to_double()
}

///|
pub fn pipeline_success_rate(runs : Array[PipelineRun]) -> Double {
  if runs.length() == 0 {
    return 0.0
  }
  runs
  .filter(fn(run) { run.status == PipelineStatus::Succeeded })
  .length()
  .to_double() /
  runs.length().to_double()
}

///|
pub fn stage_failure_rate(results : Array[StageResult]) -> Double {
  if results.length() == 0 {
    return 0.0
  }
  results
  .filter(fn(result) { result.status == PipelineStatus::Failed })
  .length()
  .to_double() /
  results.length().to_double()
}

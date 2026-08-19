///|
/// Small, serializable data-lineage primitives for feature pipelines and
/// model-training workflows. A lineage graph makes reproducibility and impact
/// analysis explicit without requiring a database-specific implementation.
pub struct LineageAsset {
  id : String
  kind : String
  owner : String
  schema_version : String
  tags : Array[String]
  row_count : Int
  updated_at : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn LineageAsset::new(
  id : String,
  kind : String,
  owner : String,
  schema_version : String,
) -> LineageAsset {
  if id == "" || kind == "" {
    abort("LineageAsset: id and kind are required")
  }
  { id, kind, owner, schema_version, tags: [], row_count: 0, updated_at: 0 }
}

///|
pub fn LineageAsset::with_tag(
  self : LineageAsset,
  tag : String,
) -> LineageAsset {
  if tag == "" {
    abort("LineageAsset: tag must not be empty")
  }
  if self.tags.contains(tag) {
    self
  } else {
    let tags = self.tags.copy()
    tags.push(tag)
    { ..self, tags, }
  }
}

///|
pub fn LineageAsset::with_observation(
  self : LineageAsset,
  row_count : Int,
  updated_at : Int,
) -> LineageAsset {
  if row_count < 0 || updated_at < 0 {
    abort("LineageAsset: observation values must be non-negative")
  }
  { ..self, row_count, updated_at }
}

///|
pub fn LineageAsset::has_tag(self : LineageAsset, tag : String) -> Bool {
  self.tags.contains(tag)
}

///|
pub struct LineageOperation {
  id : String
  name : String
  inputs : Array[String]
  outputs : Array[String]
  started_at : Int
  finished_at : Int
  status : String
  code_revision : String
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn LineageOperation::new(
  id : String,
  name : String,
  inputs : Array[String],
  outputs : Array[String],
) -> LineageOperation {
  if id == "" || name == "" || outputs.length() == 0 {
    abort("LineageOperation: id, name and outputs are required")
  }
  {
    id,
    name,
    inputs,
    outputs,
    started_at: 0,
    finished_at: 0,
    status: "planned",
    code_revision: "",
  }
}

///|
pub fn LineageOperation::started(
  self : LineageOperation,
  at : Int,
) -> LineageOperation {
  if at < 0 {
    abort("LineageOperation: timestamp must be non-negative")
  }
  { ..self, started_at: at, status: "running" }
}

///|
pub fn LineageOperation::completed(
  self : LineageOperation,
  at : Int,
) -> LineageOperation {
  if at < self.started_at {
    abort("LineageOperation: completion precedes start")
  }
  { ..self, finished_at: at, status: "succeeded" }
}

///|
pub fn LineageOperation::failed(
  self : LineageOperation,
  at : Int,
) -> LineageOperation {
  if at < self.started_at {
    abort("LineageOperation: failure precedes start")
  }
  { ..self, finished_at: at, status: "failed" }
}

///|
pub fn LineageOperation::with_revision(
  self : LineageOperation,
  revision : String,
) -> LineageOperation {
  { ..self, code_revision: revision }
}

///|
pub struct LineageGraph {
  assets : Array[LineageAsset]
  operations : Array[LineageOperation]
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn LineageGraph::new() -> LineageGraph {
  { assets: [], operations: [] }
}

///|
fn lineage_find_asset(assets : Array[LineageAsset], id : String) -> Int {
  for index in 0..<assets.length() {
    if assets[index].id == id {
      return index
    }
  }
  -1
}

///|
fn lineage_find_operation(
  operations : Array[LineageOperation],
  id : String,
) -> Int {
  for index in 0..<operations.length() {
    if operations[index].id == id {
      return index
    }
  }
  -1
}

///|
pub fn LineageGraph::register_asset(
  self : LineageGraph,
  asset : LineageAsset,
) -> LineageGraph {
  if lineage_find_asset(self.assets, asset.id) >= 0 {
    let assets = self.assets.copy()
    assets[lineage_find_asset(assets, asset.id)] = asset
    { ..self, assets, }
  } else {
    let assets = self.assets.copy()
    assets.push(asset)
    { ..self, assets, }
  }
}

///|
pub fn LineageGraph::asset(self : LineageGraph, id : String) -> LineageAsset? {
  let index = lineage_find_asset(self.assets, id)
  if index < 0 {
    None
  } else {
    Some(self.assets[index])
  }
}

///|
pub fn LineageGraph::record(
  self : LineageGraph,
  operation : LineageOperation,
) -> LineageGraph {
  for input in operation.inputs.iter() {
    if lineage_find_asset(self.assets, input) < 0 {
      abort("LineageGraph: operation references unknown input " + input)
    }
  }
  for output in operation.outputs.iter() {
    if lineage_find_asset(self.assets, output) < 0 {
      abort("LineageGraph: operation references unknown output " + output)
    }
  }
  let operations = self.operations.copy()
  let existing = lineage_find_operation(operations, operation.id)
  if existing >= 0 {
    operations[existing] = operation
  } else {
    operations.push(operation)
  }
  { ..self, operations, }
}

///|
pub fn LineageGraph::asset_count(self : LineageGraph) -> Int {
  self.assets.length()
}

///|
pub fn LineageGraph::operation_count(self : LineageGraph) -> Int {
  self.operations.length()
}

///|
fn lineage_unique_push(values : Array[String], value : String) -> Unit {
  if !values.contains(value) {
    values.push(value)
  }
}

///|
fn lineage_direct_inputs(
  graph : LineageGraph,
  asset_id : String,
) -> Array[String] {
  let result : Array[String] = []
  for operation in graph.operations.iter() {
    if operation.outputs.contains(asset_id) {
      for input in operation.inputs.iter() {
        lineage_unique_push(result, input)
      }
    }
  }
  result
}

///|
fn lineage_direct_outputs(
  graph : LineageGraph,
  asset_id : String,
) -> Array[String] {
  let result : Array[String] = []
  for operation in graph.operations.iter() {
    if operation.inputs.contains(asset_id) {
      for output in operation.outputs.iter() {
        lineage_unique_push(result, output)
      }
    }
  }
  result
}

///|
pub fn LineageGraph::upstream(
  self : LineageGraph,
  asset_id : String,
) -> Array[String] {
  if self.asset(asset_id) is None {
    abort("LineageGraph::upstream: unknown asset")
  }
  let result : Array[String] = []
  let mut frontier = lineage_direct_inputs(self, asset_id)
  while frontier.length() > 0 {
    let next : Array[String] = []
    for candidate in frontier.iter() {
      if !result.contains(candidate) {
        result.push(candidate)
        for parent in lineage_direct_inputs(self, candidate) {
          if !result.contains(parent) {
            next.push(parent)
          }
        }
      }
    }
    frontier = next
  }
  result
}

///|
pub fn LineageGraph::downstream(
  self : LineageGraph,
  asset_id : String,
) -> Array[String] {
  if self.asset(asset_id) is None {
    abort("LineageGraph::downstream: unknown asset")
  }
  let result : Array[String] = []
  let mut frontier = lineage_direct_outputs(self, asset_id)
  while frontier.length() > 0 {
    let next : Array[String] = []
    for candidate in frontier.iter() {
      if !result.contains(candidate) {
        result.push(candidate)
        for child in lineage_direct_outputs(self, candidate) {
          if !result.contains(child) {
            next.push(child)
          }
        }
      }
    }
    frontier = next
  }
  result
}

///|
pub fn LineageGraph::impact(
  self : LineageGraph,
  asset_id : String,
) -> Array[String] {
  self.downstream(asset_id)
}

///|
pub fn LineageGraph::operations_for(
  self : LineageGraph,
  asset_id : String,
) -> Array[LineageOperation] {
  let result : Array[LineageOperation] = []
  for operation in self.operations.iter() {
    if operation.inputs.contains(asset_id) ||
      operation.outputs.contains(asset_id) {
      result.push(operation)
    }
  }
  result
}

///|
pub struct ContractIssue {
  field : String
  message : String
  blocking : Bool
} derive(Debug, Eq, ToJson, FromJson)

///|
pub struct DataContractSpec {
  name : String
  required_columns : Array[String]
  min_rows : Int
  max_age : Int
  owner : String
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn DataContractSpec::new(name : String) -> DataContractSpec {
  if name == "" {
    abort("DataContractSpec: name is required")
  }
  { name, required_columns: [], min_rows: 0, max_age: 0, owner: "" }
}

///|
pub fn DataContractSpec::require(
  self : DataContractSpec,
  column : String,
) -> DataContractSpec {
  if column == "" {
    abort("DataContractSpec: column is required")
  }
  if self.required_columns.contains(column) {
    self
  } else {
    let required_columns = self.required_columns.copy()
    required_columns.push(column)
    { ..self, required_columns, }
  }
}

///|
pub fn DataContractSpec::at_least(
  self : DataContractSpec,
  rows : Int,
) -> DataContractSpec {
  if rows < 0 {
    abort("DataContractSpec: minimum rows must be non-negative")
  }
  { ..self, min_rows: rows }
}

///|
pub fn DataContractSpec::fresh_within(
  self : DataContractSpec,
  age : Int,
) -> DataContractSpec {
  if age <= 0 {
    abort("DataContractSpec: freshness window must be positive")
  }
  { ..self, max_age: age }
}

///|
pub fn DataContractSpec::owned_by(
  self : DataContractSpec,
  owner : String,
) -> DataContractSpec {
  { ..self, owner, }
}

///|
pub fn validate_data_contract(
  contract : DataContractSpec,
  columns : Array[String],
  rows : Int,
  now : Int,
  updated_at : Int,
) -> Array[ContractIssue] {
  if rows < 0 || now < 0 || updated_at < 0 {
    abort("validate_data_contract: counts and timestamps must be non-negative")
  }
  let result : Array[ContractIssue] = []
  for required in contract.required_columns.iter() {
    if !columns.contains(required) {
      result.push({
        field: required,
        message: "required column is missing",
        blocking: true,
      })
    }
  }
  if rows < contract.min_rows {
    result.push({
      field: "rows",
      message: "row count is below contract minimum",
      blocking: true,
    })
  }
  if contract.max_age > 0 &&
    (now < updated_at || now - updated_at > contract.max_age) {
    result.push({
      field: "freshness",
      message: "asset is outside freshness window",
      blocking: true,
    })
  }
  result
}

///|
pub fn contract_passes(issues : Array[ContractIssue]) -> Bool {
  for issue in issues.iter() {
    if issue.blocking {
      return false
    }
  }
  true
}

///|
pub struct LineageFreshnessWindow {
  updated_at : Int
  now : Int
  age : Int
  fresh : Bool
  stale_by : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn assess_freshness(
  updated_at : Int,
  now : Int,
  maximum_age : Int,
) -> LineageFreshnessWindow {
  if updated_at < 0 || now < updated_at || maximum_age <= 0 {
    abort("assess_freshness: invalid timestamps or maximum age")
  }
  let age = now - updated_at
  {
    updated_at,
    now,
    age,
    fresh: age <= maximum_age,
    stale_by: (age - maximum_age).max(0),
  }
}

///|
pub struct LineageAuditEvent {
  asset_id : String
  event : String
  actor : String
  at : Int
  details : String
} derive(Debug, Eq, ToJson, FromJson)

///|
pub struct LineageAudit {
  events : Array[LineageAuditEvent]
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn LineageAudit::new() -> LineageAudit {
  { events: [] }
}

///|
pub fn LineageAudit::append(
  self : LineageAudit,
  asset_id : String,
  event : String,
  actor : String,
  at : Int,
  details : String,
) -> LineageAudit {
  if asset_id == "" || event == "" || at < 0 {
    abort("LineageAudit: asset, event and timestamp are required")
  }
  let events = self.events.copy()
  events.push({ asset_id, event, actor, at, details })
  { events, }
}

///|
pub fn LineageAudit::for_asset(
  self : LineageAudit,
  asset_id : String,
) -> Array[LineageAuditEvent] {
  self.events.filter(fn(event) { event.asset_id == asset_id })
}

///|
pub fn LineageAudit::latest(
  self : LineageAudit,
  asset_id : String,
) -> LineageAuditEvent? {
  let matches = self.for_asset(asset_id)
  if matches.length() == 0 {
    None
  } else {
    Some(matches[matches.length() - 1])
  }
}

///|
pub fn LineageAudit::event_count(self : LineageAudit) -> Int {
  self.events.length()
}

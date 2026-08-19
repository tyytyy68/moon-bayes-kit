///|
/// Reproducible model registry and deployment governance primitives.
pub enum ModelStage {
  Draft
  Validating
  Staging
  Production
  Archived
  Rejected
} derive(Debug, Eq, ToJson, FromJson)

///|
pub enum ApprovalStatus {
  Pending
  Approved
  Blocked
  Expired
} derive(Debug, Eq, ToJson, FromJson)

///|
pub enum DeploymentStrategy {
  Shadow
  Canary
  BlueGreen
  Rolling
  Batch
} derive(Debug, Eq, ToJson, FromJson)

///|
pub struct FeatureSignature {
  name : String
  data_type : String
  required : Bool
  default_value : String
  minimum : Double
  maximum : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn FeatureSignature::accepts(
  self : FeatureSignature,
  value : Double,
) -> Bool {
  value == value && value >= self.minimum && value <= self.maximum
}

///|
pub fn FeatureSignature::is_bounded(self : FeatureSignature) -> Bool {
  self.minimum < self.maximum
}

///|
pub struct ModelMetric {
  name : String
  value : Double
  threshold : Double
  higher_is_better : Bool
  validation_set : String
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn ModelMetric::passes(self : ModelMetric) -> Bool {
  if self.higher_is_better {
    self.value >= self.threshold
  } else {
    self.value <= self.threshold
  }
}

///|
pub fn ModelMetric::margin(self : ModelMetric) -> Double {
  if self.higher_is_better {
    self.value - self.threshold
  } else {
    self.threshold - self.value
  }
}

///|
pub struct ModelVersion {
  name : String
  version : String
  artifact_uri : String
  source_revision : String
  created_at : Int
  stage : ModelStage
  metrics : Array[ModelMetric]
  features : Array[FeatureSignature]
  tags : Array[String]
  owner : String
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn ModelVersion::new(
  name : String,
  version : String,
  artifact_uri : String,
) -> ModelVersion {
  if name == "" || version == "" || artifact_uri == "" {
    abort("ModelVersion: identifying fields cannot be empty")
  }
  {
    name,
    version,
    artifact_uri,
    source_revision: "",
    created_at: 0,
    stage: ModelStage::Draft,
    metrics: [],
    features: [],
    tags: [],
    owner: "",
  }
}

///|
pub fn ModelVersion::with_revision(
  self : ModelVersion,
  revision : String,
  created_at : Int,
) -> ModelVersion {
  { ..self, source_revision: revision, created_at }
}

///|
pub fn ModelVersion::with_owner(
  self : ModelVersion,
  owner : String,
) -> ModelVersion {
  { ..self, owner, }
}

///|
pub fn ModelVersion::add_metric(
  self : ModelVersion,
  metric : ModelMetric,
) -> ModelVersion {
  let metrics = self.metrics.copy()
  metrics.push(metric)
  { ..self, metrics, }
}

///|
pub fn ModelVersion::add_feature(
  self : ModelVersion,
  feature : FeatureSignature,
) -> ModelVersion {
  let features = self.features.copy()
  features.push(feature)
  { ..self, features, }
}

///|
pub fn ModelVersion::add_tag(self : ModelVersion, tag : String) -> ModelVersion {
  let tags = self.tags.copy()
  if !tags.contains(tag) {
    tags.push(tag)
  }
  { ..self, tags, }
}

///|
pub fn ModelVersion::all_metrics_pass(self : ModelVersion) -> Bool {
  self.metrics.all(fn(metric) { metric.passes() })
}

///|
pub fn ModelVersion::metric(self : ModelVersion, name : String) -> Double {
  for metric in self.metrics.iter() {
    if metric.name == name {
      return metric.value
    }
  }
  abort("ModelVersion: metric not found")
}

///|
pub fn ModelVersion::feature_count(self : ModelVersion) -> Int {
  self.features.length()
}

///|
pub fn ModelVersion::required_features(self : ModelVersion) -> Array[String] {
  self.features
  .filter(fn(feature) { feature.required })
  .map(fn(feature) { feature.name })
}

///|
pub fn ModelVersion::is_deployable(self : ModelVersion) -> Bool {
  self.stage != ModelStage::Rejected &&
  self.stage != ModelStage::Archived &&
  self.all_metrics_pass() &&
  self.artifact_uri != "" &&
  self.source_revision != ""
}

///|
pub struct ValidationGate {
  name : String
  required_metrics : Array[String]
  minimum_score : Double
  maximum_error_rate : Double
  maximum_drift : Double
  require_revision : Bool
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn ValidationGate::production() -> ValidationGate {
  {
    name: "production",
    required_metrics: [],
    minimum_score: 0.8,
    maximum_error_rate: 0.05,
    maximum_drift: 0.2,
    require_revision: true,
  }
}

///|
pub fn ValidationGate::accepts(
  self : ValidationGate,
  model : ModelVersion,
  score : Double,
  error_rate : Double,
  drift : Double,
) -> Bool {
  let required_ok = self.required_metrics.all(fn(name) {
    model.metrics.any(fn(metric) { metric.name == name && metric.passes() })
  })
  required_ok &&
  score >= self.minimum_score &&
  error_rate <= self.maximum_error_rate &&
  drift <= self.maximum_drift &&
  (!self.require_revision || model.source_revision != "")
}

///|
pub struct GateResult {
  gate : String
  accepted : Bool
  failed_checks : Array[String]
  score : Double
  error_rate : Double
  drift : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn evaluate_gate(
  gate : ValidationGate,
  model : ModelVersion,
  score : Double,
  error_rate : Double,
  drift : Double,
) -> GateResult {
  let failures : Array[String] = []
  if score < gate.minimum_score {
    failures.push("score")
  }
  if error_rate > gate.maximum_error_rate {
    failures.push("error_rate")
  }
  if drift > gate.maximum_drift {
    failures.push("drift")
  }
  if gate.require_revision && model.source_revision == "" {
    failures.push("source_revision")
  }
  for metric in gate.required_metrics.iter() {
    if !model.metrics.any(fn(item) { item.name == metric && item.passes() }) {
      failures.push(metric)
    }
  }
  {
    gate: gate.name,
    accepted: failures.length() == 0,
    failed_checks: failures,
    score,
    error_rate,
    drift,
  }
}

///|
pub struct Approval {
  reviewer : String
  status : ApprovalStatus
  comment : String
  timestamp : Int
  expires_at : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn Approval::is_active(self : Approval, now : Int) -> Bool {
  self.status == ApprovalStatus::Approved &&
  (self.expires_at == 0 || now <= self.expires_at)
}

///|
pub fn Approval::approve(
  reviewer : String,
  comment : String,
  timestamp : Int,
  expires_at : Int,
) -> Approval {
  if reviewer == "" {
    abort("Approval: reviewer cannot be empty")
  }
  { reviewer, status: ApprovalStatus::Approved, comment, timestamp, expires_at }
}

///|
pub struct DeploymentRecord {
  model_name : String
  model_version : String
  strategy : DeploymentStrategy
  stage : ModelStage
  traffic_percent : Double
  replicas : Int
  started_at : Int
  ended_at : Int
  rollback_version : String
  approvals : Array[Approval]
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn DeploymentRecord::new(
  model_name : String,
  model_version : String,
  strategy : DeploymentStrategy,
) -> DeploymentRecord {
  {
    model_name,
    model_version,
    strategy,
    stage: ModelStage::Staging,
    traffic_percent: 0.0,
    replicas: 1,
    started_at: 0,
    ended_at: 0,
    rollback_version: "",
    approvals: [],
  }
}

///|
pub fn DeploymentRecord::set_traffic(
  self : DeploymentRecord,
  percent : Double,
) -> DeploymentRecord {
  if percent < 0.0 || percent > 100.0 {
    abort("DeploymentRecord: traffic must be in [0, 100]")
  }
  { ..self, traffic_percent: percent }
}

///|
pub fn DeploymentRecord::set_replicas(
  self : DeploymentRecord,
  replicas : Int,
) -> DeploymentRecord {
  if replicas <= 0 {
    abort("DeploymentRecord: replicas must be positive")
  }
  { ..self, replicas, }
}

///|
pub fn DeploymentRecord::with_rollback(
  self : DeploymentRecord,
  version : String,
) -> DeploymentRecord {
  { ..self, rollback_version: version }
}

///|
pub fn DeploymentRecord::add_approval(
  self : DeploymentRecord,
  approval : Approval,
) -> DeploymentRecord {
  let approvals = self.approvals.copy()
  approvals.push(approval)
  { ..self, approvals, }
}

///|
pub fn DeploymentRecord::approved(self : DeploymentRecord, now : Int) -> Bool {
  self.approvals.any(fn(approval) { approval.is_active(now) })
}

///|
pub fn DeploymentRecord::is_complete(self : DeploymentRecord) -> Bool {
  self.ended_at > self.started_at && self.traffic_percent >= 100.0
}

///|
pub enum AuditAction {
  Registered
  MetricUpdated
  GateEvaluated
  Approved
  Deployed
  Promoted
  RolledBack
  Archived
} derive(Debug, Eq, ToJson, FromJson)

///|
pub struct AuditEvent {
  model_name : String
  version : String
  action : AuditAction
  actor : String
  timestamp : Int
  details : String
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn AuditEvent::new(
  model_name : String,
  version : String,
  action : AuditAction,
  actor : String,
  timestamp : Int,
  details : String,
) -> AuditEvent {
  { model_name, version, action, actor, timestamp, details }
}

///|
pub struct Registry {
  models : Array[ModelVersion]
  deployments : Array[DeploymentRecord]
  audit : Array[AuditEvent]
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn Registry::new() -> Registry {
  { models: [], deployments: [], audit: [] }
}

///|
pub fn Registry::register(
  self : Registry,
  model : ModelVersion,
  actor : String,
  timestamp : Int,
) -> Registry {
  if self.models.any(fn(item) {
      item.name == model.name && item.version == model.version
    }) {
    abort("Registry: model version already exists")
  }
  let models = self.models.copy()
  models.push(model)
  let audit = self.audit.copy()
  audit.push(
    AuditEvent::new(
      models[models.length() - 1].name,
      models[models.length() - 1].version,
      AuditAction::Registered,
      actor,
      timestamp,
      "registered model version",
    ),
  )
  { ..self, models, audit }
}

///|
pub fn Registry::find(
  self : Registry,
  name : String,
  version : String,
) -> ModelVersion {
  for model in self.models.iter() {
    if model.name == name && model.version == version {
      return model
    }
  }
  abort("Registry: model version not found")
}

///|
pub fn Registry::versions(
  self : Registry,
  name : String,
) -> Array[ModelVersion] {
  self.models.filter(fn(model) { model.name == name })
}

///|
pub fn Registry::latest(self : Registry, name : String) -> ModelVersion {
  let models = self.versions(name)
  if models.length() == 0 {
    abort("Registry: model has no versions")
  }
  models[models.length() - 1]
}

///|
pub fn Registry::promote(
  self : Registry,
  name : String,
  version : String,
  target : ModelStage,
  gate : ValidationGate,
  score : Double,
  error_rate : Double,
  drift : Double,
  actor : String,
  timestamp : Int,
) -> (Registry, GateResult) {
  let model = self.find(name, version)
  let result = evaluate_gate(gate, model, score, error_rate, drift)
  if !result.accepted {
    return (self, result)
  }
  let models = self.models.map(fn(item) {
    if item.name == name && item.version == version {
      { ..item, stage: target }
    } else {
      item
    }
  })
  let audit = self.audit.copy()
  audit.push(
    AuditEvent::new(
      name,
      version,
      AuditAction::Promoted,
      actor,
      timestamp,
      "passed validation gate",
    ),
  )
  ({ ..self, models, audit }, result)
}

///|
pub fn Registry::deploy(
  self : Registry,
  record : DeploymentRecord,
  actor : String,
  timestamp : Int,
) -> Registry {
  let model = self.find(record.model_name, record.model_version)
  if !model.is_deployable() {
    abort("Registry: model is not deployable")
  }
  let deployments = self.deployments.copy()
  deployments.push({
    ..record,
    stage: ModelStage::Production,
    started_at: timestamp,
  })
  let audit = self.audit.copy()
  audit.push(
    AuditEvent::new(
      record.model_name,
      record.model_version,
      AuditAction::Deployed,
      actor,
      timestamp,
      "deployment started",
    ),
  )
  { ..self, deployments, audit }
}

///|
pub fn Registry::rollback(
  self : Registry,
  name : String,
  version : String,
  rollback_version : String,
  actor : String,
  timestamp : Int,
) -> Registry {
  let model = self.find(name, version)
  let target = self.find(name, rollback_version)
  if target.stage == ModelStage::Rejected ||
    target.stage == ModelStage::Archived {
    abort("Registry: rollback target is unavailable")
  }
  let deployments = self.deployments.map(fn(item) {
    if item.model_name == name && item.model_version == version {
      {
        ..item,
        rollback_version,
        stage: ModelStage::Archived,
        ended_at: timestamp,
      }
    } else {
      item
    }
  })
  let audit = self.audit.copy()
  audit.push(
    AuditEvent::new(
      model.name,
      model.version,
      AuditAction::RolledBack,
      actor,
      timestamp,
      "rolled back deployment",
    ),
  )
  { ..self, deployments, audit }
}

///|
pub fn Registry::production(
  self : Registry,
  name : String,
) -> Array[ModelVersion] {
  self.models.filter(fn(model) {
    model.name == name && model.stage == ModelStage::Production
  })
}

///|
pub fn Registry::audit_for(self : Registry, name : String) -> Array[AuditEvent] {
  self.audit.filter(fn(event) { event.model_name == name })
}

///|
pub struct CompatibilityReport {
  compatible : Bool
  missing : Array[String]
  type_changes : Array[String]
  newly_required : Array[String]
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn compare_feature_signatures(
  old : ModelVersion,
  newer : ModelVersion,
) -> CompatibilityReport {
  let missing : Array[String] = []
  let changes : Array[String] = []
  let newly_required : Array[String] = []
  for feature in old.features.iter() {
    let found = newer.features.filter(fn(item) { item.name == feature.name })
    if found.length() == 0 {
      missing.push(feature.name)
    } else if found[0].data_type != feature.data_type {
      changes.push(feature.name)
    }
  }
  for feature in newer.features.iter() {
    if feature.required &&
      !old.features.any(fn(item) { item.name == feature.name }) {
      newly_required.push(feature.name)
    }
  }
  {
    compatible: missing.length() == 0 &&
    changes.length() == 0 &&
    newly_required.length() == 0,
    missing,
    type_changes: changes,
    newly_required,
  }
}

///|
pub fn registry_health(registry : Registry, now : Int) -> Double {
  if registry.models.length() == 0 {
    return 1.0
  }
  let deployable = registry.models
    .filter(fn(model) { model.is_deployable() })
    .length()
  let active_approvals = registry.deployments
    .filter(fn(item) { item.approved(now) })
    .length()
  let coverage = deployable.to_double() / registry.models.length().to_double()
  let deployment = if registry.deployments.length() == 0 {
    1.0
  } else {
    active_approvals.to_double() / registry.deployments.length().to_double()
  }
  (0.7 * coverage + 0.3 * deployment).min(1.0)
}

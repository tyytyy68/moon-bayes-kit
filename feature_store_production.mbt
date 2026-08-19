///|
/// Feature-store contracts, point-in-time lookup, and freshness governance.
pub enum FeatureValueKind {
  Numeric
  Boolean
  Text
  Vector
} derive(Debug, Eq, ToJson, FromJson)

///|
pub struct FeatureDefinition {
  name : String
  kind : FeatureValueKind
  entity : String
  description : String
  default_value : Double
  ttl_seconds : Int
  owner : String
  tags : Array[String]
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn FeatureDefinition::new(
  name : String,
  entity : String,
  kind : FeatureValueKind,
) -> FeatureDefinition {
  if name == "" || entity == "" {
    abort("FeatureDefinition: name and entity are required")
  }
  {
    name,
    kind,
    entity,
    description: "",
    default_value: 0.0,
    ttl_seconds: 0,
    owner: "",
    tags: [],
  }
}

///|
pub fn FeatureDefinition::with_ttl(
  self : FeatureDefinition,
  ttl_seconds : Int,
) -> FeatureDefinition {
  if ttl_seconds < 0 {
    abort("FeatureDefinition: ttl must be non-negative")
  }
  { ..self, ttl_seconds, }
}

///|
pub fn FeatureDefinition::with_default(
  self : FeatureDefinition,
  default_value : Double,
) -> FeatureDefinition {
  { ..self, default_value, }
}

///|
pub fn FeatureDefinition::tagged(
  self : FeatureDefinition,
  tag : String,
) -> FeatureDefinition {
  let tags = self.tags.copy()
  if !tags.contains(tag) {
    tags.push(tag)
  }
  { ..self, tags, }
}

///|
pub struct FeatureObservation {
  entity_id : String
  feature : String
  value : Double
  event_time : Int
  ingest_time : Int
  source : String
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn FeatureObservation::new(
  entity_id : String,
  feature : String,
  value : Double,
  event_time : Int,
) -> FeatureObservation {
  { entity_id, feature, value, event_time, ingest_time: event_time, source: "" }
}

///|
pub fn FeatureObservation::with_ingest_time(
  self : FeatureObservation,
  ingest_time : Int,
) -> FeatureObservation {
  { ..self, ingest_time, }
}

///|
pub fn FeatureObservation::is_late(self : FeatureObservation) -> Bool {
  self.ingest_time > self.event_time
}

///|
pub fn FeatureObservation::age(self : FeatureObservation, now : Int) -> Int {
  (now - self.event_time).max(0)
}

///|
pub struct FeatureSnapshot {
  entity_id : String
  as_of : Int
  values : Array[(String, Double)]
  missing : Array[String]
  late_count : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn FeatureSnapshot::new(entity_id : String, as_of : Int) -> FeatureSnapshot {
  { entity_id, as_of, values: [], missing: [], late_count: 0 }
}

///|
pub fn FeatureSnapshot::get(self : FeatureSnapshot, feature : String) -> Double {
  for item in self.values.iter() {
    if item.0 == feature {
      return item.1
    }
  }
  0.0
}

///|
pub fn FeatureSnapshot::has(self : FeatureSnapshot, feature : String) -> Bool {
  self.values.any(fn(item) { item.0 == feature })
}

///|
pub fn FeatureSnapshot::vector(
  self : FeatureSnapshot,
  definitions : Array[FeatureDefinition],
) -> Array[Double] {
  definitions.map(fn(definition) { self.get(definition.name) })
}

///|
pub struct FeatureStore {
  definitions : Array[FeatureDefinition]
  observations : Array[FeatureObservation]
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn FeatureStore::new() -> FeatureStore {
  { definitions: [], observations: [] }
}

///|
pub fn FeatureStore::register(
  self : FeatureStore,
  definition : FeatureDefinition,
) -> FeatureStore {
  if self.definitions.any(fn(item) { item.name == definition.name }) {
    abort("FeatureStore: feature already registered")
  }
  let definitions = self.definitions.copy()
  definitions.push(definition)
  { ..self, definitions, }
}

///|
pub fn FeatureStore::definition(
  self : FeatureStore,
  name : String,
) -> FeatureDefinition {
  for definition in self.definitions.iter() {
    if definition.name == name {
      return definition
    }
  }
  abort("FeatureStore: definition not found")
}

///|
pub fn FeatureStore::write(
  self : FeatureStore,
  observation : FeatureObservation,
) -> FeatureStore {
  let _ = self.definition(observation.feature)
  let observations = self.observations.copy()
  observations.push(observation)
  { ..self, observations, }
}

///|
pub fn FeatureStore::write_batch(
  self : FeatureStore,
  observations : Array[FeatureObservation],
) -> FeatureStore {
  let mut result = self
  for observation in observations.iter() {
    result = result.write(observation)
  }
  result
}

///|
pub fn FeatureStore::lookup(
  self : FeatureStore,
  entity_id : String,
  feature_names : Array[String],
  as_of : Int,
) -> FeatureSnapshot {
  let values : Array[(String, Double)] = []
  let missing : Array[String] = []
  let mut late_count = 0
  for name in feature_names.iter() {
    let definition = self.definition(name)
    let mut found = false
    let mut best_time = -1
    let mut best_value = definition.default_value
    for observation in self.observations.iter() {
      if observation.entity_id == entity_id &&
        observation.feature == name &&
        observation.event_time <= as_of &&
        observation.event_time >= best_time {
        found = true
        best_time = observation.event_time
        best_value = observation.value
        if observation.is_late() {
          late_count = late_count + 1
        }
      }
    }
    if found {
      values.push((name, best_value))
    } else {
      missing.push(name)
      values.push((name, definition.default_value))
    }
  }
  { entity_id, as_of, values, missing, late_count }
}

///|
pub fn FeatureStore::batch_lookup(
  self : FeatureStore,
  entity_ids : Array[String],
  feature_names : Array[String],
  as_of : Int,
) -> Array[FeatureSnapshot] {
  entity_ids.map(fn(entity_id) { self.lookup(entity_id, feature_names, as_of) })
}

///|
pub fn FeatureStore::observations_for(
  self : FeatureStore,
  entity_id : String,
  feature : String,
) -> Array[FeatureObservation] {
  self.observations.filter(fn(item) {
    item.entity_id == entity_id && item.feature == feature
  })
}

///|
pub fn FeatureStore::freshness(
  self : FeatureStore,
  feature : String,
  now : Int,
) -> Double {
  let definition = self.definition(feature)
  let values = self.observations.filter(fn(item) {
    item.feature == feature && item.event_time <= now
  })
  if values.length() == 0 || definition.ttl_seconds == 0 {
    return 1.0
  }
  let latest = values.fold(init=values[0].event_time, (current, item) => {
    current.max(item.event_time)
  })
  let age = (now - latest).max(0)
  (1.0 - age.to_double() / definition.ttl_seconds.to_double()).max(0.0)
}

///|
pub struct FeatureFreshness {
  feature : String
  score : Double
  latest_event : Int
  stale : Bool
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn FeatureStore::freshness_report(
  self : FeatureStore,
  now : Int,
) -> Array[FeatureFreshness] {
  let result : Array[FeatureFreshness] = []
  for definition in self.definitions.iter() {
    let values = self.observations.filter(fn(item) {
      item.feature == definition.name && item.event_time <= now
    })
    let latest = if values.length() == 0 {
      -1
    } else {
      values.fold(init=values[0].event_time, (current, item) => {
        current.max(item.event_time)
      })
    }
    let score = self.freshness(definition.name, now)
    result.push({
      feature: definition.name,
      score,
      latest_event: latest,
      stale: score < 0.5,
    })
  }
  result
}

///|
pub struct FeatureDrift {
  feature : String
  baseline_mean : Double
  current_mean : Double
  standardized_shift : Double
  population_stability : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn feature_drift(
  feature : String,
  baseline : Array[Double],
  current : Array[Double],
) -> FeatureDrift {
  if baseline.length() == 0 || current.length() == 0 {
    abort("feature_drift: empty sample")
  }
  let base_mean = mean(baseline)
  let current_mean = mean(current)
  let scale = variance(baseline).sqrt().max(0.000000000001)
  let psi = (current_mean - base_mean).abs() / scale
  {
    feature,
    baseline_mean: base_mean,
    current_mean,
    standardized_shift: (current_mean - base_mean) / scale,
    population_stability: psi,
  }
}

///|
pub struct FeatureStoreHealth {
  definitions : Int
  observations : Int
  missing_rate : Double
  stale_rate : Double
  drift_rate : Double
  score : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn feature_store_health(
  store : FeatureStore,
  now : Int,
) -> FeatureStoreHealth {
  let reports = store.freshness_report(now)
  let stale = reports.filter(fn(item) { item.stale }).length()
  let mut missing = 0
  let mut lookups = 0
  for observation in store.observations.iter() {
    if observation.value != observation.value {
      missing = missing + 1
    }
    lookups = lookups + 1
  }
  let missing_rate = if lookups == 0 {
    0.0
  } else {
    missing.to_double() / lookups.to_double()
  }
  let stale_rate = if reports.length() == 0 {
    0.0
  } else {
    stale.to_double() / reports.length().to_double()
  }
  {
    definitions: store.definitions.length(),
    observations: store.observations.length(),
    missing_rate,
    stale_rate,
    drift_rate: 0.0,
    score: (1.0 - missing_rate - stale_rate).max(0.0),
  }
}

///|
pub enum MaterializationMode {
  Online
  Offline
  Hybrid
} derive(Debug, Eq, ToJson, FromJson)

///|
pub struct MaterializationJob {
  feature : String
  mode : MaterializationMode
  start_time : Int
  end_time : Int
  rows_written : Int
  status : PipelineStatus
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn MaterializationJob::new(
  feature : String,
  mode : MaterializationMode,
  start_time : Int,
  end_time : Int,
) -> MaterializationJob {
  if end_time < start_time {
    abort("MaterializationJob: invalid time range")
  }
  {
    feature,
    mode,
    start_time,
    end_time,
    rows_written: 0,
    status: PipelineStatus::Pending,
  }
}

///|
pub fn MaterializationJob::complete(
  self : MaterializationJob,
  rows : Int,
) -> MaterializationJob {
  { ..self, rows_written: rows.max(0), status: PipelineStatus::Succeeded }
}

///|
pub fn MaterializationJob::fail(
  self : MaterializationJob,
) -> MaterializationJob {
  { ..self, status: PipelineStatus::Failed }
}

///|
pub fn materialize(
  store : FeatureStore,
  feature : String,
  entity_ids : Array[String],
  start_time : Int,
  end_time : Int,
) -> (FeatureStore, MaterializationJob) {
  let job = MaterializationJob::new(
    feature,
    MaterializationMode::Offline,
    start_time,
    end_time,
  )
  let result = store
  let mut rows = 0
  for entity in entity_ids.iter() {
    let observations = result.observations_for(entity, feature)
    for observation in observations.iter() {
      if observation.event_time >= start_time &&
        observation.event_time <= end_time {
        rows = rows + 1
      }
    }
  }
  (result, job.complete(rows))
}

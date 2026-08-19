///|
/// Schema contracts and compatibility checks for data interfaces.
pub enum SchemaType {
  Integer
  Number
  Boolean
  String
  Timestamp
  Array
  Object
} derive(Debug, Eq, ToJson, FromJson)

///|
pub struct SchemaField {
  name : String
  kind : SchemaType
  required : Bool
  nullable : Bool
  repeated : Bool
  description : String
  tags : Array[String]
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn SchemaField::new(name : String, kind : SchemaType) -> SchemaField {
  if name == "" {
    abort("SchemaField: name cannot be empty")
  }
  {
    name,
    kind,
    required: false,
    nullable: true,
    repeated: false,
    description: "",
    tags: [],
  }
}

///|
pub fn SchemaField::required(self : SchemaField) -> SchemaField {
  { ..self, required: true, nullable: false }
}

///|
pub fn SchemaField::optional(self : SchemaField) -> SchemaField {
  { ..self, required: false, nullable: true }
}

///|
pub fn SchemaField::array(self : SchemaField) -> SchemaField {
  { ..self, repeated: true }
}

///|
pub fn SchemaField::tag(self : SchemaField, value : String) -> SchemaField {
  let tags = self.tags.copy()
  if !tags.contains(value) {
    tags.push(value)
  }
  { ..self, tags, }
}

///|
pub struct DataSchema {
  name : String
  version : String
  fields : Array[SchemaField]
  primary_key : Array[String]
  owner : String
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn DataSchema::new(name : String, version : String) -> DataSchema {
  { name, version, fields: [], primary_key: [], owner: "" }
}

///|
pub fn DataSchema::add(self : DataSchema, field : SchemaField) -> DataSchema {
  if self.fields.any(fn(item) { item.name == field.name }) {
    abort("DataSchema: duplicate field")
  }
  let fields = self.fields.copy()
  fields.push(field)
  { ..self, fields, }
}

///|
pub fn DataSchema::key(self : DataSchema, fields : Array[String]) -> DataSchema {
  for field in fields.iter() {
    if !self.fields.any(fn(item) { item.name == field }) {
      abort("DataSchema: key field not found")
    }
  }
  { ..self, primary_key: fields }
}

///|
pub fn DataSchema::field(self : DataSchema, name : String) -> SchemaField {
  for field in self.fields.iter() {
    if field.name == name {
      return field
    }
  }
  abort("DataSchema: field not found")
}

///|
pub fn DataSchema::required_fields(self : DataSchema) -> Array[String] {
  self.fields.filter(fn(field) { field.required }).map(fn(field) { field.name })
}

///|
pub fn DataSchema::field_count(self : DataSchema) -> Int {
  self.fields.length()
}

///|
pub fn DataSchema::fingerprint(self : DataSchema) -> String {
  self.name +
  ":" +
  self.version +
  ":" +
  self.fields.map(fn(field) { field.name }).join(",")
}

///|
pub struct SchemaChange {
  field : String
  breaking : Bool
  description : String
} derive(Debug, Eq, ToJson, FromJson)

///|
pub struct SchemaCompatibility {
  compatible : Bool
  changes : Array[SchemaChange]
  added : Int
  removed : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn compare_schemas(
  old : DataSchema,
  newer : DataSchema,
) -> SchemaCompatibility {
  let changes : Array[SchemaChange] = []
  for old_field in old.fields.iter() {
    let matches = newer.fields.filter(fn(field) { field.name == old_field.name })
    if matches.length() == 0 {
      changes.push({
        field: old_field.name,
        breaking: old_field.required,
        description: "field removed",
      })
    } else if matches[0].kind != old_field.kind {
      changes.push({
        field: old_field.name,
        breaking: true,
        description: "field type changed",
      })
    } else if old_field.nullable && !matches[0].nullable {
      changes.push({
        field: old_field.name,
        breaking: true,
        description: "field became non-nullable",
      })
    }
  }
  for new_field in newer.fields.iter() {
    if !old.fields.any(fn(field) { field.name == new_field.name }) {
      changes.push({
        field: new_field.name,
        breaking: new_field.required,
        description: "field added",
      })
    }
  }
  {
    compatible: !changes.any(fn(change) { change.breaking }),
    changes,
    added: newer.fields.length().max(old.fields.length()) -
    old.fields.length().min(newer.fields.length()),
    removed: old.fields
    .filter(fn(field) {
      !newer.fields.any(fn(item) { item.name == field.name })
    })
    .length(),
  }
}

///|
pub struct RowValidation {
  valid : Bool
  missing_required : Array[String]
  unknown_fields : Array[String]
  type_errors : Array[String]
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn validate_row(
  schema : DataSchema,
  present : Array[String],
  numeric_fields : Array[String],
) -> RowValidation {
  let missing : Array[String] = []
  let unknown : Array[String] = []
  let type_errors : Array[String] = []
  for field in schema.required_fields() {
    if !present.contains(field) {
      missing.push(field)
    }
  }
  for field in present {
    if !schema.fields.any(fn(item) { item.name == field }) {
      unknown.push(field)
    }
  }
  for field in numeric_fields {
    if schema.fields.any(fn(item) {
        item.name == field && item.kind == SchemaType::String
      }) {
      type_errors.push(field)
    }
  }
  {
    valid: missing.length() == 0 && type_errors.length() == 0,
    missing_required: missing,
    unknown_fields: unknown,
    type_errors,
  }
}

///|
pub fn schema_quality(schema : DataSchema) -> Double {
  if schema.fields.length() == 0 {
    return 0.0
  }
  let described = schema.fields
    .filter(fn(field) { field.description != "" })
    .length()
  described.to_double() / schema.fields.length().to_double()
}

///|
pub enum MigrationAction {
  AddField
  RemoveField
  RenameField
  CastField
  SetDefault
  RelaxConstraint
} derive(Debug, Eq, ToJson, FromJson)

///|
pub struct SchemaMigration {
  from_version : String
  to_version : String
  action : MigrationAction
  field : String
  target : String
  reversible : Bool
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn generate_migrations(
  old : DataSchema,
  newer : DataSchema,
) -> Array[SchemaMigration] {
  let result : Array[SchemaMigration] = []
  for field in newer.fields.iter() {
    if !old.fields.any(fn(item) { item.name == field.name }) {
      result.push({
        from_version: old.version,
        to_version: newer.version,
        action: MigrationAction::AddField,
        field: field.name,
        target: "",
        reversible: true,
      })
    }
  }
  for field in old.fields.iter() {
    if !newer.fields.any(fn(item) { item.name == field.name }) {
      result.push({
        from_version: old.version,
        to_version: newer.version,
        action: MigrationAction::RemoveField,
        field: field.name,
        target: "",
        reversible: false,
      })
    }
  }
  result
}

///|
pub fn apply_numeric_default(
  values : Array[Double],
  default_value : Double,
) -> Array[Double] {
  values.map(fn(value) { if value != value { default_value } else { value } })
}

///|
pub fn schema_required_coverage(
  schema : DataSchema,
  observed : Array[String],
) -> Double {
  let required = schema.required_fields()
  if required.length() == 0 {
    1.0
  } else {
    required.filter(fn(field) { observed.contains(field) }).length().to_double() /
    required.length().to_double()
  }
}

///|
pub fn schema_has_unique_key(schema : DataSchema) -> Bool {
  schema.primary_key.length() > 0 &&
  schema.primary_key.all(fn(field) {
    schema.fields.any(fn(item) { item.name == field })
  })
}

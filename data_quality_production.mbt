///|
/// Data quality primitives for validating model and analytics inputs.
pub enum QualitySeverity {
  Info
  Warning
  Error
  Critical
} derive(Debug, Eq, ToJson, FromJson)

///|
pub enum QualityRuleKind {
  Required
  NumericRange
  StringLength
  AllowedValues
  Unique
  Monotonic
  Freshness
  Cardinality
  DistributionDrift
  NullRate
} derive(Debug, Eq, ToJson, FromJson)

///|
pub struct QualityIssue {
  rule : String
  column : String
  severity : QualitySeverity
  row : Int
  value : String
  message : String
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn QualityIssue::new(
  rule : String,
  column : String,
  severity : QualitySeverity,
  row : Int,
  value : String,
  message : String,
) -> QualityIssue {
  { rule, column, severity, row, value, message }
}

///|
pub fn QualityIssue::is_blocking(self : QualityIssue) -> Bool {
  match self.severity {
    QualitySeverity::Error | QualitySeverity::Critical => true
    _ => false
  }
}

///|
pub struct ColumnProfile {
  name : String
  count : Int
  missing : Int
  distinct : Int
  numeric : Bool
  minimum : Double
  maximum : Double
  mean : Double
  variance : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn ColumnProfile::missing_rate(self : ColumnProfile) -> Double {
  if self.count == 0 {
    0.0
  } else {
    self.missing.to_double() / self.count.to_double()
  }
}

///|
pub fn ColumnProfile::null_rate(self : ColumnProfile) -> Double {
  self.missing_rate()
}

///|
pub fn ColumnProfile::observed(self : ColumnProfile) -> Int {
  self.count - self.missing
}

///|
pub fn ColumnProfile::range(self : ColumnProfile) -> Double {
  self.maximum - self.minimum
}

///|
pub fn ColumnProfile::has_values(self : ColumnProfile) -> Bool {
  self.observed() > 0
}

///|
pub struct QualityReport {
  dataset : String
  rows : Int
  columns : Int
  checked_rules : Int
  passed_rules : Int
  issues : Array[QualityIssue]
  profiles : Array[ColumnProfile]
  score : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn QualityReport::new(dataset : String, rows : Int) -> QualityReport {
  if rows < 0 {
    abort("QualityReport: rows must be non-negative")
  }
  {
    dataset,
    rows,
    columns: 0,
    checked_rules: 0,
    passed_rules: 0,
    issues: [],
    profiles: [],
    score: 1.0,
  }
}

///|
pub fn QualityReport::has_errors(self : QualityReport) -> Bool {
  self.issues.any(fn(issue) { issue.is_blocking() })
}

///|
pub fn QualityReport::issue_count(self : QualityReport) -> Int {
  self.issues.length()
}

///|
pub fn QualityReport::error_count(self : QualityReport) -> Int {
  self.issues.filter(fn(issue) { issue.is_blocking() }).length()
}

///|
pub fn QualityReport::warning_count(self : QualityReport) -> Int {
  self.issues
  .filter(fn(issue) { issue.severity == QualitySeverity::Warning })
  .length()
}

///|
pub fn QualityReport::pass_rate(self : QualityReport) -> Double {
  if self.checked_rules == 0 {
    1.0
  } else {
    self.passed_rules.to_double() / self.checked_rules.to_double()
  }
}

///|
pub fn QualityReport::quality_score(self : QualityReport) -> Double {
  self.score
}

///|
pub fn QualityReport::issues(self : QualityReport) -> Array[QualityIssue] {
  self.issues.copy()
}

///|
pub fn QualityReport::profiles(self : QualityReport) -> Array[ColumnProfile] {
  self.profiles.copy()
}

///|
fn append_issue(report : QualityReport, issue : QualityIssue) -> QualityReport {
  let issues = report.issues.copy()
  issues.push(issue)
  let penalty = match issues[issues.length() - 1].severity {
    QualitySeverity::Info => 0.0
    QualitySeverity::Warning => 0.02
    QualitySeverity::Error => 0.08
    QualitySeverity::Critical => 0.2
  }
  { ..report, issues, score: (report.score - penalty).max(0.0) }
}

///|
fn checked(report : QualityReport, passed : Bool) -> QualityReport {
  {
    ..report,
    checked_rules: report.checked_rules + 1,
    passed_rules: if passed {
      report.passed_rules + 1
    } else {
      report.passed_rules
    },
  }
}

///|
pub fn check_required(
  report : QualityReport,
  column : String,
  values : Array[String],
  severity : QualitySeverity,
) -> QualityReport {
  let mut result = report
  let mut missing = 0
  for index in 0..<values.length() {
    let value = values[index]
    if value == "" || value == "null" || value == "NA" {
      missing = missing + 1
      result = append_issue(
        result,
        QualityIssue::new(
          "required", column, severity, index, value, "required value is missing",
        ),
      )
    }
  }
  if missing == 0 {
    checked(result, true)
  } else {
    checked(result, false)
  }
}

///|
pub fn check_null_rate(
  report : QualityReport,
  column : String,
  values : Array[String],
  maximum_rate : Double,
) -> QualityReport {
  if maximum_rate < 0.0 || maximum_rate > 1.0 {
    abort("check_null_rate: rate must be in [0, 1]")
  }
  let mut missing = 0
  for value in values.iter() {
    if value == "" || value == "null" {
      missing = missing + 1
    }
  }
  let rate = if values.length() == 0 {
    0.0
  } else {
    missing.to_double() / values.length().to_double()
  }
  if rate > maximum_rate {
    checked(
      append_issue(
        report,
        QualityIssue::new(
          "null_rate",
          column,
          QualitySeverity::Error,
          -1,
          rate.to_string(),
          "null rate exceeds threshold",
        ),
      ),
      false,
    )
  } else {
    checked(report, true)
  }
}

///|
pub fn check_numeric_range(
  report : QualityReport,
  column : String,
  values : Array[Double],
  minimum : Double,
  maximum : Double,
  severity : QualitySeverity,
) -> QualityReport {
  if minimum > maximum {
    abort("check_numeric_range: inverted range")
  }
  let mut result = report
  let mut valid = true
  for index in 0..<values.length() {
    let value = values[index]
    if value < minimum || value > maximum {
      valid = false
      result = append_issue(
        result,
        QualityIssue::new(
          "numeric_range",
          column,
          severity,
          index,
          value.to_string(),
          "value is outside the allowed range",
        ),
      )
    }
  }
  checked(result, valid)
}

///|
pub fn check_finite(
  report : QualityReport,
  column : String,
  values : Array[Double],
) -> QualityReport {
  let mut result = report
  let mut valid = true
  for index in 0..<values.length() {
    let value = values[index]
    if value != value {
      valid = false
      result = append_issue(
        result,
        QualityIssue::new(
          "finite",
          column,
          QualitySeverity::Critical,
          index,
          value.to_string(),
          "non-finite numeric value",
        ),
      )
    }
  }
  checked(result, valid)
}

///|
pub fn check_monotonic(
  report : QualityReport,
  column : String,
  values : Array[Double],
  increasing : Bool,
) -> QualityReport {
  let mut result = report
  let mut valid = true
  if values.length() > 1 {
    for index in 1..<values.length() {
      let violation = if increasing {
        values[index] < values[index - 1]
      } else {
        values[index] > values[index - 1]
      }
      if violation {
        valid = false
        result = append_issue(
          result,
          QualityIssue::new(
            "monotonic",
            column,
            QualitySeverity::Error,
            index,
            values[index].to_string(),
            "ordering constraint violated",
          ),
        )
      }
    }
  }
  checked(result, valid)
}

///|
pub fn check_unique(
  report : QualityReport,
  column : String,
  values : Array[String],
) -> QualityReport {
  let mut result = report
  let seen : Array[String] = []
  let mut valid = true
  for index in 0..<values.length() {
    let value = values[index]
    if seen.contains(value) {
      valid = false
      result = append_issue(
        result,
        QualityIssue::new(
          "unique",
          column,
          QualitySeverity::Error,
          index,
          value,
          "duplicate value",
        ),
      )
    } else {
      seen.push(value)
    }
  }
  checked(result, valid)
}

///|
pub fn check_allowed_values(
  report : QualityReport,
  column : String,
  values : Array[String],
  allowed : Array[String],
) -> QualityReport {
  let mut result = report
  let mut valid = true
  for index in 0..<values.length() {
    let value = values[index]
    if !allowed.contains(value) {
      valid = false
      result = append_issue(
        result,
        QualityIssue::new(
          "allowed_values",
          column,
          QualitySeverity::Error,
          index,
          value,
          "value is not in the allowed set",
        ),
      )
    }
  }
  checked(result, valid)
}

///|
pub fn check_string_length(
  report : QualityReport,
  column : String,
  values : Array[String],
  minimum : Int,
  maximum : Int,
) -> QualityReport {
  if minimum < 0 || minimum > maximum {
    abort("check_string_length: invalid bounds")
  }
  let mut result = report
  let mut valid = true
  for index in 0..<values.length() {
    let value = values[index]
    let length = value.length()
    if length < minimum || length > maximum {
      valid = false
      result = append_issue(
        result,
        QualityIssue::new(
          "string_length",
          column,
          QualitySeverity::Warning,
          index,
          value,
          "string length outside bounds",
        ),
      )
    }
  }
  checked(result, valid)
}

///|
pub fn check_cardinality(
  report : QualityReport,
  column : String,
  values : Array[String],
  minimum : Int,
  maximum : Int,
) -> QualityReport {
  let distinct : Array[String] = []
  for value in values.iter() {
    if !distinct.contains(value) {
      distinct.push(value)
    }
  }
  let valid = distinct.length() >= minimum && distinct.length() <= maximum
  if !valid {
    checked(
      append_issue(
        report,
        QualityIssue::new(
          "cardinality",
          column,
          QualitySeverity::Warning,
          -1,
          distinct.length().to_string(),
          "distinct count outside bounds",
        ),
      ),
      false,
    )
  } else {
    checked(report, true)
  }
}

///|
pub fn check_distribution_drift(
  report : QualityReport,
  column : String,
  baseline : Array[Double],
  current : Array[Double],
  threshold : Double,
) -> QualityReport {
  if baseline.length() == 0 || current.length() == 0 || threshold < 0.0 {
    abort("check_distribution_drift: invalid inputs")
  }
  let baseline_mean = mean(baseline)
  let current_mean = mean(current)
  let scale = baseline
    .map(fn(value) { (value - baseline_mean).abs() })
    .fold(init=0.0, (total, value) => total + value)
  let drift = (current_mean - baseline_mean).abs() /
    (scale / baseline.length().to_double() + 0.000000000001)
  if drift > threshold {
    checked(
      append_issue(
        report,
        QualityIssue::new(
          "distribution_drift",
          column,
          QualitySeverity::Warning,
          -1,
          drift.to_string(),
          "mean drift exceeds threshold",
        ),
      ),
      false,
    )
  } else {
    checked(report, true)
  }
}

///|
pub fn profile_numeric(
  column : String,
  values : Array[Double],
) -> ColumnProfile {
  if values.length() == 0 {
    return {
      name: column,
      count: 0,
      missing: 0,
      distinct: 0,
      numeric: true,
      minimum: 0.0,
      maximum: 0.0,
      mean: 0.0,
      variance: 0.0,
    }
  }
  let distinct : Array[Double] = []
  for value in values.iter() {
    if !distinct.contains(value) {
      distinct.push(value)
    }
  }
  {
    name: column,
    count: values.length(),
    missing: 0,
    distinct: distinct.length(),
    numeric: true,
    minimum: values.fold(init=values[0], (a, b) => a.min(b)),
    maximum: values.fold(init=values[0], (a, b) => a.max(b)),
    mean: mean(values),
    variance: variance(values),
  }
}

///|
pub fn profile_strings(
  column : String,
  values : Array[String],
) -> ColumnProfile {
  let mut missing = 0
  let distinct : Array[String] = []
  for value in values.iter() {
    if value == "" || value == "null" {
      missing = missing + 1
    }
    if !distinct.contains(value) {
      distinct.push(value)
    }
  }
  {
    name: column,
    count: values.length(),
    missing,
    distinct: distinct.length(),
    numeric: false,
    minimum: 0.0,
    maximum: 0.0,
    mean: 0.0,
    variance: 0.0,
  }
}

///|
pub fn append_profile(
  report : QualityReport,
  profile : ColumnProfile,
) -> QualityReport {
  let profiles = report.profiles.copy()
  profiles.push(profile)
  { ..report, columns: profiles.length(), profiles }
}

///|
pub struct FreshnessWindow {
  latest : Int
  now : Int
  maximum_age : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn FreshnessWindow::is_fresh(self : FreshnessWindow) -> Bool {
  self.latest >= self.now - self.maximum_age
}

///|
pub fn FreshnessWindow::age(self : FreshnessWindow) -> Int {
  (self.now - self.latest).max(0)
}

///|
pub fn check_freshness(
  report : QualityReport,
  column : String,
  timestamps : Array[Int],
  now : Int,
  maximum_age : Int,
) -> QualityReport {
  if maximum_age < 0 {
    abort("check_freshness: maximum age must be non-negative")
  }
  let latest = if timestamps.length() == 0 {
    0
  } else {
    timestamps.fold(init=timestamps[0], (a, b) => a.max(b))
  }
  let window = FreshnessWindow::{ latest, now, maximum_age }
  if window.is_fresh() {
    checked(report, true)
  } else {
    checked(
      append_issue(
        report,
        QualityIssue::new(
          "freshness",
          column,
          QualitySeverity::Critical,
          -1,
          window.age().to_string(),
          "dataset is stale",
        ),
      ),
      false,
    )
  }
}

///|
pub struct MissingnessSummary {
  columns : Int
  rows : Int
  total_missing : Int
  complete_rows : Int
  all_missing_columns : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn MissingnessSummary::missing_rate(self : MissingnessSummary) -> Double {
  let cells = self.columns * self.rows
  if cells <= 0 {
    0.0
  } else {
    self.total_missing.to_double() / cells.to_double()
  }
}

///|
pub fn MissingnessSummary::complete_rate(self : MissingnessSummary) -> Double {
  if self.rows <= 0 {
    1.0
  } else {
    self.complete_rows.to_double() / self.rows.to_double()
  }
}

///|
pub fn summarize_missingness(matrix : Array[Array[Bool]]) -> MissingnessSummary {
  if matrix.length() == 0 {
    return {
      columns: 0,
      rows: 0,
      total_missing: 0,
      complete_rows: 0,
      all_missing_columns: 0,
    }
  }
  let rows = matrix.length()
  let columns = matrix[0].length()
  let mut total = 0
  let mut complete = 0
  for row in matrix.iter() {
    let mut row_complete = true
    for missing in row.iter() {
      if missing {
        total = total + 1
        row_complete = false
      }
    }
    if row_complete {
      complete = complete + 1
    }
  }
  let mut all_missing = 0
  for column in 0..<columns {
    let mut missing = true
    for row in matrix.iter() {
      if !row[column] {
        missing = false
      }
    }
    if missing {
      all_missing = all_missing + 1
    }
  }
  {
    columns,
    rows,
    total_missing: total,
    complete_rows: complete,
    all_missing_columns: all_missing,
  }
}

///|
pub enum RepairAction {
  ImputeMean
  ImputeMedian
  ImputeConstant
  DropRow
  DropColumn
  ClipRange
  Deduplicate
  Reject
} derive(Debug, Eq, ToJson, FromJson)

///|
pub struct RepairPlan {
  column : String
  action : RepairAction
  parameter : Double
  affected_rows : Int
  rationale : String
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn RepairPlan::is_lossy(self : RepairPlan) -> Bool {
  match self.action {
    RepairAction::DropRow | RepairAction::DropColumn | RepairAction::Reject =>
      true
    _ => false
  }
}

///|
pub fn suggest_numeric_repairs(
  profile : ColumnProfile,
  maximum_missing_rate : Double,
) -> Array[RepairPlan] {
  let plans : Array[RepairPlan] = []
  if profile.missing_rate() > maximum_missing_rate {
    plans.push({
      column: profile.name,
      action: RepairAction::ImputeMedian,
      parameter: profile.mean,
      affected_rows: profile.missing,
      rationale: "missing rate requires a robust fill policy",
    })
  }
  if profile.minimum != profile.minimum || profile.maximum != profile.maximum {
    plans.push({
      column: profile.name,
      action: RepairAction::Reject,
      parameter: 0.0,
      affected_rows: profile.count,
      rationale: "profile contains invalid numeric bounds",
    })
  }
  if profile.variance == 0.0 && profile.observed() > 1 {
    plans.push({
      column: profile.name,
      action: RepairAction::DropColumn,
      parameter: 0.0,
      affected_rows: profile.count,
      rationale: "constant feature carries no variance",
    })
  }
  plans
}

///|
pub fn quality_gate(report : QualityReport, minimum_score : Double) -> Bool {
  if minimum_score < 0.0 || minimum_score > 1.0 {
    abort("quality_gate: score must be in [0, 1]")
  }
  !report.has_errors() && report.quality_score() >= minimum_score
}

///|
pub fn merge_quality_reports(
  left : QualityReport,
  right : QualityReport,
) -> QualityReport {
  let issues = left.issues.copy()
  for issue in right.issues.iter() {
    issues.push(issue)
  }
  let profiles = left.profiles.copy()
  for profile in right.profiles.iter() {
    profiles.push(profile)
  }
  {
    dataset: left.dataset,
    rows: left.rows.max(right.rows),
    columns: profiles.length(),
    checked_rules: left.checked_rules + right.checked_rules,
    passed_rules: left.passed_rules + right.passed_rules,
    issues,
    profiles,
    score: (left.score + right.score) / 2.0,
  }
}

///|
pub fn issue_summary(report : QualityReport) -> Array[(String, Int)] {
  let names : Array[String] = []
  let counts : Array[Int] = []
  for issue in report.issues.iter() {
    let mut found = -1
    for index in 0..<names.length() {
      if names[index] == issue.rule {
        found = index
      }
    }
    if found >= 0 {
      counts[found] = counts[found] + 1
    } else {
      names.push(issue.rule)
      counts.push(1)
    }
  }
  let result : Array[(String, Int)] = []
  for index in 0..<names.length() {
    result.push((names[index], counts[index]))
  }
  result
}

///|
pub fn weighted_quality_score(
  report : QualityReport,
  weights : Array[Double],
) -> Double {
  if weights.length() != report.issues.length() {
    abort("weighted_quality_score: weights must match issues")
  }
  let mut penalty = 0.0
  for index in 0..<weights.length() {
    let severity = match report.issues[index].severity {
      QualitySeverity::Info => 0.0
      QualitySeverity::Warning => 0.1
      QualitySeverity::Error => 0.4
      QualitySeverity::Critical => 1.0
    }
    penalty = penalty + weights[index].max(0.0) * severity
  }
  (1.0 - penalty).max(0.0)
}

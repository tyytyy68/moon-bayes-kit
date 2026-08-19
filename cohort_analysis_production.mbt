///|
/// Cohort and fairness analysis for model evaluation. Cohorts are represented
/// as ordinary strings, which keeps the report portable across data stores and
/// makes subgroup regressions easy to serialize into CI artifacts.
pub struct CohortObservation {
  cohort : String
  score : Double
  outcome : Bool
  weight : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn CohortObservation::new(
  cohort : String,
  score : Double,
  outcome : Bool,
) -> CohortObservation {
  if cohort == "" || score < 0.0 || score > 1.0 {
    abort("CohortObservation: invalid cohort or score")
  }
  { cohort, score, outcome, weight: 1.0 }
}

///|
pub fn CohortObservation::weighted(
  self : CohortObservation,
  weight : Double,
) -> CohortObservation {
  if weight <= 0.0 {
    abort("CohortObservation: weight must be positive")
  }
  { ..self, weight, }
}

///|
pub struct CohortMetric {
  cohort : String
  observations : Int
  weighted_observations : Double
  positive_rate : Double
  mean_score : Double
  brier : Double
  precision : Double
  recall : Double
  f1 : Double
  threshold : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub struct CohortGap {
  reference : String
  cohort : String
  score_gap : Double
  positive_rate_gap : Double
  recall_gap : Double
  precision_ratio : Double
  meets_policy : Bool
} derive(Debug, Eq, ToJson, FromJson)

///|
fn cohort_names(observations : Array[CohortObservation]) -> Array[String] {
  let result : Array[String] = []
  for observation in observations.iter() {
    if !result.contains(observation.cohort) {
      result.push(observation.cohort)
    }
  }
  result
}

///|
fn cohort_subset(
  observations : Array[CohortObservation],
  cohort : String,
) -> Array[CohortObservation] {
  observations.filter(fn(observation) { observation.cohort == cohort })
}

///|
pub fn cohort_metric(
  observations : Array[CohortObservation],
  cohort : String,
  threshold : Double,
) -> CohortMetric {
  if observations.length() == 0 {
    abort("cohort_metric: observations must not be empty")
  }
  if threshold < 0.0 || threshold > 1.0 {
    abort("cohort_metric: threshold must be in [0, 1]")
  }
  let selected = cohort_subset(observations, cohort)
  if selected.length() == 0 {
    abort("cohort_metric: cohort is not present")
  }
  let scores = selected.map(fn(item) { item.score })
  let outcomes = selected.map(fn(item) { item.outcome })
  let metrics = threshold_confusion_matrix(scores, outcomes, threshold)
  let mut weighted_total = 0.0
  let mut positive_weight = 0.0
  for item in selected.iter() {
    weighted_total = weighted_total + item.weight
    if item.outcome {
      positive_weight = positive_weight + item.weight
    }
  }
  let positive_rate = if weighted_total == 0.0 {
    0.0
  } else {
    positive_weight / weighted_total
  }
  {
    cohort,
    observations: selected.length(),
    weighted_observations: weighted_total,
    positive_rate,
    mean_score: weighted_mean(scores, selected.map(fn(item) { item.weight })),
    brier: calibration_brier_score(scores, outcomes),
    precision: metrics.precision(),
    recall: metrics.recall(),
    f1: metrics.f1(),
    threshold,
  }
}

///|
pub fn all_cohort_metrics(
  observations : Array[CohortObservation],
  threshold : Double,
) -> Array[CohortMetric] {
  let result : Array[CohortMetric] = []
  for cohort in cohort_names(observations).iter() {
    result.push(cohort_metric(observations, cohort, threshold))
  }
  result
}

///|
pub fn cohort_gaps(
  observations : Array[CohortObservation],
  reference : String,
  threshold : Double,
  maximum_score_gap : Double,
  maximum_recall_gap : Double,
) -> Array[CohortGap] {
  if maximum_score_gap < 0.0 || maximum_recall_gap < 0.0 {
    abort("cohort_gaps: policy tolerances must be non-negative")
  }
  let reference_metric = cohort_metric(observations, reference, threshold)
  let result : Array[CohortGap] = []
  for cohort in cohort_names(observations).iter() {
    if cohort != reference {
      let metric = cohort_metric(observations, cohort, threshold)
      let precision_ratio = if reference_metric.precision == 0.0 {
        0.0
      } else {
        metric.precision / reference_metric.precision
      }
      result.push({
        reference,
        cohort,
        score_gap: metric.mean_score - reference_metric.mean_score,
        positive_rate_gap: metric.positive_rate - reference_metric.positive_rate,
        recall_gap: metric.recall - reference_metric.recall,
        precision_ratio,
        meets_policy: (metric.mean_score - reference_metric.mean_score).abs() <=
        maximum_score_gap &&
        (metric.recall - reference_metric.recall).abs() <= maximum_recall_gap,
      })
    }
  }
  result
}

///|
pub struct CohortReport {
  metrics : Array[CohortMetric]
  gaps : Array[CohortGap]
  reference : String
  policy_passed : Bool
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn build_cohort_report(
  observations : Array[CohortObservation],
  reference : String,
  threshold : Double,
  maximum_score_gap : Double,
  maximum_recall_gap : Double,
) -> CohortReport {
  let metrics = all_cohort_metrics(observations, threshold)
  let gaps = cohort_gaps(
    observations, reference, threshold, maximum_score_gap, maximum_recall_gap,
  )
  {
    metrics,
    gaps,
    reference,
    policy_passed: gaps.fold(init=true, (passed, gap) => {
      passed && gap.meets_policy
    }),
  }
}

///|
pub struct CohortDrift {
  cohort : String
  baseline_count : Int
  current_count : Int
  count_ratio : Double
  score_shift : Double
  drifted : Bool
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn compare_cohort_distributions(
  baseline : Array[CohortObservation],
  current : Array[CohortObservation],
  minimum_count_ratio : Double,
  maximum_score_shift : Double,
) -> Array[CohortDrift] {
  if minimum_count_ratio < 0.0 || maximum_score_shift < 0.0 {
    abort("compare_cohort_distributions: invalid policy")
  }
  let names = cohort_names(baseline)
  for name in cohort_names(current).iter() {
    if !names.contains(name) {
      names.push(name)
    }
  }
  let result : Array[CohortDrift] = []
  for name in names.iter() {
    let base = cohort_subset(baseline, name)
    let now = cohort_subset(current, name)
    let base_count = base.length()
    let current_count = now.length()
    let count_ratio = if base_count == 0 {
      0.0
    } else {
      current_count.to_double() / base_count.to_double()
    }
    let base_mean = if base_count == 0 {
      0.0
    } else {
      mean(base.map(fn(item) { item.score }))
    }
    let now_mean = if current_count == 0 {
      0.0
    } else {
      mean(now.map(fn(item) { item.score }))
    }
    result.push({
      cohort: name,
      baseline_count: base_count,
      current_count,
      count_ratio,
      score_shift: now_mean - base_mean,
      drifted: count_ratio < minimum_count_ratio ||
      (now_mean - base_mean).abs() > maximum_score_shift,
    })
  }
  result
}

///|
pub struct RankingReport {
  cohorts : Array[String]
  ordering : Array[String]
  rank_gap : Int
  top_cohort : String
  bottom_cohort : String
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn rank_cohorts_by_metric(
  metrics : Array[CohortMetric],
  descending : Bool,
) -> RankingReport {
  if metrics.length() == 0 {
    abort("rank_cohorts_by_metric: metrics must not be empty")
  }
  let ordering = metrics.map(fn(item) { item.cohort })
  for left in 0..<ordering.length() {
    for right in (left + 1)..<ordering.length() {
      let left_metric = metrics.filter(fn(item) {
          item.cohort == ordering[left]
        })[0]
      let right_metric = metrics.filter(fn(item) {
          item.cohort == ordering[right]
        })[0]
      let should_swap = if descending {
        right_metric.f1 > left_metric.f1
      } else {
        right_metric.f1 < left_metric.f1
      }
      if should_swap {
        let value = ordering[left]
        ordering[left] = ordering[right]
        ordering[right] = value
      }
    }
  }
  {
    cohorts: metrics.map(fn(item) { item.cohort }),
    ordering,
    rank_gap: metrics.length() - 1,
    top_cohort: ordering[0],
    bottom_cohort: ordering[ordering.length() - 1],
  }
}

///|
pub struct EqualizedOddsGap {
  cohort : String
  false_positive_rate_gap : Double
  true_positive_rate_gap : Double
  violation : Bool
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn equalized_odds_gaps(
  observations : Array[CohortObservation],
  reference : String,
  threshold : Double,
  tolerance : Double,
) -> Array[EqualizedOddsGap] {
  if tolerance < 0.0 {
    abort("equalized_odds_gaps: tolerance must be non-negative")
  }
  let reference_observations = cohort_subset(observations, reference)
  let reference_matrix = threshold_confusion_matrix(
    reference_observations.map(fn(item) { item.score }),
    reference_observations.map(fn(item) { item.outcome }),
    threshold,
  )
  let reference_fpr = 1.0 - reference_matrix.specificity()
  let reference_tpr = reference_matrix.recall()
  let result : Array[EqualizedOddsGap] = []
  for cohort in cohort_names(observations).iter() {
    if cohort != reference {
      let selected = cohort_subset(observations, cohort)
      let matrix = threshold_confusion_matrix(
        selected.map(fn(item) { item.score }),
        selected.map(fn(item) { item.outcome }),
        threshold,
      )
      let fpr_gap = 1.0 - matrix.specificity() - reference_fpr
      let tpr_gap = matrix.recall() - reference_tpr
      result.push({
        cohort,
        false_positive_rate_gap: fpr_gap,
        true_positive_rate_gap: tpr_gap,
        violation: fpr_gap.abs() > tolerance || tpr_gap.abs() > tolerance,
      })
    }
  }
  result
}

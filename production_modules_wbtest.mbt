///|
/// Boundary and integration coverage for production modules.
test "time series and survival boundaries" {
  let series = TimeSeries::from_values([1.0, 2.0, 4.0, 8.0])
  inspect(series.len(), content="4")
  inspect(series.rolling_mean(2).at(2), content="6")
  inspect(series.difference(1).values()[0], content="1")
  let survival = KaplanMeier::fit([
    SurvivalObservation::new(1.0, EventStatus::Event),
    SurvivalObservation::new(2.0, EventStatus::Censored),
    SurvivalObservation::new(3.0, EventStatus::Event),
  ])
  inspect(survival.steps().length(), content="3")
  inspect(survival.survival_at(0.0), content="1")
  inspect(survival.survival_at(4.0) < 1.0, content="true")
}

///|
test "quality and schema gates" {
  let report = QualityReport::new("events", 3)
    |> check_required("id", ["a", "", "c"], QualitySeverity::Error)
    |> check_numeric_range(
      "score",
      [0.1, 0.5, 2.0],
      0.0,
      1.0,
      QualitySeverity::Warning,
    )
  inspect(report.has_errors(), content="true")
  inspect(report.issue_count(), content="2")
  let schema = DataSchema::new("events", "1").add(
    SchemaField::new("id", SchemaType::String).required(),
  )
  inspect(schema.field_count(), content="1")
  inspect(validate_row(schema, ["id"], []).valid, content="true")
}

///|
test "experiment and causal estimates" {
  let control = ExperimentArm::new("control")
    .record(0.0)
    .record(1.0)
    .record(0.0)
  let treatment = ExperimentArm::new("treatment")
    .record(1.0)
    .record(1.0)
    .record(1.0)
  let effect = compare_arms(control, treatment)
  inspect(effect.difference > 0.0, content="true")
  let observations = [
    CausalObservation::new(true, 2.0, 0.5),
    CausalObservation::new(false, 1.0, 0.5),
  ]
  inspect(inverse_probability_effect(observations).estimate, content="1")
}

///|
test "registry and feature store" {
  let model = ModelVersion::new("risk", "1", "artifact")
    .with_revision("abc", 1)
    .add_metric({
      name: "auc",
      value: 0.9,
      threshold: 0.8,
      higher_is_better: true,
      validation_set: "holdout",
    })
  inspect(model.is_deployable(), content="true")
  let feature = FeatureDefinition::new("age", "user", FeatureValueKind::Numeric).with_ttl(
    100,
  )
  let store = FeatureStore::new()
    .register(feature)
    .write(FeatureObservation::new("u1", "age", 30.0, 10))
  inspect(store.lookup("u1", ["age"], 10).get("age"), content="30")
  inspect(store.lookup("u2", ["age"], 10).missing.length(), content="1")
}

///|
test "uncertainty and ensemble diagnostics" {
  let calibrator = ConformalCalibrator::fit([1.0, -2.0, 0.5, -1.5], 0.8)
  let interval = calibrator.interval(10.0)
  inspect(interval.contains(10.0), content="true")
  let members = [
    EnsembleMember::new("a", [1.0, 2.0]).with_loss(0.2),
    EnsembleMember::new("b", [3.0, 4.0]).with_loss(0.4),
  ]
  let combined = combine_predictions(members, EnsembleMode::Mean)
  inspect(combined.values.length(), content="2")
  inspect(combined.values[0], content="2")
}

///|
test "privacy and decision boundaries" {
  let budget = PrivacyBudget::new(1.0, 0.1).spend(0.2, 0.01)
  inspect(budget.remaining_epsilon(), content="0.8")
  inspect(randomized_response(true, 1.0, 0.9), content="true")
  let cost = DecisionCost::new(1.0, 3.0)
  let report = threshold_report(
    [0.9, 0.2, 0.8, 0.1],
    [true, false, true, false],
    0.5,
    cost,
  )
  inspect(report.accuracy, content="1")
  inspect(
    optimize_threshold([0.9, 0.2], [true, false], cost, 10).threshold >= 0.0,
    content="true",
  )
}

///|
test "graph and pipeline execution" {
  let graph = WeightedGraph::new(3, true)
    .add_edge(GraphEdge::new(0, 1, 1.0))
    .add_edge(GraphEdge::new(1, 2, 2.0))
  debug_inspect(graph_bfs(graph, 0), content="[0, 1, 2]")
  inspect(dijkstra(graph, 0, 2).reachable, content="true")
  let plan = PipelinePlan::new("events", "1")
    .add(PipelineStage::new("source", StageKind::Source))
    .add(PipelineStage::new("sink", StageKind::Sink).depends_on("source"))
  debug_inspect(plan.topological_order(), content="[\"source\", \"sink\"]")
}

///|
test "state space and factor inference" {
  let model = KalmanModel::scalar(1.0, 0.1, 0.5)
  let updates = kalman_filter(
    model,
    [1.0, 1.2, 0.9],
    kalman_initial(0.0, 1.0, 0),
  )
  inspect(updates.length(), content="3")
  inspect(updates[2].estimate.mean[0] > 0.0, content="true")
  let variable = DiscreteVariable::new("coin", 2)
  let factor = Factor::new([variable], [0.25, 0.75]).normalize()
  inspect(factor.sum(), content="1")
  inspect(factor.marginalize("coin").values[0], content="1")
}

///|
test "monte carlo and distributed summaries" {
  let summary = DistributedSummary::new().push_all([1.0, 2.0, 3.0, 4.0])
  let merged = DistributedSummary::new()
    .push_all([1.0, 2.0])
    .merge(DistributedSummary::new().push_all([3.0, 4.0]))
  inspect(summary.variance(), content="1.6666666666666667")
  inspect(merged.mean, content="2.5")
  let quantiles = QuantileSketch::new(4).push_all([1.0, 2.0, 3.0, 4.0])
  inspect(quantiles.quantile(0.5), content="2.5")
  let rate = RateSummary::new().record(true, 1.0).record(false, 1.0)
  inspect(rate.rate(), content="0.5")
  let (_, estimate) = integrate_uniform(
    DeterministicRng::new(7UL),
    0.0,
    1.0,
    100,
    fn(x) { x },
  )
  inspect(estimate.estimate > 0.3 && estimate.estimate < 0.7, content="true")
  inspect(effective_sample_size([1.0, 2.0, 1.0, 2.0], 1) > 0.0, content="true")
}

///|
test "numerical and optimization boundaries" {
  let bracket = RootBracket::new(0.0, 3.0, fn(x) { x * x - 4.0 })
  let root = solve_bisection(fn(x) { x * x - 4.0 }, bracket, 0.000001, 80)
  inspect(root.converged, content="true")
  inspect((root.value - 2.0).abs() < 0.001, content="true")
  let linear = solve_linear_system(
    [[2.0, 0.0], [0.0, 4.0]],
    [4.0, 8.0],
    0.000001,
  )
  inspect(linear.solved, content="true")
  let fit = fit_linear_model(
    [[0.0], [1.0], [2.0], [3.0]],
    [1.0, 3.0, 5.0, 7.0],
    OptimizationConfig::new().with_learning_rate(0.1).with_iterations(100),
  )
  inspect(fit.predict([4.0]) > 7.0, content="true")
}

///|
test "calibration and robust diagnostics" {
  let calibration = calibration_report(
    [0.0, 1.0, 0.0, 1.0],
    [false, true, false, true],
    4,
  )
  inspect(calibration.is_calibrated(0.001), content="true")
  let matrix = threshold_confusion_matrix(
    [0.9, 0.1, 0.8, 0.2],
    [true, false, true, false],
    0.5,
  )
  inspect(matrix.f1(), content="1")
  inspect(
    roc_auc([0.9, 0.1, 0.8, 0.2], [true, false, true, false]) > 0.99,
    content="true",
  )
  let robust = robust_observations(
    [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 20.0],
    1.5,
  )
  inspect(robust.filter(fn(item) { item.outlier }).length(), content="1")
  inspect(RobustScaler::fit([1.0, 2.0, 3.0], 5.0).transform(2.0), content="0")
}

///|
test "lineage and serving controls" {
  let source = LineageAsset::new("raw", "dataset", "team", "1")
  let feature = LineageAsset::new("features", "feature_set", "team", "1")
  let graph = LineageGraph::new()
    .register_asset(source)
    .register_asset(feature)
    .record(
      LineageOperation::new("transform", "build features", ["raw"], ["features"]),
    )
  debug_inspect(graph.downstream("raw"), content="[\"features\"]")
  let contract = DataContractSpec::new("events").require("id").at_least(2)
  inspect(
    contract_passes(validate_data_contract(contract, ["id"], 3, 10, 10)),
    content="true",
  )
  let request = ServingRequest::new("r1", "u1", [0.2, 0.3], 10)
  let prediction = ServingPrediction::new("r1", 0.4, "risk", "v1", 12, 11)
  let log = PredictionAuditLog::new(2).append(request, prediction)
  inspect(log.entry_count(), content="1")
  let health = ServiceHealth::new(0)
    .record(1, 10.0, true)
    .record(2, 20.0, false)
  inspect(health.error_rate(), content="0.5")
}

///|
test "risk cohorts and experiment gates" {
  let scorecard = RiskScorecard::new(-1.0)
    .add_feature(RiskFeatureContribution::new("age", 2.0, 1.0))
    .add_band(RiskBand::new("low", 0.0, 0.5, "accept"))
    .add_band(RiskBand::new("high", 0.5, 1.0, "review"))
  inspect(scorecard.probability() > 0.5, content="true")
  inspect(decide_risk(scorecard, 10.0, 1.0, 5.0).action, content="review")
  let observations = [
    CohortObservation::new("a", 0.9, true),
    CohortObservation::new("a", 0.1, false),
    CohortObservation::new("b", 0.8, true),
    CohortObservation::new("b", 0.2, false),
  ]
  inspect(
    build_cohort_report(observations, "a", 0.5, 0.2, 0.2).policy_passed,
    content="true",
  )
  let control = AnalysisArm::new("control").record(1.0).record(1.0).record(2.0)
  let treatment = AnalysisArm::new("treatment")
    .record(2.0)
    .record(2.0)
    .record(3.0)
  inspect(
    compare_analysis_arms(control, treatment).estimate > 0.0,
    content="true",
  )
  let guardrails = evaluate_guardrails([
    GuardrailMetric::new("retention", 0.8, 0.79, 0.95, 0.1),
  ])
  inspect(guardrails.passed, content="true")
  inspect(
    plan_binary_experiment(0.2, 0.05, 0.05, 0.8).required_per_arm > 2,
    content="true",
  )
}

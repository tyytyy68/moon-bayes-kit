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
test "fixed latency kernels" {
  inspect(fixed_mean_003([1.0, 2.0, 3.0]), content="2")
  inspect(fixed_variance_003([1.0, 2.0, 3.0]), content="0.6666666666666666")
  inspect(fixed_median_003([3.0, 1.0, 2.0]), content="2")
  inspect(
    fixed_absolute_deviation_003([1.0, 2.0, 3.0]),
    content="0.6666666666666666",
  )
}

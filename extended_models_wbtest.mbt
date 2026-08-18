///|
test "negative binomial and unknown variance models" {
  let beta = BetaNegativeBinomial::new(2.0, 2.0).update(3, 1)
  inspect(beta.successes(), content="3")
  inspect(beta.failures(), content="1")
  inspect(beta.posterior_mean(), content="0.625")
  inspect(beta.total_observations(), content="4")
  let normal = NormalInverseGamma::new(0.0, 1.0, 2.0, 2.0).update(3.0, 1.0, 4)
  inspect(normal.observations(), content="4")
  inspect(normal.posterior_mean(), content="2.4")
  inspect(normal.predictive_variance() > 0.0, content="true")
}

///|
test "categorical classifier" {
  let classifier = CategoricalNaiveBayes::new([0, 1], 2, 3).fit([0, 0, 1, 1], [
    [0, 0],
    [0, 1],
    [2, 2],
    [2, 1],
  ])
  inspect(classifier.class_count(), content="2")
  inspect(classifier.vocabulary_size(), content="3")
  inspect(classifier.predict([0, 0]), content="0")
  inspect(classifier.predict([2, 2]), content="1")
  inspect(
    classifier.accuracy([0, 0, 1, 1], [[0, 0], [0, 1], [2, 2], [2, 1]]),
    content="1",
  )
}

///|
test "online ridge and experiment log" {
  let ridge = OnlineRidge::new(2, 0.1, 1.0).fit(
    [[1.0, 0.0], [1.0, 1.0], [1.0, 2.0]],
    [1.0, 3.0, 5.0],
  )
  inspect(ridge.updates(), content="3")
  inspect(ridge.predict([1.0, 3.0]) > 5.0, content="true")
  inspect(ridge.coefficients().length(), content="2")
  let log = ExperimentLog::new("calibration").record(0.8, 1.0).record(0.5, 1.0)
  inspect(log.len(), content="2")
  inspect(log.best_step(), content="1")
  inspect(log.improvement(), content="0.30000000000000004")
}

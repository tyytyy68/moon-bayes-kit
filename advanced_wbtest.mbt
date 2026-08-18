///|
test "online statistics are mergeable" {
  let left = OnlineStats::new().push_all([1.0, 2.0, 3.0])
  let right = OnlineStats::new().push_all([4.0, 5.0])
  let merged = left.merge(right)
  inspect(merged.count(), content="5")
  inspect(merged.mean(), content="3")
  inspect(merged.variance(), content="2.5")
  inspect(mean([1.0, 2.0, 3.0, 4.0]), content="2.5")
  inspect(quantile([9.0, 1.0, 5.0, 3.0], 0.5), content="4")
}

///|
test "probability utilities" {
  debug_inspect(
    normalize_probabilities([2.0, 3.0, 5.0]),
    content="[0.2, 0.3, 0.5]",
  )
  inspect(weighted_mean([10.0, 20.0], [1.0, 3.0]), content="17.5")
  inspect(covariance([1.0, 2.0, 3.0], [2.0, 4.0, 8.0]), content="3")
}

///|
test "predictive distributions normalize" {
  let beta = BetaBinomial::new(2.0, 3.0)
  let distribution = beta.predictive_distribution(8)
  inspect(distribution.length(), content="9")
  inspect(sum(distribution) > 0.99, content="true")
  inspect(beta.predictive_quantile(8, 0.5), content="3")
  let gamma = GammaPoisson::new(2.0, 2.0)
  inspect(gamma.predictive_probability(0), content="0.4444444444444444")
  let categorical = DirichletMultinomial::new([2.0, 1.0, 1.0])
  debug_inspect(categorical.sample_without_randomness(10), content="[6, 2, 2]")
}

///|
test "diagnostics" {
  let matrix = ConfusionMatrix::new()
    .add(true, true)
    .add(true, false)
    .add(false, true)
    .add(false, false)
  inspect(matrix.accuracy(), content="0.5")
  inspect(matrix.precision(), content="0.5")
  inspect(matrix.recall(), content="0.5")
  inspect(matrix.f1(), content="0.5")
  inspect(brier_score([0.9, 0.2], [true, false]), content="0.025")
  inspect(
    root_mean_squared_error([1.0, 2.0], [2.0, 2.0]),
    content="0.7071067811865476",
  )
  let bin = CalibrationBin::new(0.0, 1.0).add(0.8, true).add(0.6, false)
  inspect(bin.count(), content="2")
  inspect(bin.observed_rate(), content="0.5")
}

///|
test "matrix operations" {
  let matrix = DenseMatrix::from_rows([[2.0, 1.0], [1.0, 2.0]])
  debug_inspect(matrix.matvec([3.0, 4.0]), content="[10, 11]")
  inspect(matrix.trace(), content="4")
  inspect(matrix.is_symmetric(), content="true")
  let factor = cholesky(matrix)
  debug_inspect(
    factor.matvec([1.0, 0.0]),
    content="[1.4142135623730951, 0.7071067811865475]",
  )
  let product = matrix.matmul(matrix)
  debug_inspect(product.row(0), content="[5, 4]")
}

///|
test "bayesian regression" {
  let model = BayesianLinearRegression::new([0.0, 0.0], 100.0, 1.0)
  let fitted = model.fit([[1.0, 0.0], [1.0, 1.0], [1.0, 2.0]], [1.0, 3.0, 5.0])
  let coefficients = fitted.posterior_mean()
  inspect(coefficients.length(), content="2")
  inspect(fitted.observations(), content="3")
  inspect(fitted.predict([1.0, 3.0]) > 6.0, content="true")
  inspect(fitted.predict([1.0, 3.0]) < 7.0, content="true")
  inspect(
    fitted.r_squared([[1.0, 0.0], [1.0, 1.0], [1.0, 2.0]], [1.0, 3.0, 5.0]) >
    0.99,
    content="true",
  )
}

///|
test "stream ledger replays observations" {
  let ledger = UpdateLedger::new(
      BetaBinomial::new(1.0, 1.0),
      GammaPoisson::new(1.0, 1.0),
      NormalNormal::new(0.0, 1.0, 1.0),
      DirichletMultinomial::new([1.0, 1.0]),
    )
    .push(Binary(successes=3, trials=4))
    .push(Counts(sum=5, observations=2))
    .push(Continuous(mean=2.0, observations=2))
    .push(Categorical(index=1))
  inspect(ledger.len(), content="4")
  inspect(ledger.binary().posterior_mean(), content="0.6666666666666666")
  inspect(ledger.counts().posterior_mean(), content="2")
  inspect(ledger.continuous().posterior_mean(), content="1.3333333333333333")
  debug_inspect(
    ledger.categorical().posterior_mean(),
    content="[0.3333333333333333, 0.6666666666666666]",
  )
}

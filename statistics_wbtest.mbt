///|
test "advanced statistics" {
  inspect(median([9.0, 1.0, 5.0, 3.0]), content="4")
  inspect(interquartile_range([1.0, 2.0, 3.0, 4.0]), content="1.5")
  inspect(median_absolute_deviation([1.0, 2.0, 3.0, 4.0]), content="1")
  inspect(correlation([1.0, 2.0, 3.0], [2.0, 4.0, 6.0]), content="1")
  inspect(percentile_rank([1.0, 2.0, 3.0, 4.0], 3.0), content="0.75")
  debug_inspect(histogram([0.1, 0.2, 0.9], 0.0, 1.0, 2), content="[2, 1]")
  debug_inspect(moving_average([1.0, 2.0, 3.0], 2), content="[1, 1.5, 2.5]")
  debug_inspect(cumulative_sum([1.0, -1.0, 2.0]), content="[1, 0, 2]")
  inspect(autocorrelation([1.0, 2.0, 3.0], 0), content="1")
  inspect(empirical_entropy([1, 1, 2, 2]) > 0.0, content="true")
}

///|
test "matrix algorithms" {
  let matrix = DenseMatrix::from_rows([[1.0, 2.0], [3.0, 4.0]])
  inspect(matrix.determinant(), content="-2")
  debug_inspect(matrix.diagonal(), content="[1, 4]")
  inspect(matrix.frobenius_norm(), content="5.477225575051661")
  let covariance = covariance_matrix([[1.0, 2.0], [2.0, 4.0], [3.0, 6.0]])
  inspect(covariance.at(0, 0), content="1")
  debug_inspect(solve_diagonal([2.0, 4.0], [4.0, 8.0]), content="[2, 2]")
}

///|
test "model ranking and validation" {
  let scores = [
    ModelScore::new("slow", 2.0, 4),
    ModelScore::new("fast", 1.0, 2),
  ]
  inspect(select_lowest_score(scores), content="1")
  debug_inspect(rank_models(scores), content="[1, 0]")
  inspect(aic(2.0, 10, 2), content="24")
  let split = chronological_split(10, 0.2)
  inspect(split.train_size(), content="8")
  inspect(split.test_size(), content="2")
}

///|
test "deterministic resampling" {
  let rng = DeterministicRng::new(42UL)
  let (next, summary) = bootstrap_mean(rng, [1.0, 2.0, 3.0], 20)
  inspect(next != rng, content="true")
  inspect(summary.replicates(), content="20")
  inspect(summary.estimate(), content="2")
  let (shuffled, values) = shuffle(rng, [0, 1, 2, 3])
  inspect(shuffled != rng, content="true")
  inspect(values.length(), content="4")
}

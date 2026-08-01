///|
test "NormalNormal" {
  // Prior mean = 0, prior var = 1, data var = 1
  let prior = NormalNormal::new(0.0, 1.0, 1.0)
  inspect(prior.posterior_mean(), content="0")
  inspect(prior.posterior_variance(), content="1")

  // Observe 1 sample with mean 1
  let posterior = prior.update(1.0, 1)
  inspect(posterior.posterior_mean(), content="0.5")
  inspect(posterior.posterior_variance(), content="0.5")

  inspect(posterior.posterior_predictive_mean(), content="0.5")
  inspect(posterior.posterior_predictive_variance(), content="1.5")

  // Test serialization
  json_inspect(posterior, content={
    "prior_mean": 0.5,
    "prior_variance": 0.5,
    "data_variance": 1,
  })
}

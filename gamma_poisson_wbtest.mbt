///|
test "GammaPoisson" {
  let prior = GammaPoisson::new(2.0, 1.0)
  inspect(prior.posterior_mean(), content="2")
  inspect(prior.posterior_variance(), content="2")

  // Observe 3 counts over 2 observations: total sum = 3, n = 2
  let posterior = prior.update(3, 2)
  inspect(posterior.posterior_mean(), content="1.6666666666666667")
  inspect(posterior.posterior_variance(), content="0.5555555555555556")
  
  inspect(posterior.posterior_predictive_mean(), content="1.6666666666666667")
  inspect(posterior.posterior_predictive_variance(), content="2.2222222222222223")
  
  // Test serialization
  json_inspect(posterior, content=({"shape":5,"rate":3}))
}

///|
test "BetaBinomial" {
  let prior = BetaBinomial::new(1.0, 1.0)
  inspect(prior.posterior_mean(), content="0.5")
  inspect(prior.posterior_variance(), content="0.08333333333333333")

  let posterior = prior.update(7, 10)
  inspect(posterior.posterior_mean(), content="0.6666666666666666")
  
  inspect(posterior.posterior_predictive_mean(10), content=(
    #|6.666666666666667
  ))
  
  // Test serialization
  json_inspect(posterior, content=
    ({"alpha":8,"beta":4})
  )
}

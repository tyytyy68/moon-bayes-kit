///|
test "DirichletMultinomial" {
  let prior = DirichletMultinomial::new([1.0, 1.0, 1.0])
  let posterior = prior.update([3, 1, 0])
  debug_inspect(
    posterior.posterior_mean(),
    content=(
      #|[0.5714285714285714, 0.2857142857142857, 0.14285714285714285]
    ),
  )
  debug_inspect(
    posterior.posterior_predictive_mean(8),
    content=(
      #|[4.571428571428571, 2.2857142857142856, 1.1428571428571428]
    ),
  )
  debug_inspect(
    posterior.posterior_variance(),
    content=(
      #|[0.030612244897959183, 0.025510204081632654, 0.015306122448979591]
    ),
  )
  let streamed = prior.update_one(0).update_one(1).update_one(0)
  json_inspect(streamed, content={ "alpha": [3, 2, 1] })
  json_inspect(posterior, content={ "alpha": [4, 2, 1] })
}

///|
fn main {
  let iterations = 10000
  let mut beta = @kit.BetaBinomial::new(1.0, 1.0)
  let mut gamma = @kit.GammaPoisson::new(2.0, 1.0)
  let mut stats = @kit.OnlineStats::new()
  for index in 0..<iterations {
    beta = beta.update(index % 7, 10)
    gamma = gamma.update(index % 11, 5)
    stats = stats.push((index % 100).to_double())
  }
  println("moon-bayes-kit benchmark")
  println("iterations=\{iterations}")
  println("beta_mean=\{beta.posterior_mean()}")
  println("gamma_mean=\{gamma.posterior_mean()}")
  println("online_mean=\{stats.mean()}")
  println("online_variance=\{stats.variance()}")
}

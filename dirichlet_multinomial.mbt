///|
/// Dirichlet-Multinomial conjugate model for categorical observations.
///
/// Each element of `alpha` is the prior concentration for one category. The
/// category order is kept by the caller, so the model can be used for labels
/// such as `["red", "green", "blue"]` without introducing a dependency on a
/// map implementation.
pub struct DirichletMultinomial {
  alpha : Array[Double]
} derive(ToJson, FromJson, Debug, Eq)

///|
/// Creates a Dirichlet-Multinomial model from positive concentration values.
pub fn DirichletMultinomial::new(alpha : Array[Double]) -> DirichletMultinomial {
  if alpha.length() == 0 {
    abort("DirichletMultinomial::new: alpha must not be empty")
  }
  for value in alpha {
    if value <= 0.0 {
      abort("DirichletMultinomial::new: alpha values must be positive")
    }
  }
  { alpha: alpha.map(fn(value) { value }) }
}

///|
/// Updates the model with category counts and returns the posterior.
pub fn DirichletMultinomial::update(
  self : DirichletMultinomial,
  counts : Array[Int],
) -> DirichletMultinomial {
  if counts.length() != self.alpha.length() {
    abort("DirichletMultinomial::update: counts length must match alpha length")
  }
  let posterior = self.alpha.map(fn(value) { value })
  for i, count in counts {
    if count < 0 {
      abort("DirichletMultinomial::update: counts must be non-negative")
    }
    posterior[i] = posterior[i] + count.to_double()
  }
  { alpha: posterior }
}

///|
/// Adds one observation for the category at `index`.
pub fn DirichletMultinomial::update_one(
  self : DirichletMultinomial,
  index : Int,
) -> DirichletMultinomial {
  if index < 0 || index >= self.alpha.length() {
    abort("DirichletMultinomial::update_one: category index out of range")
  }
  let counts = Array::make(self.alpha.length(), 0)
  counts[index] = 1
  self.update(counts)
}

///|
/// Returns the posterior mean probability for each category.
pub fn DirichletMultinomial::posterior_mean(
  self : DirichletMultinomial,
) -> Array[Double] {
  let total = self.alpha.fold(init=0.0, (sum, value) => sum + value)
  self.alpha.map(fn(value) { value / total })
}

///|
/// Returns the posterior variance for each category probability.
pub fn DirichletMultinomial::posterior_variance(
  self : DirichletMultinomial,
) -> Array[Double] {
  let total = self.alpha.fold(init=0.0, (sum, value) => sum + value)
  self.alpha.map(fn(value) {
    value * (total - value) / (total * total * (total + 1.0))
  })
}

///|
/// Returns the expected count for each category in `trials` new observations.
pub fn DirichletMultinomial::posterior_predictive_mean(
  self : DirichletMultinomial,
  trials : Int,
) -> Array[Double] {
  if trials < 0 {
    abort(
      "DirichletMultinomial::posterior_predictive_mean: trials must be non-negative",
    )
  }
  let n = trials.to_double()
  self.posterior_mean().map(fn(value) { n * value })
}

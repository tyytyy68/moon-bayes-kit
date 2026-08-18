///|
pub struct BootstrapSummary {
  estimate : Double
  lower : Double
  upper : Double
  replicates : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn BootstrapSummary::estimate(self : BootstrapSummary) -> Double {
  self.estimate
}

///|
pub fn BootstrapSummary::interval(self : BootstrapSummary) -> (Double, Double) {
  (self.lower, self.upper)
}

///|
pub fn BootstrapSummary::replicates(self : BootstrapSummary) -> Int {
  self.replicates
}

///|
pub fn bootstrap_mean(
  rng : DeterministicRng,
  values : Array[Double],
  replicates : Int,
) -> (DeterministicRng, BootstrapSummary) {
  if values.length() == 0 || replicates < 2 {
    abort("bootstrap_mean: invalid values or replicates")
  }
  let estimates = Array::make(replicates, 0.0)
  let mut current = rng
  for replicate in 0..<replicates {
    let (next, indices) = bootstrap_indices(
      current,
      values.length(),
      values.length(),
    )
    current = next
    let sample = indices.map(fn(index) { values[index] })
    estimates[replicate] = mean(sample)
  }
  let estimate = mean(values)
  let lower = quantile(estimates, 0.025.min(1.0))
  let upper = quantile(estimates, 0.975.min(1.0))
  (current, { estimate, lower, upper, replicates })
}

///|
pub fn permutation_difference(
  rng : DeterministicRng,
  left : Array[Double],
  right : Array[Double],
  permutations : Int,
) -> (DeterministicRng, Double) {
  if left.length() == 0 || right.length() == 0 || permutations <= 0 {
    abort("permutation_difference: invalid inputs")
  }
  let observed = mean(left) - mean(right)
  let combined = left.copy()
  for value in right {
    combined.push(value)
  }
  let indices = []
  for index in 0..<combined.length() {
    indices.push(index)
  }
  let mut exceed = 0
  let mut current = rng
  for _ in 0..<permutations {
    let (next, order) = shuffle(current, indices)
    current = next
    let mut left_sum = 0.0
    let mut right_sum = 0.0
    for index in 0..<combined.length() {
      if index < left.length() {
        left_sum = left_sum + combined[order[index]]
      } else {
        right_sum = right_sum + combined[order[index]]
      }
    }
    let difference = left_sum / left.length().to_double() -
      right_sum / right.length().to_double()
    if difference.abs() >= observed.abs() {
      exceed = exceed + 1
    }
  }
  (current, (exceed + 1).to_double() / (permutations + 1).to_double())
}

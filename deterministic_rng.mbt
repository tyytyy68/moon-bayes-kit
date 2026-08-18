///|
/// A tiny deterministic generator for reproducible examples and tests.
pub struct DeterministicRng {
  state : UInt64
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn DeterministicRng::new(seed : UInt64) -> DeterministicRng {
  { state: seed }
}

///|
pub fn DeterministicRng::next(
  self : DeterministicRng,
) -> (DeterministicRng, UInt64) {
  let next = self.state * 6364136223846793005UL + 1442695040888963407UL
  ({ state: next }, next)
}

///|
pub fn DeterministicRng::uniform(
  self : DeterministicRng,
) -> (DeterministicRng, Double) {
  let (next, value) = self.next()
  (next, value.to_double() / 18446744073709551616.0)
}

///|
pub fn DeterministicRng::int(
  self : DeterministicRng,
  upper : Int,
) -> (DeterministicRng, Int) {
  if upper <= 0 {
    abort("DeterministicRng::int: upper must be positive")
  }
  let (next, value) = self.next()
  (next, (value % upper.to_uint64()).to_int())
}

///|
pub fn weighted_choice(
  rng : DeterministicRng,
  weights : Array[Double],
) -> (DeterministicRng, Int) {
  let probabilities = normalize_probabilities(weights)
  let (next, sample) = rng.uniform()
  let mut cumulative = 0.0
  for index in 0..<probabilities.length() {
    cumulative = cumulative + probabilities[index]
    if sample < cumulative {
      return (next, index)
    }
  }
  (next, probabilities.length() - 1)
}

///|
pub fn shuffle(
  rng : DeterministicRng,
  values : Array[Int],
) -> (DeterministicRng, Array[Int]) {
  let result = values.copy()
  let mut current = rng
  for offset in 0..<result.length() {
    let remaining = result.length() - offset
    let (next, selected) = current.int(remaining)
    current = next
    let index = offset + selected
    let temporary = result[offset]
    result[offset] = result[index]
    result[index] = temporary
  }
  (current, result)
}

///|
pub fn bootstrap_indices(
  rng : DeterministicRng,
  size : Int,
  samples : Int,
) -> (DeterministicRng, Array[Int]) {
  if size <= 0 || samples < 0 {
    abort("bootstrap_indices: invalid size or sample count")
  }
  let result = Array::make(samples, 0)
  let mut current = rng
  for index in 0..<samples {
    let (next, value) = current.int(size)
    current = next
    result[index] = value
  }
  (current, result)
}

///|
pub fn uniform_grid(
  lower : Double,
  upper : Double,
  count : Int,
) -> Array[Double] {
  if lower > upper || count <= 0 {
    abort("uniform_grid: invalid range or count")
  }
  if count == 1 {
    return [lower]
  }
  let step = (upper - lower) / (count - 1).to_double()
  let result = Array::make(count, 0.0)
  for index in 0..<count {
    result[index] = lower + index.to_double() * step
  }
  result
}

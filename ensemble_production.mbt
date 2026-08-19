///|
/// Ensemble weighting, stacking, and disagreement diagnostics.
pub enum EnsembleMode {
  Mean
  Median
  Weighted
  Trimmed
  Voting
} derive(Debug, Eq, ToJson, FromJson)

///|
pub struct EnsembleMember {
  name : String
  predictions : Array[Double]
  weight : Double
  validation_loss : Double
  active : Bool
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn EnsembleMember::new(
  name : String,
  predictions : Array[Double],
) -> EnsembleMember {
  { name, predictions, weight: 1.0, validation_loss: 0.0, active: true }
}

///|
pub fn EnsembleMember::with_loss(
  self : EnsembleMember,
  loss : Double,
) -> EnsembleMember {
  { ..self, validation_loss: loss.max(0.0) }
}

///|
pub fn EnsembleMember::with_weight(
  self : EnsembleMember,
  weight : Double,
) -> EnsembleMember {
  if weight < 0.0 {
    abort("EnsembleMember: weight must be non-negative")
  }
  { ..self, weight, }
}

///|
pub fn EnsembleMember::disabled(self : EnsembleMember) -> EnsembleMember {
  { ..self, active: false }
}

///|
pub struct EnsemblePrediction {
  values : Array[Double]
  lower : Array[Double]
  upper : Array[Double]
  member_count : Int
  disagreement : Array[Double]
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn combine_predictions(
  members : Array[EnsembleMember],
  mode : EnsembleMode,
) -> EnsemblePrediction {
  let active = members.filter(fn(model_member) { model_member.active })
  if active.length() == 0 {
    abort("combine_predictions: no active members")
  }
  let points = active[0].predictions.length()
  for model_member in active.iter() {
    if model_member.predictions.length() != points {
      abort("combine_predictions: prediction lengths differ")
    }
  }
  let values : Array[Double] = []
  let lower : Array[Double] = []
  let upper : Array[Double] = []
  let disagreement : Array[Double] = []
  for point in 0..<points {
    let point_values : Array[Double] = []
    for model_member in active.iter() {
      point_values.push(model_member.predictions[point])
    }
    let center = match mode {
      EnsembleMode::Mean | EnsembleMode::Weighted =>
        weighted_point(active, point)
      EnsembleMode::Median => empirical_quantile(point_values, 0.5)
      EnsembleMode::Trimmed => trimmed_mean(point_values, 0.2)
      EnsembleMode::Voting =>
        if point_values.filter(fn(value) { value >= 0.5 }).length() * 2 >=
          point_values.length() {
          1.0
        } else {
          0.0
        }
    }
    values.push(center)
    lower.push(empirical_quantile(point_values, 0.1))
    upper.push(empirical_quantile(point_values, 0.9))
    disagreement.push(variance(point_values).sqrt())
  }
  { values, lower, upper, member_count: active.length(), disagreement }
}

///|
fn weighted_point(members : Array[EnsembleMember], point : Int) -> Double {
  let mut total = 0.0
  let mut weight = 0.0
  for model_member in members.iter() {
    total = total + model_member.predictions[point] * model_member.weight
    weight = weight + model_member.weight
  }
  if weight == 0.0 {
    0.0
  } else {
    total / weight
  }
}

///|
fn trimmed_mean(values : Array[Double], fraction : Double) -> Double {
  if values.length() == 0 {
    return 0.0
  }
  let sorted = values.copy()
  for left in 0..<sorted.length() {
    for right in (left + 1)..<sorted.length() {
      if sorted[right] < sorted[left] {
        let temp = sorted[left]
        sorted[left] = sorted[right]
        sorted[right] = temp
      }
    }
  }
  let trim = (sorted.length().to_double() * fraction)
    .floor()
    .to_int()
    .min((sorted.length() - 1) / 2)
  let mut total = 0.0
  let mut count = 0
  for index in trim..<(sorted.length() - trim) {
    total = total + sorted[index]
    count = count + 1
  }
  total / count.to_double()
}

///|
pub struct WeightFit {
  weights : Array[Double]
  intercept : Double
  training_loss : Double
  iterations : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn fit_linear_stacker(
  features : Array[Array[Double]],
  target : Array[Double],
  iterations : Int,
  learning_rate : Double,
) -> WeightFit {
  if features.length() != target.length() ||
    features.length() == 0 ||
    iterations <= 0 ||
    learning_rate <= 0.0 {
    abort("fit_linear_stacker: invalid inputs")
  }
  let columns = features[0].length()
  let weights : Array[Double] = []
  for _ in 0..<columns {
    weights.push(0.0)
  }
  let mut intercept = mean(target)
  for _ in 0..<iterations {
    let mut intercept_gradient = 0.0
    let gradients : Array[Double] = []
    for _ in 0..<columns {
      gradients.push(0.0)
    }
    for row in 0..<features.length() {
      let mut prediction = intercept
      for column in 0..<columns {
        prediction = prediction + weights[column] * features[row][column]
      }
      let error = prediction - target[row]
      intercept_gradient = intercept_gradient + error
      for column in 0..<columns {
        gradients[column] = gradients[column] + error * features[row][column]
      }
    }
    intercept = intercept -
      learning_rate * intercept_gradient / features.length().to_double()
    for column in 0..<columns {
      weights[column] = weights[column] -
        learning_rate * gradients[column] / features.length().to_double()
    }
  }
  let predictions : Array[Double] = []
  for row in features.iter() {
    let mut value = intercept
    for column in 0..<columns {
      value = value + weights[column] * row[column]
    }
    predictions.push(value)
  }
  let mut loss = 0.0
  for index in 0..<target.length() {
    let error = predictions[index] - target[index]
    loss = loss + error * error
  }
  {
    weights,
    intercept,
    training_loss: loss / target.length().to_double(),
    iterations,
  }
}

///|
pub fn weighted_loss(members : Array[EnsembleMember]) -> Double {
  let active = members.filter(fn(model_member) { model_member.active })
  let total_weight = active.fold(init=0.0, (total, model_member) => {
    total + model_member.weight
  })
  if total_weight == 0.0 {
    0.0
  } else {
    active.fold(init=0.0, (total, model_member) => {
      total + model_member.weight * model_member.validation_loss
    }) /
    total_weight
  }
}

///|
pub fn inverse_loss_weights(
  members : Array[EnsembleMember],
  floor : Double,
) -> Array[EnsembleMember] {
  if floor <= 0.0 {
    abort("inverse_loss_weights: floor must be positive")
  }
  let mut total = 0.0
  let raw = members.map(fn(model_member) {
    1.0 / model_member.validation_loss.max(floor)
  })
  for weight in raw.iter() {
    total = total + weight
  }
  members.map(fn(model_member) {
    let mut index = 0
    for candidate in members.iter() {
      if candidate.name == model_member.name {
        break
      }
      index = index + 1
    }
    { ..model_member, weight: raw[index] / total }
  })
}

///|
pub fn ensemble_bias(
  predicted : Array[Double],
  actual : Array[Double],
) -> Double {
  if predicted.length() != actual.length() || predicted.length() == 0 {
    abort("ensemble_bias: lengths must match")
  }
  let mut total = 0.0
  for index in 0..<predicted.length() {
    total = total + predicted[index] - actual[index]
  }
  total / predicted.length().to_double()
}

///|
pub fn ensemble_rmse(
  predicted : Array[Double],
  actual : Array[Double],
) -> Double {
  if predicted.length() != actual.length() || predicted.length() == 0 {
    abort("ensemble_rmse: lengths must match")
  }
  let mut total = 0.0
  for index in 0..<predicted.length() {
    let error = predicted[index] - actual[index]
    total = total + error * error
  }
  (total / predicted.length().to_double()).sqrt()
}

///|
pub struct DisagreementReport {
  mean_disagreement : Double
  maximum_disagreement : Double
  high_disagreement_points : Array[Int]
  threshold : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn disagreement_report(
  disagreement : Array[Double],
  threshold : Double,
) -> DisagreementReport {
  let high : Array[Int] = []
  for index in 0..<disagreement.length() {
    if disagreement[index] > threshold {
      high.push(index)
    }
  }
  {
    mean_disagreement: if disagreement.length() == 0 {
      0.0
    } else {
      mean(disagreement)
    },
    maximum_disagreement: if disagreement.length() == 0 {
      0.0
    } else {
      disagreement.fold(init=disagreement[0], (current, value) => {
        current.max(value)
      })
    },
    high_disagreement_points: high,
    threshold,
  }
}

///|
pub fn ensemble_rank(members : Array[EnsembleMember]) -> Array[String] {
  let ordered = members.copy()
  for left in 0..<ordered.length() {
    for right in (left + 1)..<ordered.length() {
      if ordered[right].validation_loss < ordered[left].validation_loss {
        let temp = ordered[left]
        ordered[left] = ordered[right]
        ordered[right] = temp
      }
    }
  }
  ordered.map(fn(model_member) { model_member.name })
}

///|
pub fn diversity_matrix(
  members : Array[EnsembleMember],
) -> Array[Array[Double]] {
  let result : Array[Array[Double]] = []
  for left in members.iter() {
    let row : Array[Double] = []
    for right in members.iter() {
      row.push(mean_squared_difference(left.predictions, right.predictions))
    }
    result.push(row)
  }
  result
}

///|
fn mean_squared_difference(
  left : Array[Double],
  right : Array[Double],
) -> Double {
  if left.length() != right.length() || left.length() == 0 {
    return 0.0
  }
  let mut total = 0.0
  for index in 0..<left.length() {
    let difference = left[index] - right[index]
    total = total + difference * difference
  }
  total / left.length().to_double()
}

///|
pub fn select_diverse_members(
  members : Array[EnsembleMember],
  limit : Int,
) -> Array[EnsembleMember] {
  if limit <= 0 {
    return []
  }
  let ordered = ensemble_rank(members)
  let result : Array[EnsembleMember] = []
  for name in ordered.iter() {
    if result.length() < limit {
      for model_member in members.iter() {
        if model_member.name == name {
          result.push(model_member)
        }
      }
    }
  }
  result
}

///|
pub struct StackingReport {
  member_count : Int
  training_loss : Double
  weighted_loss : Double
  diversity : Double
  selected : Array[String]
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn stacking_report(
  members : Array[EnsembleMember],
  prediction : EnsemblePrediction,
) -> StackingReport {
  let diversity = mean(prediction.disagreement)
  {
    member_count: members.length(),
    training_loss: weighted_loss(members),
    weighted_loss: weighted_loss(members),
    diversity,
    selected: ensemble_rank(members),
  }
}

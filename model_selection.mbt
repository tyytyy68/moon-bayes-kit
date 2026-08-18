///|
pub struct ModelScore {
  name : String
  score : Double
  complexity : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn ModelScore::new(
  name : String,
  score : Double,
  complexity : Int,
) -> ModelScore {
  if complexity < 0 {
    abort("ModelScore: complexity must be non-negative")
  }
  { name, score, complexity }
}

///|
pub fn ModelScore::name(self : ModelScore) -> String {
  self.name
}

///|
pub fn ModelScore::score(self : ModelScore) -> Double {
  self.score
}

///|
pub fn ModelScore::complexity(self : ModelScore) -> Int {
  self.complexity
}

///|
pub fn select_lowest_score(scores : Array[ModelScore]) -> Int {
  if scores.length() == 0 {
    abort("select_lowest_score: scores must not be empty")
  }
  let mut best = 0
  for index in 1..<scores.length() {
    if scores[index].score() < scores[best].score() {
      best = index
    }
  }
  best
}

///|
pub fn rank_models(scores : Array[ModelScore]) -> Array[Int] {
  let result = []
  for index in 0..<scores.length() {
    result.push(index)
  }
  for left in 0..<result.length() {
    for right in (left + 1)..<result.length() {
      if scores[result[right]].score() < scores[result[left]].score() {
        let temp = result[left]
        result[left] = result[right]
        result[right] = temp
      }
    }
  }
  result
}

///|
pub fn aic(
  residual_sum : Double,
  observations : Int,
  parameters : Int,
) -> Double {
  if residual_sum <= 0.0 || observations <= 0 || parameters < 0 {
    abort("aic: invalid inputs")
  }
  observations.to_double() * residual_sum + 2.0 * parameters.to_double()
}

///|
pub fn bic(
  residual_sum : Double,
  observations : Int,
  parameters : Int,
) -> Double {
  if residual_sum <= 0.0 || observations <= 0 || parameters < 0 {
    abort("bic: invalid inputs")
  }
  observations.to_double() * residual_sum +
  observations.to_double().sqrt() * parameters.to_double()
}

///|
pub fn cross_validated_rmse(folds : Array[RegressionReport]) -> Double {
  if folds.length() == 0 {
    abort("cross_validated_rmse: folds must not be empty")
  }
  let total = folds.fold(init=0.0, (sum_value, report) => {
    sum_value + report.rmse() * report.rmse() * report.count().to_double()
  })
  let count = folds.fold(init=0, (sum_count, report) => {
    sum_count + report.count()
  })
  if count == 0 {
    0.0
  } else {
    (total / count.to_double()).sqrt()
  }
}

///|
pub fn compare_binary_models(
  predictions : Array[Array[Double]],
  observed : Array[Bool],
) -> Array[ModelScore] {
  let result = []
  for _, model in predictions {
    if model.length() != observed.length() {
      abort("compare_binary_models: lengths must match")
    }
    result.push(
      ModelScore::new(
        "model-{index}",
        brier_score(model, observed),
        model.length(),
      ),
    )
  }
  result
}

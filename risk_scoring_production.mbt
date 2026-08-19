///|
/// Interpretable risk-scorecard primitives for turning posterior probabilities
/// into operational bands, actions, and monitored portfolio summaries.
pub struct RiskBand {
  name : String
  lower : Double
  upper : Double
  action : String
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn RiskBand::new(
  name : String,
  lower : Double,
  upper : Double,
  action : String,
) -> RiskBand {
  if name == "" || action == "" || lower < 0.0 || upper > 1.0 || lower >= upper {
    abort("RiskBand: invalid name, interval, or action")
  }
  { name, lower, upper, action }
}

///|
pub fn RiskBand::contains(self : RiskBand, probability : Double) -> Bool {
  probability >= self.lower && probability < self.upper
}

///|
pub struct RiskFeatureContribution {
  name : String
  value : Double
  weight : Double
  contribution : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn RiskFeatureContribution::new(
  name : String,
  value : Double,
  weight : Double,
) -> RiskFeatureContribution {
  if name == "" {
    abort("RiskFeatureContribution: name is required")
  }
  { name, value, weight, contribution: value * weight }
}

///|
pub struct RiskScorecard {
  intercept : Double
  features : Array[RiskFeatureContribution]
  bands : Array[RiskBand]
  minimum : Double
  maximum : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn RiskScorecard::new(intercept : Double) -> RiskScorecard {
  { intercept, features: [], bands: [], minimum: 0.0, maximum: 1.0 }
}

///|
pub fn RiskScorecard::with_bounds(
  self : RiskScorecard,
  minimum : Double,
  maximum : Double,
) -> RiskScorecard {
  if minimum < 0.0 || maximum > 1.0 || minimum >= maximum {
    abort("RiskScorecard: invalid probability bounds")
  }
  { ..self, minimum, maximum }
}

///|
pub fn RiskScorecard::add_feature(
  self : RiskScorecard,
  feature : RiskFeatureContribution,
) -> RiskScorecard {
  let features = self.features.copy()
  features.push(feature)
  { ..self, features, }
}

///|
pub fn RiskScorecard::add_band(
  self : RiskScorecard,
  band : RiskBand,
) -> RiskScorecard {
  for existing in self.bands.iter() {
    if band.lower < existing.upper && existing.lower < band.upper {
      abort("RiskScorecard: risk bands must not overlap")
    }
  }
  let bands = self.bands.copy()
  bands.push(band)
  { ..self, bands, }
}

///|
pub fn RiskScorecard::logit(self : RiskScorecard) -> Double {
  self.intercept +
  self.features.fold(init=0.0, (total, feature) => total + feature.contribution)
}

///|
pub fn RiskScorecard::probability(self : RiskScorecard) -> Double {
  let logit = self.logit()
  let raw = if logit >= 0.0 {
    1.0 / (1.0 + @math.pow(2.718281828459045, 0.0 - logit))
  } else {
    let exponential = @math.pow(2.718281828459045, logit)
    exponential / (1.0 + exponential)
  }
  raw.max(self.minimum).min(self.maximum)
}

///|
pub fn RiskScorecard::band(self : RiskScorecard) -> RiskBand? {
  let probability = self.probability()
  for item in self.bands.iter() {
    if item.contains(probability) ||
      (probability == self.maximum && item.upper == self.maximum) {
      return Some(item)
    }
  }
  None
}

///|
pub fn RiskScorecard::explain(
  self : RiskScorecard,
) -> Array[RiskFeatureContribution] {
  let result = self.features.copy()
  for left in 0..<result.length() {
    for right in (left + 1)..<result.length() {
      if result[right].contribution > result[left].contribution {
        let swap = result[left]
        result[left] = result[right]
        result[right] = swap
      }
    }
  }
  result
}

///|
pub struct RiskDecision {
  probability : Double
  band : String
  action : String
  expected_loss : Double
  accepted : Bool
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn decide_risk(
  scorecard : RiskScorecard,
  loss_if_positive : Double,
  loss_if_negative : Double,
  accept_loss : Double,
) -> RiskDecision {
  if loss_if_positive < 0.0 || loss_if_negative < 0.0 || accept_loss < 0.0 {
    abort("decide_risk: losses must be non-negative")
  }
  let probability = scorecard.probability()
  let expected_loss = probability * loss_if_positive +
    (1.0 - probability) * loss_if_negative
  let selected_band = scorecard.band()
  let band = match selected_band {
    Some(item) => item.name
    None => "unbanded"
  }
  let action = match selected_band {
    Some(item) => item.action
    None => "review"
  }
  {
    probability,
    band,
    action,
    expected_loss,
    accepted: expected_loss <= accept_loss,
  }
}

///|
pub struct PortfolioRiskSummary {
  count : Int
  mean_probability : Double
  expected_events : Double
  high_risk_count : Int
  total_exposure : Double
  expected_loss : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn summarize_portfolio(
  probabilities : Array[Double],
  exposures : Array[Double],
  high_risk_threshold : Double,
  loss_if_event : Double,
) -> PortfolioRiskSummary {
  if probabilities.length() == 0 ||
    probabilities.length() != exposures.length() ||
    high_risk_threshold < 0.0 ||
    high_risk_threshold > 1.0 ||
    loss_if_event < 0.0 {
    abort("summarize_portfolio: invalid probabilities, exposures, or policy")
  }
  let mut expected_events = 0.0
  let mut high_risk_count = 0
  let mut total_exposure = 0.0
  let mut expected_loss = 0.0
  for index in 0..<probabilities.length() {
    let probability = probabilities[index]
    let exposure = exposures[index]
    if probability < 0.0 || probability > 1.0 || exposure < 0.0 {
      abort("summarize_portfolio: invalid observation")
    }
    expected_events = expected_events + probability
    if probability >= high_risk_threshold {
      high_risk_count = high_risk_count + 1
    }
    total_exposure = total_exposure + exposure
    expected_loss = expected_loss + probability * loss_if_event * exposure
  }
  {
    count: probabilities.length(),
    mean_probability: mean(probabilities),
    expected_events,
    high_risk_count,
    total_exposure,
    expected_loss,
  }
}

///|
pub struct RiskCalibrationRow {
  lower : Double
  upper : Double
  count : Int
  predicted : Double
  observed : Double
  calibration_gap : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn risk_calibration_table(
  probabilities : Array[Double],
  outcomes : Array[Bool],
  buckets : Int,
) -> Array[RiskCalibrationRow] {
  if probabilities.length() == 0 ||
    probabilities.length() != outcomes.length() ||
    buckets <= 0 {
    abort("risk_calibration_table: invalid inputs")
  }
  let result : Array[RiskCalibrationRow] = []
  for bucket in 0..<buckets {
    let lower = bucket.to_double() / buckets.to_double()
    let upper = (bucket + 1).to_double() / buckets.to_double()
    let mut count = 0
    let mut predicted = 0.0
    let mut observed = 0.0
    for index in 0..<probabilities.length() {
      let is_last = bucket == buckets - 1 && probabilities[index] <= upper
      if probabilities[index] >= lower &&
        (probabilities[index] < upper || is_last) {
        count = count + 1
        predicted = predicted + probabilities[index]
        if outcomes[index] {
          observed = observed + 1.0
        }
      }
    }
    let predicted_rate = if count == 0 {
      0.0
    } else {
      predicted / count.to_double()
    }
    let observed_rate = if count == 0 {
      0.0
    } else {
      observed / count.to_double()
    }
    result.push({
      lower,
      upper,
      count,
      predicted: predicted_rate,
      observed: observed_rate,
      calibration_gap: predicted_rate - observed_rate,
    })
  }
  result
}

///|
pub fn risk_calibration_error(rows : Array[RiskCalibrationRow]) -> Double {
  let total = rows.fold(init=0, (count, row) => count + row.count)
  if total == 0 {
    return 0.0
  }
  rows.fold(init=0.0, (error, row) => {
    error +
    row.count.to_double() / total.to_double() * row.calibration_gap.abs()
  })
}

///|
pub struct LossCurvePoint {
  threshold : Double
  accepted : Int
  reviewed : Int
  expected_loss : Double
  acceptance_rate : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn risk_loss_curve(
  probabilities : Array[Double],
  exposures : Array[Double],
  loss_if_event : Double,
  review_cost : Double,
  steps : Int,
) -> Array[LossCurvePoint] {
  if probabilities.length() == 0 ||
    probabilities.length() != exposures.length() ||
    loss_if_event < 0.0 ||
    review_cost < 0.0 ||
    steps <= 0 {
    abort("risk_loss_curve: invalid inputs")
  }
  let result : Array[LossCurvePoint] = []
  for step in 0..<=steps {
    let threshold = step.to_double() / steps.to_double()
    let mut accepted = 0
    let mut reviewed = 0
    let mut loss = 0.0
    for index in 0..<probabilities.length() {
      if probabilities[index] <= threshold {
        accepted = accepted + 1
      } else {
        reviewed = reviewed + 1
        loss = loss + review_cost * exposures[index]
      }
      loss = loss + probabilities[index] * loss_if_event * exposures[index]
    }
    result.push({
      threshold,
      accepted,
      reviewed,
      expected_loss: loss,
      acceptance_rate: accepted.to_double() / probabilities.length().to_double(),
    })
  }
  result
}

///|
pub fn minimum_loss_policy(points : Array[LossCurvePoint]) -> LossCurvePoint {
  if points.length() == 0 {
    abort("minimum_loss_policy: points must not be empty")
  }
  let mut best = points[0]
  for point in points.iter() {
    if point.expected_loss < best.expected_loss {
      best = point
    }
  }
  best
}

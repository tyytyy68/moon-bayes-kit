///|
/// Gaussian Naive Bayes classifier with immutable online updates.
pub struct GaussianClass {
  label : Int
  prior : Double
  counts : Array[Int]
  summaries : Array[OnlineStats]
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn GaussianClass::new(
  label : Int,
  feature_count : Int,
  prior : Double,
) -> GaussianClass {
  if feature_count <= 0 || prior <= 0.0 {
    abort("GaussianClass: invalid feature count or prior")
  }
  {
    label,
    prior,
    counts: Array::make(feature_count, 0),
    summaries: Array::make(feature_count, OnlineStats::new()),
  }
}

///|
pub fn GaussianClass::label(self : GaussianClass) -> Int {
  self.label
}

///|
pub fn GaussianClass::observations(self : GaussianClass) -> Int {
  if self.counts.length() == 0 {
    0
  } else {
    self.counts[0]
  }
}

///|
pub fn GaussianClass::feature_count(self : GaussianClass) -> Int {
  self.summaries.length()
}

///|
pub fn GaussianClass::update(
  self : GaussianClass,
  features : Array[Double],
) -> GaussianClass {
  if features.length() != self.feature_count() {
    abort("GaussianClass: feature length mismatch")
  }
  let counts = self.counts.copy()
  let summaries = self.summaries.copy()
  for index, value in features {
    counts[index] = counts[index] + 1
    summaries[index] = summaries[index].push(value)
  }
  { ..self, counts, summaries }
}

///|
pub fn GaussianClass::mean(self : GaussianClass, feature : Int) -> Double {
  self.summaries[feature].mean()
}

///|
pub fn GaussianClass::variance(self : GaussianClass, feature : Int) -> Double {
  self.summaries[feature].variance().max(0.000000000001)
}

///|
pub fn GaussianClass::prior_probability(self : GaussianClass) -> Double {
  self.prior
}

///|
pub fn GaussianClass::score(
  self : GaussianClass,
  features : Array[Double],
) -> Double {
  if features.length() != self.feature_count() {
    abort("GaussianClass: feature length mismatch")
  }
  let mut result = self.prior
  for index, value in features {
    let variance = self.variance(index)
    let distance = value - self.mean(index)
    result = result * (1.0 / (1.0 + distance * distance / variance))
  }
  result
}

///|
pub struct GaussianNaiveBayes {
  classes : Array[GaussianClass]
  feature_count : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn GaussianNaiveBayes::new(
  labels : Array[Int],
  feature_count : Int,
) -> GaussianNaiveBayes {
  if labels.length() == 0 || feature_count <= 0 {
    abort("GaussianNaiveBayes: invalid dimensions")
  }
  let prior = 1.0 / labels.length().to_double()
  let classes = labels.map(fn(label) {
    GaussianClass::new(label, feature_count, prior)
  })
  { classes, feature_count }
}

///|
pub fn GaussianNaiveBayes::update(
  self : GaussianNaiveBayes,
  label : Int,
  features : Array[Double],
) -> GaussianNaiveBayes {
  if features.length() != self.feature_count {
    abort("GaussianNaiveBayes: feature length mismatch")
  }
  let classes = self.classes.copy()
  let mut found = false
  for index in 0..<classes.length() {
    if classes[index].label() == label {
      classes[index] = classes[index].update(features)
      found = true
    }
  }
  if !found {
    abort("GaussianNaiveBayes: unknown label")
  }
  { ..self, classes, }
}

///|
pub fn GaussianNaiveBayes::fit(
  self : GaussianNaiveBayes,
  labels : Array[Int],
  features : Array[Array[Double]],
) -> GaussianNaiveBayes {
  if labels.length() != features.length() {
    abort("GaussianNaiveBayes::fit: row count mismatch")
  }
  features.foldi(init=self, fn(index, model, row) {
    model.update(labels[index], row)
  })
}

///|
pub fn GaussianNaiveBayes::predict_scores(
  self : GaussianNaiveBayes,
  features : Array[Double],
) -> Array[Double] {
  self.classes.map(fn(classifier) { classifier.score(features) })
}

///|
pub fn GaussianNaiveBayes::predict(
  self : GaussianNaiveBayes,
  features : Array[Double],
) -> Int {
  let scores = self.predict_scores(features)
  let mut best = 0
  for index in 1..<scores.length() {
    if scores[index] > scores[best] {
      best = index
    }
  }
  self.classes[best].label()
}

///|
pub fn GaussianNaiveBayes::class_count(self : GaussianNaiveBayes) -> Int {
  self.classes.length()
}

///|
pub fn GaussianNaiveBayes::feature_count(self : GaussianNaiveBayes) -> Int {
  self.feature_count
}

///|
pub fn GaussianNaiveBayes::class_summary(
  self : GaussianNaiveBayes,
  label : Int,
) -> GaussianClass {
  for classifier in self.classes {
    if classifier.label() == label {
      return classifier
    }
  }
  abort("GaussianNaiveBayes: unknown label")
}

///|
pub fn GaussianNaiveBayes::accuracy(
  self : GaussianNaiveBayes,
  labels : Array[Int],
  features : Array[Array[Double]],
) -> Double {
  if labels.length() != features.length() {
    abort("GaussianNaiveBayes::accuracy: row count mismatch")
  }
  if labels.length() == 0 {
    return 0.0
  }
  let mut correct = 0
  for index in 0..<labels.length() {
    if self.predict(features[index]) == labels[index] {
      correct = correct + 1
    }
  }
  correct.to_double() / labels.length().to_double()
}

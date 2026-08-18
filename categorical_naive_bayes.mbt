///|
/// Online categorical Naive Bayes for integer feature vocabularies.
pub struct CategoricalClass {
  label : Int
  counts : Array[Array[Int]]
  total : Int
  prior : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn CategoricalClass::new(
  label : Int,
  feature_count : Int,
  vocabulary : Int,
  prior : Int,
) -> CategoricalClass {
  if feature_count <= 0 || vocabulary <= 0 || prior <= 0 {
    abort("CategoricalClass: invalid dimensions")
  }
  {
    label,
    counts: Array::make(feature_count, Array::make(vocabulary, 0)),
    total: 0,
    prior,
  }
}

///|
pub fn CategoricalClass::label(self : CategoricalClass) -> Int {
  self.label
}

///|
pub fn CategoricalClass::update(
  self : CategoricalClass,
  features : Array[Int],
) -> CategoricalClass {
  if features.length() != self.counts.length() {
    abort("CategoricalClass: feature count mismatch")
  }
  let counts = self.counts.map(fn(row) { row.copy() })
  for feature, value in features {
    if value < 0 || value >= counts[feature].length() {
      abort("CategoricalClass: category out of range")
    }
    counts[feature][value] = counts[feature][value] + 1
  }
  { ..self, counts, total: self.total + 1 }
}

///|
pub fn CategoricalClass::feature_probability(
  self : CategoricalClass,
  feature : Int,
  value : Int,
) -> Double {
  if feature < 0 ||
    feature >= self.counts.length() ||
    value < 0 ||
    value >= self.counts[feature].length() {
    abort("CategoricalClass: index out of range")
  }
  (self.counts[feature][value] + self.prior).to_double() /
  (self.total + self.prior * self.counts[feature].length()).to_double()
}

///|
pub fn CategoricalClass::score(
  self : CategoricalClass,
  features : Array[Int],
) -> Double {
  if features.length() != self.counts.length() {
    abort("CategoricalClass: feature count mismatch")
  }
  let mut score = 1.0
  for feature, value in features {
    score = score * self.feature_probability(feature, value)
  }
  score
}

///|
pub fn CategoricalClass::observations(self : CategoricalClass) -> Int {
  self.total
}

///|
pub struct CategoricalNaiveBayes {
  classes : Array[CategoricalClass]
  vocabulary : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn CategoricalNaiveBayes::new(
  labels : Array[Int],
  feature_count : Int,
  vocabulary : Int,
) -> CategoricalNaiveBayes {
  if labels.length() == 0 {
    abort("CategoricalNaiveBayes: labels must not be empty")
  }
  {
    classes: labels.map(fn(label) {
      CategoricalClass::new(label, feature_count, vocabulary, 1)
    }),
    vocabulary,
  }
}

///|
pub fn CategoricalNaiveBayes::update(
  self : CategoricalNaiveBayes,
  label : Int,
  features : Array[Int],
) -> CategoricalNaiveBayes {
  let classes = self.classes.copy()
  let mut found = false
  for index in 0..<classes.length() {
    if classes[index].label() == label {
      classes[index] = classes[index].update(features)
      found = true
    }
  }
  if !found {
    abort("CategoricalNaiveBayes: unknown label")
  }
  { ..self, classes, }
}

///|
pub fn CategoricalNaiveBayes::fit(
  self : CategoricalNaiveBayes,
  labels : Array[Int],
  features : Array[Array[Int]],
) -> CategoricalNaiveBayes {
  if labels.length() != features.length() {
    abort("CategoricalNaiveBayes::fit: row count mismatch")
  }
  features.foldi(init=self, fn(index, model, row) {
    model.update(labels[index], row)
  })
}

///|
pub fn CategoricalNaiveBayes::predict_scores(
  self : CategoricalNaiveBayes,
  features : Array[Int],
) -> Array[Double] {
  self.classes.map(fn(classifier) { classifier.score(features) })
}

///|
pub fn CategoricalNaiveBayes::predict(
  self : CategoricalNaiveBayes,
  features : Array[Int],
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
pub fn CategoricalNaiveBayes::accuracy(
  self : CategoricalNaiveBayes,
  labels : Array[Int],
  features : Array[Array[Int]],
) -> Double {
  if labels.length() != features.length() {
    abort("CategoricalNaiveBayes::accuracy: row count mismatch")
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

///|
pub fn CategoricalNaiveBayes::class_count(self : CategoricalNaiveBayes) -> Int {
  self.classes.length()
}

///|
pub fn CategoricalNaiveBayes::vocabulary_size(
  self : CategoricalNaiveBayes,
) -> Int {
  self.vocabulary
}

///|
pub fn CategoricalNaiveBayes::class_observations(
  self : CategoricalNaiveBayes,
  label : Int,
) -> Int {
  for classifier in self.classes {
    if classifier.label() == label {
      return classifier.observations()
    }
  }
  abort("CategoricalNaiveBayes: unknown label")
}

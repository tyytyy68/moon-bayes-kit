# moon-bayes-kit

MoonBit Composable Bayesian Online Update Library.

## Features

- **Beta-Binomial Conjugate Model**: Prior update and posterior predictions for binomial data.
- **Gamma-Poisson Conjugate Model**: Inference on count data.
- **Normal-Normal Conjugate Model**: Continuous data with known variance.
- **Dirichlet-Multinomial Conjugate Model**: Categorical data with any number of categories.
- **Serialization**: `ToJson` support for model persistence.

## Extensible online updates

Every model is immutable: `update` returns a new posterior, so updates can be
composed, replayed, or persisted without hidden state. The categorical model
accepts an arbitrary number of categories and supports both batch counts and
one-observation-at-a-time updates.

```mbt check
///|
test {
  let model = DirichletMultinomial::new([1.0, 1.0, 1.0])
  let posterior = model.update([3, 1, 0])
  debug_inspect(
    posterior.posterior_mean(),
    content=(
      #|[0.5714285714285714, 0.2857142857142857, 0.14285714285714285]

    ),
  )
}
```

## Example

```mbt check
///|
test {
  // Create a Beta-Binomial model with prior alpha=1.0, beta=1.0 (Uniform prior)
  let prior = BetaBinomial::new(1.0, 1.0)

  // Update with 7 successes out of 10 trials
  let posterior = prior.update(7, 10)

  // Posterior mean is now (1+7) / (1+10+1) = 8 / 12 = 0.666...
  inspect(posterior.posterior_mean(), content="0.6666666666666666")
}
```

```mbt check
///|
test {
  // Gamma-Poisson model example
  let prior = GammaPoisson::new(2.0, 1.0)
  let posterior = prior.update(3, 2)
  inspect(posterior.posterior_mean(), content="1.6666666666666667")
}
```

```mbt check
test {
  // Normal-Normal model example
  let prior = NormalNormal::new(0.0, 1.0, 1.0)
  let posterior = prior.update(1.0, 1)
  inspect(posterior.posterior_mean(), content="0.5")
}
```

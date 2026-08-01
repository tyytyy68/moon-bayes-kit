# moon-bayes-kit

MoonBit Composable Bayesian Online Update Library.

## Features

- **Beta-Binomial Conjugate Model**: Prior update and posterior predictions for binomial data.
- **Gamma-Poisson Conjugate Model**: Inference on count data.
- **Normal-Normal Conjugate Model**: Continuous data with known variance.
- **Serialization**: `ToJson` support for model persistence.

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

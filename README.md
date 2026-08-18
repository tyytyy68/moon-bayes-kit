# moon-bayes-kit

`moon-bayes-kit` is a dependency-light MoonBit library for immutable Bayesian
updates, online statistics, predictive checks, and small-model forecasting.
It is being completed for the August 2026 MoonBit Hackathon. The implementation
is original MoonBit code; it is not a port of a third-party project.

## What is included

- Beta-Binomial, Gamma-Poisson, Normal-Normal, and Dirichlet-Multinomial models;
- predictive probability tables, quantiles, credible intervals, and posterior summaries;
- immutable `UpdateLedger` replaying heterogeneous observations;
- Welford online moments, mergeable summaries, rolling windows, EWMA and CUSUM drift detection;
- dense matrix operations and Bayesian linear regression with sufficient-statistic updates;
- binary classification, calibration, Brier/log loss, MAE/RMSE, and regression reports;
- deterministic chronological and walk-forward validation helpers;
- reproducible Beta-bandit policy and largest-remainder categorical allocation;
- JSON persistence through MoonBit `ToJson` / `FromJson` derivation.

Every update returns a new value, making event replay, checkpointing, edge-device
inference, and deterministic tests straightforward.

## Quick start

```mbt check
///|
test {
  let prior = BetaBinomial::new(1.0, 1.0)
  let posterior = prior.update(7, 10)
  inspect(posterior.posterior_mean(), content="0.6666666666666666")
}
```

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

## Validation and benchmark

```text
moon fmt --check
moon check --target all --deny-warn
moon test --target all --deny-warn
moon info --deny-warn
moon run --target native cmd/benchmark
```

The committed benchmark performs 10,000 online updates across the conjugate
models and Welford statistics. On the development machine used for this release
(MoonBit 0.1.20260807 / moonc 0.10.7), the native release workload completed in
0.258 s wall time for the end-to-end native debug command using PowerShell
`Measure-Command` averaged over five runs after one warm-up. Timing varies by
machine; the command above reproduces the calculation and output.

## License and provenance

Apache-2.0. This is an original MoonBit implementation with no copied source,
generated third-party code, or external fixture data.

## Package metadata

- MoonBit module: `tyytyy68/moon-bayes-kit`
- GitHub: https://github.com/tyytyy68/moon-bayes-kit
- GitLink: https://gitlink.org.cn/tyytyy68/moon-bayes-kit

## Examples

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

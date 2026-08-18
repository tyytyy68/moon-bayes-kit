# moon-bayes-kit

Composable Bayesian updating and online statistical utilities for MoonBit.
The library is immutable at its public boundaries, dependency-light, and usable
from native, WebAssembly, and JavaScript-targeted MoonBit programs.

## Core capabilities

- Conjugate models: Beta-Binomial, Gamma-Poisson, Normal-Normal,
  Normal-Inverse-Gamma, Beta-Negative-Binomial, and Dirichlet-Multinomial.
- Online inference: mergeable Welford statistics, rolling windows, update
  ledgers, EWMA/CUSUM drift detection, and deterministic replay.
- Predictive analytics: posterior summaries, predictive distributions,
  credible intervals, calibration, Brier score, log loss, MAE, and RMSE.
- Applied modeling: Bayesian linear/ridge regression, Gaussian and categorical
  Naive Bayes, Beta-bandit policies, and walk-forward validation.
- Numerical building blocks: dense matrices, Cholesky factorization, vector
  operations, covariance matrices, deterministic resampling, and datasets.
- Feature engineering: normalization, standardization, clipping, imputation,
  one-hot encoding, polynomial features, interactions, and feature ranking.

## Quick start

Add the package to a MoonBit module:

```text
moon add tyytyy68/moon-bayes-kit@0.1.5
```

Update a Beta-Binomial posterior:

```mbt check
///|
test {
  let posterior = BetaBinomial::new(1.0, 1.0).update(7, 10)
  inspect(posterior.posterior_mean(), content="0.6666666666666666")
  inspect(posterior.posterior_predictive_mean(5), content="3.333333333333333")
}
```

Maintain online statistics without retaining the input stream:

```mbt check
///|
test {
  let summary = OnlineStats::new().push_all([10.0, 12.0, 11.0, 13.0])
  inspect(summary.count(), content="4")
  inspect(summary.mean(), content="11.5")
  inspect(summary.variance(), content="1.6666666666666667")
}
```

## Library architecture

The root package exposes model types and small numerical primitives. Model
updates are immutable and return new posterior values. `UpdateLedger` provides
heterogeneous event replay; `OnlineStats`, `RollingWindow`, and the drift
detectors handle streaming summaries; `DenseMatrix` and regression types cover
small numerical models; dataset and feature-pipeline types connect tabular data
to those models. Derived JSON implementations support checkpointing.

The implementation intentionally avoids a mandatory random-number or plotting
dependency. `DeterministicRng` is provided for reproducible examples,
resampling, and tests.

## Command-line and runnable examples

The package is primarily a library and does not install a separate end-user CLI.
The repository includes a reproducible native benchmark executable:

```text
moon run --target native cmd/benchmark
```

It performs 10,000 online updates across the conjugate models and Welford
statistics and prints deterministic result values.

## Benchmarks

The recorded local baseline is in [BENCHMARKS.md](BENCHMARKS.md). On the
development Windows machine, five end-to-end native debug runs averaged
257.8251 ms after one warm-up. This measurement includes build and process
startup; it is a reproducibility baseline, not a steady-state throughput claim.
Re-run the benchmark on the target hardware before comparing performance.

## Tests and verification

Run the same checks used by CI:

```text
moon fmt --check
moon check --target all --deny-warn
moon test --target all --deny-warn
moon build --target all
moon info
```

The test suite covers model updates, serialization, predictive calculations,
boundary validation, online statistics, matrices, regression, classifiers,
feature transforms, and resampling. The repository's runnable examples are
checked as MoonBit documentation tests.

## Continuous integration

GitHub Actions tests Linux, macOS, and Windows with the latest stable MoonBit
toolchain. The workflow checks all backends, denies warnings, runs tests,
verifies formatting, and detects public API changes through `moon info`.
Package publication is a separate manual workflow.

## License

Apache-2.0. See [LICENSE](LICENSE).

## Repository

- Module: `tyytyy68/moon-bayes-kit`
- Source: https://github.com/tyytyy68/moon-bayes-kit

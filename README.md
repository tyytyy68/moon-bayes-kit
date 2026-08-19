# moon-bayes-kit

## Project positioning

Composable Bayesian updating and online statistical utilities for MoonBit.
The library is immutable at its public boundaries, dependency-light, and usable
from native, WebAssembly, and JavaScript-targeted MoonBit programs.

## Core capabilities

- Conjugate and structured inference: Beta-Binomial, Gamma-Poisson,
  Normal-Normal, Normal-Inverse-Gamma, Dirichlet-Multinomial, discrete factors,
  Bayesian networks, Kalman filters, and local-level forecasts.
- Streaming and distributed statistics: mergeable Welford and covariance
  summaries, weighted rates, quantile/distinct sketches, rolling windows,
  EWMA/CUSUM drift detection, and deterministic replay.
- Applied modeling: Bayesian linear/ridge regression, Gaussian and categorical
  Naive Bayes, bandit policies, survival analysis, state-space models, and
  Monte Carlo/importance/MCMC diagnostics.
- Production analytics: probability calibration, threshold and cost policies,
  cohort/fairness reports, robust statistics, risk scorecards, experiment
  guardrails, numerical optimization, and reproducible numerical methods.
- Data and operations: data contracts and lineage, feature stores, model
  registries, pipeline plans, prediction audit logs, rollout counters, service
  health/SLO checks, and privacy-preserving summaries.

## Quick start

Add the package to a MoonBit module:

```text
moon add tyytyy68/moon-bayes-kit@0.1.8
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
updates are immutable and return new posterior values. The inference layer is
organized around conjugate distributions, factor graphs, and state-space
updates; the analytics layer adds calibration, cohort, causal, survival, and
experiment reports; the operations layer provides contracts, lineage,
feature/model registries, serving guards, and monitoring records. Numerical
optimization, interpolation, integration, and robust estimators are shared by
the modeling and production layers. Derived JSON implementations support
checkpointing and portable reports.

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
boundary validation, online and distributed statistics, factor inference,
state-space filtering, Monte Carlo diagnostics, calibration, numerical
solvers, optimization, lineage, serving controls, risk scoring, cohort
analysis, and experiment gates. The repository's runnable examples are checked
as MoonBit documentation tests.

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

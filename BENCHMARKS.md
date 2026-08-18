# Benchmark record

Date: 2026-08-18  
Toolchain: `moon 0.1.20260807`, `moonc 0.10.7`  
Workload: `moon run --target native cmd/benchmark` with 10,000 Beta-Binomial,
Gamma-Poisson, and online-statistics updates.

Measured on the local Windows development machine with PowerShell
`Measure-Command`. After one warm-up, five end-to-end runs were:

```text
250.5595 ms
253.3439 ms
282.0473 ms
251.7704 ms
251.4044 ms
average: 257.8251 ms
```

The command includes the native debug build and process startup, so this is a
reproducibility baseline rather than a claim about steady-state throughput.
The deterministic output was:

```text
iterations=10000
beta_mean=0.2999440011199776
gamma_mean=0.999920001599968
online_mean=49.49999999999976
online_variance=833.3333333333356
```

Re-run with `moon run --target native cmd/benchmark`.

# 日次シミュレーション速度ベンチマーク

[English](README.md) / [日本語](README.ja.md)

機能テストのNightlyとは独立しています。GitHub標準ランナーの値は参考値で、5回の測定から統計的有意性を断言しません。

## 最新の測定回

**測定回:** `actions-44103555558-1` — complete
2026-11-17T15:00:17.437065+00:00 → 2026-11-17T15:46:25.375450+00:00

比率は最新kirimasimの差分時間÷比較対象の差分時間です。1未満なら最新kirimasimが速いことを示します。

この環境での参考値です。失敗・欠測はゼロ秒ではありません。

[JSON](runs/actions-44103555558-1.json) · [Actions logs / ログ](https://github.com/kurochan001/kirimasim-tests/actions/runs/44103555558/attempts/1) · [Method / 測定方法](https://github.com/kurochan001/kirimasim-tests/blob/main/docs/daily-benchmark.md)

環境: github-hosted-ubuntu-24.04 / AMD EPYC 7763 64-Core Processor / Linux-7.0.0-1017-azure-x86_64-with-glibc2.39

<details><summary>測定条件</summary>

```json
{
  "machine": {
    "os": "Linux-7.0.0-1017-azure-x86_64-with-glibc2.39",
    "cores": 4,
    "cpu": "AMD EPYC 7763 64-Core Processor",
    "memory_gib": 16,
    "distribution": "Ubuntu 24.04.5 LTS",
    "architecture": "x86_64"
  },
  "compiler": "g++ (Ubuntu 13.3.0-6ubuntu2~24.04.1) 13.3.0",
  "environment": "github-hosted-ubuntu-24.04",
  "image_os": "ubuntu24",
  "image_version": "20261111.370.1",
  "settings": {
    "runs": 5,
    "warmups": 1,
    "timeout_seconds": 600,
    "short_seconds": 0.05,
    "regression_warning_ratio": 1.15,
    "simulation_threads": 1,
    "waveforms": false,
    "assertions": false,
    "verilator_build_jobs": 1
  },
  "mode": "formal",
  "runs": 5,
  "tool_builds": {
    "latest": {
      "compiler": "g++ (Ubuntu 13.3.0-6ubuntu2~24.04.1) 13.3.0",
      "c_compiler": "gcc (Ubuntu 13.3.0-6ubuntu2~24.04.1) 13.3.0",
      "flags": {
        "CC": "gcc",
        "CXX": "g++",
        "CFLAGS": "",
        "CXXFLAGS": "",
        "preset": "release",
        "cmake": "-O3 -DNDEBUG -ffp-contract=off, no fast-math",
        "make_jobs": 2
      }
    },
    "baseline": {
      "compiler": "g++ (Ubuntu 13.3.0-6ubuntu2~24.04.1) 13.3.0",
      "c_compiler": "gcc (Ubuntu 13.3.0-6ubuntu2~24.04.1) 13.3.0",
      "flags": {
        "CC": "gcc",
        "CXX": "g++",
        "CFLAGS": "",
        "CXXFLAGS": "",
        "preset": "release",
        "cmake": "-O3 -DNDEBUG -ffp-contract=off, no fast-math",
        "make_jobs": 2
      }
    },
    "icarus": {
      "compiler": "g++ (Ubuntu 13.3.0-6ubuntu2~24.04.1) 13.3.0",
      "c_compiler": "gcc (Ubuntu 13.3.0-6ubuntu2~24.04.1) 13.3.0",
      "flags": {
        "CC": "gcc",
        "CXX": "g++",
        "CFLAGS": "",
        "CXXFLAGS": "",
        "preset": "release",
        "cmake": "-O3 -DNDEBUG -ffp-contract=off, no fast-math",
        "make_jobs": 2
      }
    },
    "verilator": {
      "compiler": "g++ (Ubuntu 13.3.0-6ubuntu2~24.04.1) 13.3.0",
      "c_compiler": "gcc (Ubuntu 13.3.0-6ubuntu2~24.04.1) 13.3.0",
      "flags": {
        "CC": "gcc",
        "CXX": "g++",
        "CFLAGS": "",
        "CXXFLAGS": "",
        "preset": "release",
        "cmake": "-O3 -DNDEBUG -ffp-contract=off, no fast-math",
        "make_jobs": 2
      }
    }
  },
  "verilator_options": "--binary --timing --threads 1 --build-jobs 1; default C++ optimization; assertions/tracing off",
  "icarus_options": "-g2012; vvp -n; single process",
  "kirimasim_options": "default four-state; interpreter; no waveform/assertion request"
}
```

</details>

- `latest`: `13d52dde3c491059c95ef9570264c06094306309` — kirimasim 0.1.1 (commit 13d52dde3c49), built with GNU 13.3.0
- `baseline`: `cfa2ccd75989c1ebb9ed63303271183377364cf0` — kirimasim 0.1.0 (commit cfa2ccd75989), built with GNU 13.3.0
- `icarus`: `dfeee909ed9f20b4870dd93423156c0170c0e1ff` — Icarus Verilog version 13.0 (stable) (dfeee90-dirty)
- `verilator`: `bbb60a403932a9f695cb6ff001ceb73de6ad9234` — Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261117-bbb60a4

定義・測定処理の識別情報: `{'config_sha256': '216daa768275047fcbe9a5e7870b2d4e75fcb595af23bd95da6aa37cf9359786', 'driver_sha256': '175b631376be5989eb9871bbb6b962294ec7990b0e5ae809795bec95127a2dcc', 'comparison_sha256': '2896f429781d5eaff2d0ecec465726de342f840892056d20304d2df179ad6be0', 'history_sha256': '1b8797ae32822347eb9128f1d76bbf59bc5ed730248eea4ab93546fda5083583', 'setup_sha256': '35fd0861a6a91f6bd13719ca3a926142a8a248cb672d9499e328bfdd04c791e3', 'adapter_sha256': '4811f9d50d4a09d8794710296d644350468c49a9579a794f27af42ac9fb6b5bc', 'benchmark_commit': 'cfa2ccd75989c1ebb9ed63303271183377364cf0'}`

| ケース | 処理系 | 状態 | ビルド秒 | T(1)中央値秒 | T(N)中央値秒 | 差分秒 | T(N) MAD秒 | RSS MiB | 最新/対象 | 理由・注意 |
|---|---|---|---:|---:|---:|---:|---:|---:|---:|---|
| casez_struct (N=5000000) | latest | measured | — | 0.0052239 | 5.7977 | 5.7925 | 0.033824 | 28.543 | — |  |
| casez_struct (N=5000000) | baseline | measured | — | 0.0052564 | 7.7471 | 7.7419 | 0.046384 | 28.543 | 0.7482 |  |
| casez_struct (N=5000000) | icarus | measured | 0.0072629 | 0.0038684 | 8.3386 | 8.3347 | 0.073416 | 7.3008 | 0.69498 |  |
| casez_struct (N=5000000) | verilator | measured | 6.8554 | 0.0017702 | 0.03119 | 0.02942 | 3.9668e-05 | 3.8359 | 196.89 | short incremental time; sensitive to timing noise |
| comb_chain (N=3000000) | latest | measured | — | 0.0048348 | 17.864 | 17.86 | 0.090701 | 28.539 | — |  |
| comb_chain (N=3000000) | baseline | measured | — | 0.005695 | 23.123 | 23.117 | 0.19037 | 28.48 | 0.77256 |  |
| comb_chain (N=3000000) | icarus | measured | 0.0057491 | 0.0038387 | 26.461 | 26.457 | 0.081308 | 7.3398 | 0.67504 |  |
| comb_chain (N=3000000) | verilator | measured | 7.842 | 0.0014973 | 0.46146 | 0.45996 | 0.001827 | 3.7227 | 38.828 |  |
| dyn_queue (N=4000000) | latest | measured | — | 0.0058012 | 7.3712 | 7.3654 | 0.070716 | 28.375 | — |  |
| dyn_queue (N=4000000) | baseline | measured | — | 0.0049369 | 8.7961 | 8.7912 | 0.051235 | 28.41 | 0.83782 |  |
| dyn_queue (N=4000000) | icarus | measured | 0.006262 | 0.0038414 | 13.925 | 13.922 | 0.047808 | 7.3398 | 0.52906 |  |
| dyn_queue (N=4000000) | verilator | measured | 6.9457 | 0.001797 | 0.16518 | 0.16338 | 0.00030947 | 3.6875 | 45.081 |  |
| fork_join (N=4000000) | latest | measured | — | 0.0043891 | 10.338 | 10.334 | 0.025384 | 28.527 | — |  |
| fork_join (N=4000000) | baseline | measured | — | 0.0047755 | 11.634 | 11.629 | 0.11698 | 28.512 | 0.88861 |  |
| fork_join (N=4000000) | icarus | measured | 0.0059273 | 0.0037367 | 12.651 | 12.647 | 0.027066 | 7.3281 | 0.81711 |  |
| fork_join (N=4000000) | verilator | measured | 8.0235 | 0.0015049 | 2.517 | 2.5155 | 0.017571 | 3.7227 | 4.1081 |  |
| func_call (N=1500000) | latest | measured | — | 0.0046962 | 9.1354 | 9.1307 | 0.083309 | 28.379 | — |  |
| func_call (N=1500000) | baseline | measured | — | 0.0044855 | 10.994 | 10.99 | 0.06086 | 28.316 | 0.83084 |  |
| func_call (N=1500000) | icarus | measured | 0.0059564 | 0.0038377 | 20.978 | 20.974 | 0.015878 | 7.2812 | 0.43533 |  |
| func_call (N=1500000) | verilator | measured | 6.8292 | 0.0018252 | 0.011411 | 0.0095856 | 5.3051e-05 | 3.6797 | 952.54 | short incremental time; sensitive to timing noise |
| gate_udp (N=400000) | latest | measured | — | 0.0059871 | 10.59 | 10.584 | 0.1157 | 28.547 | — |  |
| gate_udp (N=400000) | baseline | measured | — | 0.0066757 | 13.12 | 13.114 | 0.11246 | 28.445 | 0.80708 |  |
| gate_udp (N=400000) | icarus | measured | 0.0083512 | 0.0052667 | 6.4055 | 6.4002 | 0.050794 | 7.3945 | 1.6537 |  |
| gate_udp (N=400000) | verilator | measured | 7.9782 | 0.0014328 | 0.091103 | 0.08967 | 2.6123e-05 | 3.6914 | 118.03 |  |
| mem_rw (N=4000000) | latest | measured | — | 0.0072053 | 9.7958 | 9.7886 | 0.14245 | 28.52 | — |  |
| mem_rw (N=4000000) | baseline | measured | — | 0.0080616 | 11.675 | 11.667 | 0.00737 | 28.387 | 0.83902 |  |
| mem_rw (N=4000000) | icarus | measured | 0.0065836 | 0.0044419 | 8.6636 | 8.6592 | 0.033417 | 7.3398 | 1.1304 |  |
| mem_rw (N=4000000) | verilator | measured | 7.945 | 0.0017998 | 1.366 | 1.3642 | 0.014079 | 3.6992 | 7.1753 |  |
| nba_burst (N=500000) | latest | measured | — | 0.0049768 | 0.17347 | 0.16849 | 0.00044102 | 124.55 | — |  |
| nba_burst (N=500000) | baseline | measured | — | 0.0044048 | 0.22592 | 0.22152 | 0.0041807 | 124.47 | 0.76062 |  |
| nba_burst (N=500000) | icarus | measured | 0.0064931 | 0.003225 | 0.24166 | 0.23844 | 0.0019386 | 33.773 | 0.70665 |  |
| nba_burst (N=500000) | verilator | measured | 7.8967 | 0.0013767 | 0.0022359 | 0.00085923 | 7.2956e-05 | 0.55859 | 196.1 | short incremental time; sensitive to timing noise |
| nba_shift (N=1000000) | latest | measured | — | 0.0061941 | 42.606 | 42.6 | 0.19776 | 28.52 | — |  |
| nba_shift (N=1000000) | baseline | measured | — | 0.0058257 | 54.703 | 54.697 | 0.026908 | 28.418 | 0.77883 |  |
| nba_shift (N=1000000) | icarus | measured | 0.0061401 | 0.004266 | 49.233 | 49.229 | 0.042933 | 7.4375 | 0.86534 |  |
| nba_shift (N=1000000) | verilator | measured | 8.1923 | 0.0017935 | 0.41832 | 0.41652 | 0.00049062 | 3.6914 | 102.27 |  |
| proc_wait (N=1000000) | latest | measured | — | 0.0084218 | 16.272 | 16.263 | 0.039191 | 32.48 | — |  |
| proc_wait (N=1000000) | baseline | measured | — | 0.009098 | 19.481 | 19.472 | 0.12458 | 30.457 | 0.83522 |  |
| proc_wait (N=1000000) | icarus | measured | 0.0072903 | 0.0054944 | 10.268 | 10.262 | 0.011805 | 7.7734 | 1.5848 |  |
| proc_wait (N=1000000) | verilator | measured | 10.324 | 0.001571 | 4.0975 | 4.096 | 0.0096562 | 3.8516 | 3.9705 |  |
| string_fmt (N=500000) | latest | measured | — | 0.0047553 | 6.8421 | 6.8374 | 0.041881 | 28.391 | — |  |
| string_fmt (N=500000) | baseline | measured | — | 0.0046576 | 9.0958 | 9.0912 | 0.020547 | 28.332 | 0.75209 |  |
| string_fmt (N=500000) | icarus | measured | 0.0055672 | 0.0037971 | 20.453 | 20.449 | 0.13882 | 7.332 | 0.33437 |  |
| string_fmt (N=500000) | verilator | measured | 6.768 | 0.0017956 | 0.29258 | 0.29079 | 0.00073522 | 3.8281 | 23.513 |  |
| wide_arith (N=1500000) | latest | measured | — | 0.0045191 | 4.1863 | 4.1817 | 0.034834 | 28.332 | — |  |
| wide_arith (N=1500000) | baseline | measured | — | 0.004921 | 9.4076 | 9.4027 | 0.045013 | 28.289 | 0.44474 |  |
| wide_arith (N=1500000) | icarus | measured | 0.0067454 | 0.0036422 | 16.05 | 16.046 | 0.025212 | 7.2656 | 0.2606 |  |
| wide_arith (N=1500000) | verilator | measured | 6.9724 | 0.0014709 | 0.14485 | 0.14338 | 0.00017448 | 3.7109 | 29.166 |  |
| fourstate_mix (N=1000000) | latest | measured | — | 0.0048515 | 2.167 | 2.1622 | 0.032523 | 28.664 | — |  |
| fourstate_mix (N=1000000) | baseline | measured | — | 0.0050839 | 2.7292 | 2.7241 | 0.01421 | 28.547 | 0.79371 |  |
| fourstate_mix (N=1000000) | icarus | measured | 0.0065847 | 0.0037536 | 4.2379 | 4.2341 | 0.023163 | 7.293 | 0.51065 |  |
| fourstate_mix (N=1000000) | verilator | unsupported | — | — | — | — | — | — | — | X/Z observations require four-state semantics; excluded before execution |

固定した総合値の集合（全ケースの有効値が必要です）：

- **regression-common**: 0.76483; 12/12; casez_struct, comb_chain, dyn_queue, fork_join, func_call, gate_udp, mem_rw, nba_burst, nba_shift, proc_wait, string_fmt, wide_arith
- **regression-fourstate**: 0.79371; 1/1; fourstate_mix
- **icarus-common**: 0.7004; 12/12; casez_struct, comb_chain, dyn_queue, fork_join, func_call, gate_udp, mem_rw, nba_burst, nba_shift, proc_wait, string_fmt, wide_arith
- **icarus-fourstate**: 0.51065; 1/1; fourstate_mix
- **verilator-common**: 44.626; 12/12; casez_struct, comb_chain, dyn_queue, fork_join, func_call, gate_udp, mem_rw, nba_burst, nba_shift, proc_wait, string_fmt, wide_arith

## 環境・定義別の推移

### `962ea28f5124b999`

1 runs; 2026-11-17T15:00:17.437065+00:00 → 2026-11-17T15:00:17.437065+00:00

測定定義: `daily-v2-thirteen`; ケース数: **13**

![regression-common](charts/962ea28f5124b99939a8ae6dec023cb53d2fa7f3769aecf4e0801a27d99c196d/regression-common.svg)

![regression-fourstate](charts/962ea28f5124b99939a8ae6dec023cb53d2fa7f3769aecf4e0801a27d99c196d/regression-fourstate.svg)

![icarus-common](charts/962ea28f5124b99939a8ae6dec023cb53d2fa7f3769aecf4e0801a27d99c196d/icarus-common.svg)

![icarus-fourstate](charts/962ea28f5124b99939a8ae6dec023cb53d2fa7f3769aecf4e0801a27d99c196d/icarus-fourstate.svg)

![verilator-common](charts/962ea28f5124b99939a8ae6dec023cb53d2fa7f3769aecf4e0801a27d99c196d/verilator-common.svg)

失敗を含む各回：

- [actions-44103555558-1](runs/actions-44103555558-1.json): complete — `13d52dde3c49`
### `ff134f2dfe29a369`

1 runs; 2026-11-17T13:04:45.723115+00:00 → 2026-11-17T13:04:45.723115+00:00

測定定義: `daily-v1`; ケース数: **5**

![regression-common](charts/ff134f2dfe29a369d8116a07680e0a4ea53e757ba74a0abb4811823a01606d89/regression-common.svg)

![regression-fourstate](charts/ff134f2dfe29a369d8116a07680e0a4ea53e757ba74a0abb4811823a01606d89/regression-fourstate.svg)

![icarus-common](charts/ff134f2dfe29a369d8116a07680e0a4ea53e757ba74a0abb4811823a01606d89/icarus-common.svg)

![icarus-fourstate](charts/ff134f2dfe29a369d8116a07680e0a4ea53e757ba74a0abb4811823a01606d89/icarus-fourstate.svg)

![verilator-common](charts/ff134f2dfe29a369d8116a07680e0a4ea53e757ba74a0abb4811823a01606d89/verilator-common.svg)

失敗を含む各回：

- [actions-44085771320-1](runs/actions-44085771320-1.json): complete — `26f359bcd504`

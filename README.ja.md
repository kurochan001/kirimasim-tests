# 日次シミュレーション速度ベンチマーク

[English](README.md) / [日本語](README.ja.md)

機能テストのNightlyとは独立しています。GitHub標準ランナーの値は参考値で、5回の測定から統計的有意性を断言しません。

## 最新の測定回

**測定回:** `actions-44085771320-1` — complete
2026-11-17T13:04:45.723115+00:00 → 2026-11-17T13:21:24.008983+00:00

比率は最新kirimasimの差分時間÷比較対象の差分時間です。1未満なら最新kirimasimが速いことを示します。

この環境での参考値です。失敗・欠測はゼロ秒ではありません。

[JSON](runs/actions-44085771320-1.json) · [Actions logs / ログ](https://github.com/kurochan001/kirimasim-tests/actions/runs/44085771320/attempts/1) · [Method / 測定方法](https://github.com/kurochan001/kirimasim-tests/blob/main/docs/daily-benchmark.md)

環境: github-hosted-ubuntu-24.04 / Intel(R) Xeon(R) 6975P-C / Linux-7.0.0-1014-aws-x86_64-with-glibc2.39

<details><summary>測定条件</summary>

```json
{
  "machine": {
    "os": "Linux-7.0.0-1014-aws-x86_64-with-glibc2.39",
    "cores": 4,
    "cpu": "Intel(R) Xeon(R) 6975P-C",
    "memory_gib": 15,
    "distribution": "Ubuntu 24.04.5 LTS",
    "architecture": "x86_64"
  },
  "compiler": "g++ (Ubuntu 13.3.0-6ubuntu2~24.04.1) 13.3.0",
  "environment": "github-hosted-ubuntu-24.04",
  "image_os": "ubuntu24",
  "image_version": "20261111.127.1",
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

- `latest`: `26f359bcd5042b0ac0696d851c1a7946589e283b` — kirimasim 0.1.1 (commit 26f359bcd504), built with GNU 13.3.0
- `baseline`: `cfa2ccd75989c1ebb9ed63303271183377364cf0` — kirimasim 0.1.0 (commit cfa2ccd75989), built with GNU 13.3.0
- `icarus`: `dfeee909ed9f20b4870dd93423156c0170c0e1ff` — Icarus Verilog version 13.0 (stable) (dfeee90-dirty)
- `verilator`: `bbb60a403932a9f695cb6ff001ceb73de6ad9234` — Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261117-bbb60a4

定義・測定処理の識別情報: `{'config_sha256': '3ea67af50c32a2e7b1e0d91fc1e6e2308267ee07a2c0d396d31b3a9c6c10b99f', 'driver_sha256': '175b631376be5989eb9871bbb6b962294ec7990b0e5ae809795bec95127a2dcc', 'comparison_sha256': '2896f429781d5eaff2d0ecec465726de342f840892056d20304d2df179ad6be0', 'history_sha256': 'fdf54ea35022e764ea40c0544a0dccbfb0f2dcb456e13830afdcb9b88f32dae9', 'setup_sha256': '35fd0861a6a91f6bd13719ca3a926142a8a248cb672d9499e328bfdd04c791e3', 'adapter_sha256': '4811f9d50d4a09d8794710296d644350468c49a9579a794f27af42ac9fb6b5bc', 'benchmark_commit': 'cfa2ccd75989c1ebb9ed63303271183377364cf0'}`

| ケース | 処理系 | 状態 | ビルド秒 | T(1)中央値秒 | T(N)中央値秒 | 差分秒 | T(N) MAD秒 | RSS MiB | 最新/対象 | 理由・注意 |
|---|---|---|---:|---:|---:|---:|---:|---:|---:|---|
| comb_chain (N=3000000) | latest | measured | — | 0.0043822 | 11.166 | 11.162 | 0.010827 | 28.543 | — |  |
| comb_chain (N=3000000) | baseline | measured | — | 0.0045556 | 13.554 | 13.549 | 0.088533 | 28.422 | 0.82379 |  |
| comb_chain (N=3000000) | icarus | measured | 0.0047752 | 0.0026597 | 19.365 | 19.363 | 0.013889 | 7.4297 | 0.57646 |  |
| comb_chain (N=3000000) | verilator | measured | 5.4153 | 0.0012673 | 0.32258 | 0.32132 | 0.0005647 | 3.8477 | 34.738 |  |
| mem_rw (N=4000000) | latest | measured | — | 0.0064199 | 6.3499 | 6.3435 | 0.0029005 | 28.379 | — |  |
| mem_rw (N=4000000) | baseline | measured | — | 0.0064727 | 7.2789 | 7.2724 | 0.014684 | 28.254 | 0.87227 |  |
| mem_rw (N=4000000) | icarus | measured | 0.0034851 | 0.0026799 | 6.0608 | 6.0581 | 0.016569 | 7.4297 | 1.0471 |  |
| mem_rw (N=4000000) | verilator | measured | 5.3482 | 0.00098207 | 0.97462 | 0.97364 | 0.0013158 | 3.8555 | 6.5153 |  |
| nba_shift (N=1000000) | latest | measured | — | 0.0050158 | 29.177 | 29.172 | 0.19874 | 28.418 | — |  |
| nba_shift (N=1000000) | baseline | measured | — | 0.005317 | 35.388 | 35.383 | 0.34533 | 28.398 | 0.82449 |  |
| nba_shift (N=1000000) | icarus | measured | 0.0040487 | 0.0029563 | 34.476 | 34.473 | 0.03039 | 7.4766 | 0.84623 |  |
| nba_shift (N=1000000) | verilator | measured | 5.4483 | 0.0013143 | 0.28246 | 0.28115 | 0.00035624 | 3.8555 | 103.76 |  |
| wide_arith (N=1500000) | latest | measured | — | 0.0050668 | 2.8159 | 2.8108 | 0.015941 | 28.484 | — |  |
| wide_arith (N=1500000) | baseline | measured | — | 0.0048083 | 7.1039 | 7.099 | 0.004796 | 28.305 | 0.39594 |  |
| wide_arith (N=1500000) | icarus | measured | 0.0037238 | 0.0024847 | 14.551 | 14.548 | 0.0061806 | 7.3242 | 0.19321 |  |
| wide_arith (N=1500000) | verilator | measured | 4.7905 | 0.00098426 | 0.12014 | 0.11915 | 0.00015644 | 3.8359 | 23.59 |  |
| fourstate_mix (N=1000000) | latest | measured | — | 0.0043398 | 1.3971 | 1.3928 | 0.0075812 | 28.668 | — |  |
| fourstate_mix (N=1000000) | baseline | measured | — | 0.0052891 | 1.736 | 1.7307 | 0.0063163 | 28.578 | 0.80477 |  |
| fourstate_mix (N=1000000) | icarus | measured | 0.0044507 | 0.0027553 | 3.1894 | 3.1866 | 0.0016275 | 7.3516 | 0.43707 |  |
| fourstate_mix (N=1000000) | verilator | unsupported | — | — | — | — | — | — | — | X/Z observations require four-state semantics; excluded before execution |

固定した総合値の集合（全ケースの有効値が必要です）：

- **regression-common**: 0.69594; 4/4; comb_chain, mem_rw, nba_shift, wide_arith
- **regression-fourstate**: 0.80477; 1/1; fourstate_mix
- **icarus-common**: 0.56049; 4/4; comb_chain, mem_rw, nba_shift, wide_arith
- **icarus-fourstate**: 0.43707; 1/1; fourstate_mix
- **verilator-common**: 27.282; 4/4; comb_chain, mem_rw, nba_shift, wide_arith

## 環境・定義別の推移

### `ff134f2dfe29a369`

1 runs; 2026-11-17T13:04:45.723115+00:00 → 2026-11-17T13:04:45.723115+00:00

![regression-common](charts/ff134f2dfe29a369d8116a07680e0a4ea53e757ba74a0abb4811823a01606d89/regression-common.svg)

![regression-fourstate](charts/ff134f2dfe29a369d8116a07680e0a4ea53e757ba74a0abb4811823a01606d89/regression-fourstate.svg)

![icarus-common](charts/ff134f2dfe29a369d8116a07680e0a4ea53e757ba74a0abb4811823a01606d89/icarus-common.svg)

![icarus-fourstate](charts/ff134f2dfe29a369d8116a07680e0a4ea53e757ba74a0abb4811823a01606d89/icarus-fourstate.svg)

![verilator-common](charts/ff134f2dfe29a369d8116a07680e0a4ea53e757ba74a0abb4811823a01606d89/verilator-common.svg)

失敗を含む各回：

- [actions-44085771320-1](runs/actions-44085771320-1.json): complete — `26f359bcd504`

# Daily and weekly simulation-speed benchmarks

[English](README.md) / [日本語](README.ja.md)

Independent of functional Nightly. GitHub-hosted values are reference measurements; five repetitions do not establish statistical significance.

![Daily overall elapsed ratio: Icarus 14 devel = 1](charts/daily-icarus14.svg)

Equal-weight geometric mean of all 25 daily designs (22 common + 3 four-state). Ratio = kirimasim / Icarus 14.0 devel incremental elapsed. 0.97 means 3% less elapsed time; lower is faster.

Both development heads are resolved once per campaign. A day uses its last formal attempt in JST; one invalid member makes the mean missing. Different environments/definitions are separate curves. Both simulators can affect the trend; fixed-version comparisons are below.

[JSON](headline.json) · [Method / 測定方法](https://github.com/kurochan001/kirimasim-tests/blob/main/docs/daily-benchmark.md)

Latest overall attempt: **2026-11-20 JST — 0.71154** (25/25; complete)

[Raw / 生データ](runs/actions-44656096600-1.json) · [Actions logs / ログ](https://github.com/kurochan001/kirimasim-tests/actions/runs/44656096600/attempts/1)

<details><summary>Case results, fixed-version comparisons and earlier series</summary>

## Latest daily attempt

[JSON](latest-daily.json)

**Run:** `actions-44656096600-1` — complete
2026-11-20T01:57:13.586055+00:00 → 2026-11-20T02:51:29.292680+00:00

Ratios = latest kirimasim / peer incremental elapsed; below 1 favors latest.

This is a descriptive reference on this environment. Missing/failed values are not zero.

[JSON](runs/actions-44656096600-1.json) · [Actions logs / ログ](https://github.com/kurochan001/kirimasim-tests/actions/runs/44656096600/attempts/1) · [Method / 測定方法](https://github.com/kurochan001/kirimasim-tests/blob/main/docs/daily-benchmark.md)

Environment: github-hosted-ubuntu-24.04 / Intel(R) Xeon(R) 6975P-C / Linux-7.0.0-1014-aws-x86_64-with-glibc2.39

<details><summary>Measurement settings</summary>

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
  "profile": "daily",
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
    },
    "icarus_devel": {
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

- `latest`: `cb97fc93bf6be9795d90cc1e8d346d60ef71955e` — kirimasim 0.1.1 (commit cb97fc93bf6b), built with GNU 13.3.0
- `baseline`: `cfa2ccd75989c1ebb9ed63303271183377364cf0` — kirimasim 0.1.0 (commit cfa2ccd75989), built with GNU 13.3.0
- `icarus`: `dfeee909ed9f20b4870dd93423156c0170c0e1ff` — Icarus Verilog version 13.0 (stable) (dfeee90-dirty)
- `verilator`: `bbb60a403932a9f695cb6ff001ceb73de6ad9234` — Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261118-bbb60a4
- `icarus_devel`: `c717fc33e4c98f2088ac50935ad71b00408ce3bf` — Icarus Verilog version 14.0 (devel) (c717fc3)

Definition and measurement identity: `{'config_sha256': '4006a76543b7c88eed78ba128e7459c54ac2ee82a78efdd401ac2d85643bef9b', 'driver_sha256': '0edb91f5cbc17e8d1eec9e77ab4c87fb7dbcf4b9ff57d233c5e94628770ad077', 'comparison_sha256': '2896f429781d5eaff2d0ecec465726de342f840892056d20304d2df179ad6be0', 'history_sha256': 'bda014f86bbbea0bd769b5458656bfda07cbcaec712624cfad17960b10b5c887', 'setup_sha256': 'aa89dd6c7df5268f361f96049069cfe68b524ff93819afc4351fcb557c91d8f9', 'adapter_sha256': '4811f9d50d4a09d8794710296d644350468c49a9579a794f27af42ac9fb6b5bc', 'benchmark_commit': 'cfa2ccd75989c1ebb9ed63303271183377364cf0', 'reference_sha256': {'bench/reference_expanded.py': 'a1196d79efb88425f61cc69ba1d9ec99542f7f5dc41fac2a07ade82090b00f4a', 'bench/reference_fourstate_mix.py': '586fb643e9ef9df9e304df83e04e711aa1b875e6cb4393e6e3c98cd1707b70e1'}}`

| Case | Tool | State | Build s | T(1) median s | T(N) median s | Incremental s | MAD T(N) s | RSS MiB | latest/peer | Reason / warning |
|---|---|---|---:|---:|---:|---:|---:|---:|---:|---|
| casez_struct (N=5000000) | latest | measured | — | 0.0051258 | 2.4915 | 2.4864 | 0.0133 | 28.543 | — |  |
| casez_struct (N=5000000) | baseline | measured | — | 0.0050461 | 5.0645 | 5.0595 | 0.050718 | 28.332 | 0.49143 |  |
| casez_struct (N=5000000) | icarus | measured | 0.0034985 | 0.0027164 | 5.4917 | 5.4889 | 0.026623 | 7.3633 | 0.45298 |  |
| casez_struct (N=5000000) | verilator | measured | 4.6447 | 0.0013419 | 0.02955 | 0.028209 | 0.00012992 | 3.8359 | 88.143 | short incremental time; sensitive to timing noise |
| casez_struct (N=5000000) | icarus_devel | measured | 0.0036793 | 0.002572 | 5.0295 | 5.0269 | 0.0042175 | 7.4648 | 0.49461 |  |
| comb_chain (N=3000000) | latest | measured | — | 0.0051118 | 7.486 | 7.4809 | 0.016983 | 28.441 | — |  |
| comb_chain (N=3000000) | baseline | measured | — | 0.0048232 | 13.55 | 13.545 | 0.049417 | 28.312 | 0.55228 |  |
| comb_chain (N=3000000) | icarus | measured | 0.0040418 | 0.0027462 | 19.492 | 19.489 | 0.048208 | 7.4375 | 0.38385 |  |
| comb_chain (N=3000000) | verilator | measured | 5.493 | 0.0013431 | 0.32371 | 0.32237 | 0.0007565 | 3.8164 | 23.206 |  |
| comb_chain (N=3000000) | icarus_devel | measured | 0.0038073 | 0.0025805 | 12.604 | 12.601 | 0.0221 | 7.5391 | 0.59367 |  |
| dyn_queue (N=4000000) | latest | measured | — | 0.0046897 | 4.326 | 4.3213 | 0.0081606 | 28.598 | — |  |
| dyn_queue (N=4000000) | baseline | measured | — | 0.0056428 | 5.5423 | 5.5366 | 0.0018323 | 28.105 | 0.78049 |  |
| dyn_queue (N=4000000) | icarus | measured | 0.0039071 | 0.0028525 | 10.326 | 10.323 | 0.010765 | 7.3984 | 0.41859 |  |
| dyn_queue (N=4000000) | verilator | measured | 5.0115 | 0.0013167 | 0.10516 | 0.10384 | 0.00095193 | 3.8164 | 41.614 |  |
| dyn_queue (N=4000000) | icarus_devel | measured | 0.0038345 | 0.0026798 | 9.699 | 9.6964 | 0.021838 | 7.6094 | 0.44566 |  |
| fork_join (N=4000000) | latest | measured | — | 0.0057141 | 5.1984 | 5.1927 | 0.011902 | 28.285 | — |  |
| fork_join (N=4000000) | baseline | measured | — | 0.0053679 | 6.9901 | 6.9848 | 0.039291 | 28.141 | 0.74343 |  |
| fork_join (N=4000000) | icarus | measured | 0.0038408 | 0.002681 | 9.0414 | 9.0387 | 0.006173 | 7.3906 | 0.57449 |  |
| fork_join (N=4000000) | verilator | measured | 5.6648 | 0.0013162 | 1.7496 | 1.7483 | 0.00136 | 3.8516 | 2.9702 |  |
| fork_join (N=4000000) | icarus_devel | measured | 0.0036334 | 0.0025579 | 6.7505 | 6.7479 | 0.0019473 | 7.5547 | 0.76952 |  |
| func_call (N=1500000) | latest | measured | — | 0.0055059 | 4.9088 | 4.9033 | 0.0094444 | 28.363 | — |  |
| func_call (N=1500000) | baseline | measured | — | 0.0053091 | 6.7486 | 6.7433 | 0.01306 | 28.148 | 0.72714 |  |
| func_call (N=1500000) | icarus | measured | 0.0038024 | 0.0027488 | 15.371 | 15.368 | 0.011146 | 7.3516 | 0.31906 |  |
| func_call (N=1500000) | verilator | measured | 4.7563 | 0.0013019 | 0.0084523 | 0.0071504 | 0.00011806 | 0.32031 | 685.74 | short incremental time; sensitive to timing noise |
| func_call (N=1500000) | icarus_devel | measured | 0.00366 | 0.0025276 | 10.389 | 10.386 | 0.070802 | 7.4727 | 0.4721 |  |
| gate_udp (N=400000) | latest | measured | — | 0.0058938 | 4.2973 | 4.2914 | 0.012893 | 28.367 | — |  |
| gate_udp (N=400000) | baseline | measured | — | 0.0059513 | 7.6274 | 7.6214 | 0.017947 | 28.164 | 0.56307 |  |
| gate_udp (N=400000) | icarus | measured | 0.0049559 | 0.0036075 | 4.8942 | 4.8906 | 0.0025806 | 7.5156 | 0.87749 |  |
| gate_udp (N=400000) | verilator | measured | 5.4455 | 0.0012927 | 0.06234 | 0.061048 | 5.9316e-05 | 3.8555 | 70.297 |  |
| gate_udp (N=400000) | icarus_devel | measured | 0.0047895 | 0.0034617 | 4.4893 | 4.4858 | 0.0032195 | 7.6328 | 0.95666 |  |
| mem_rw (N=4000000) | latest | measured | — | 0.005698 | 4.7678 | 4.7621 | 0.0050374 | 28.469 | — |  |
| mem_rw (N=4000000) | baseline | measured | — | 0.0067684 | 7.3022 | 7.2955 | 0.012978 | 28.195 | 0.65275 |  |
| mem_rw (N=4000000) | icarus | measured | 0.0041228 | 0.0032403 | 6.0599 | 6.0567 | 0.011452 | 7.4297 | 0.78625 |  |
| mem_rw (N=4000000) | verilator | measured | 5.5797 | 0.0013603 | 0.98017 | 0.97881 | 0.00080062 | 3.8203 | 4.8652 |  |
| mem_rw (N=4000000) | icarus_devel | measured | 0.0039075 | 0.0031727 | 4.3561 | 4.3529 | 0.0083878 | 7.5547 | 1.094 |  |
| nba_burst (N=500000) | latest | measured | — | 0.0049787 | 0.10669 | 0.10171 | 0.0018575 | 124.55 | — |  |
| nba_burst (N=500000) | baseline | measured | — | 0.0051344 | 0.152 | 0.14687 | 0.00022571 | 124.4 | 0.69252 |  |
| nba_burst (N=500000) | icarus | measured | 0.0049496 | 0.0024663 | 0.16923 | 0.16676 | 0.00036443 | 33.801 | 0.60989 |  |
| nba_burst (N=500000) | verilator | measured | 5.5587 | 0.0013303 | 0.0013434 | 1.3141e-05 | 5.1566e-05 | 0.31641 | 7739.7 | short incremental time; sensitive to timing noise; incremental time is close to observed dispersion |
| nba_burst (N=500000) | icarus_devel | measured | 0.0036154 | 0.0023424 | 0.16785 | 0.16551 | 0.0001318 | 33.953 | 0.61451 |  |
| nba_shift (N=1000000) | latest | measured | — | 0.0053094 | 20.941 | 20.935 | 0.020018 | 28.543 | — |  |
| nba_shift (N=1000000) | baseline | measured | — | 0.0061464 | 35.697 | 35.691 | 0.16981 | 28.219 | 0.58658 |  |
| nba_shift (N=1000000) | icarus | measured | 0.0042937 | 0.0031604 | 34.574 | 34.57 | 0.033723 | 7.4648 | 0.60558 |  |
| nba_shift (N=1000000) | verilator | measured | 5.7367 | 0.001313 | 0.28266 | 0.28134 | 0.0003116 | 3.8516 | 74.411 |  |
| nba_shift (N=1000000) | icarus_devel | measured | 0.0040278 | 0.0029771 | 34.243 | 34.24 | 0.065789 | 7.6367 | 0.61142 |  |
| proc_wait (N=1000000) | latest | measured | — | 0.0076138 | 7.8733 | 7.8657 | 0.016729 | 32.383 | — |  |
| proc_wait (N=1000000) | baseline | measured | — | 0.0073996 | 10.507 | 10.5 | 0.037061 | 30.16 | 0.74912 |  |
| proc_wait (N=1000000) | icarus | measured | 0.0067382 | 0.0037808 | 8.612 | 8.6082 | 0.0048639 | 7.832 | 0.91374 |  |
| proc_wait (N=1000000) | verilator | measured | 7.3998 | 0.0013786 | 2.9326 | 2.9312 | 0.012607 | 3.9844 | 2.6834 |  |
| proc_wait (N=1000000) | icarus_devel | measured | 0.0050368 | 0.0035357 | 8.1649 | 8.1613 | 0.018692 | 8.0781 | 0.96377 |  |
| string_fmt (N=500000) | latest | measured | — | 0.0045222 | 4.0487 | 4.0442 | 0.013973 | 28.445 | — |  |
| string_fmt (N=500000) | baseline | measured | — | 0.0051012 | 5.8381 | 5.833 | 0.010001 | 28.285 | 0.69333 |  |
| string_fmt (N=500000) | icarus | measured | 0.0038276 | 0.0027992 | 15.059 | 15.056 | 0.019769 | 7.4023 | 0.26861 |  |
| string_fmt (N=500000) | verilator | measured | 4.9013 | 0.0012986 | 0.19885 | 0.19755 | 0.00013327 | 3.9258 | 20.471 |  |
| string_fmt (N=500000) | icarus_devel | measured | 0.0038155 | 0.0026931 | 11.829 | 11.827 | 0.016264 | 7.5234 | 0.34195 |  |
| wide_arith (N=1500000) | latest | measured | — | 0.0050175 | 2.8057 | 2.8006 | 0.0035698 | 28.48 | — |  |
| wide_arith (N=1500000) | baseline | measured | — | 0.0050606 | 7.1395 | 7.1344 | 0.02808 | 28.215 | 0.39255 |  |
| wide_arith (N=1500000) | icarus | measured | 0.0041984 | 0.0026669 | 14.58 | 14.578 | 0.0042485 | 7.293 | 0.19212 |  |
| wide_arith (N=1500000) | verilator | measured | 4.7627 | 0.001351 | 0.12071 | 0.11936 | 0.00074967 | 3.8359 | 23.464 |  |
| wide_arith (N=1500000) | icarus_devel | measured | 0.0036469 | 0.0025637 | 2.6632 | 2.6607 | 0.0049688 | 7.4453 | 1.0526 |  |
| fourstate_mix (N=1000000) | latest | measured | — | 0.0046969 | 1.0696 | 1.0649 | 0.0048126 | 28.609 | — |  |
| fourstate_mix (N=1000000) | baseline | measured | — | 0.0051298 | 1.735 | 1.7299 | 0.0027224 | 28.379 | 0.61558 |  |
| fourstate_mix (N=1000000) | icarus | measured | 0.0040936 | 0.0027594 | 3.2047 | 3.2019 | 0.0077762 | 7.3945 | 0.33257 |  |
| fourstate_mix (N=1000000) | verilator | unsupported | — | — | — | — | — | — | — | X/Z observations require four-state semantics; excluded before execution |
| fourstate_mix (N=1000000) | icarus_devel | measured | 0.0036867 | 0.0027603 | 2.2074 | 2.2046 | 0.0042501 | 7.5273 | 0.48302 |  |
| fifo_stream (N=200000) | latest | measured | — | 0.0055887 | 0.53779 | 0.5322 | 0.0006325 | 28.539 | — |  |
| fifo_stream (N=200000) | baseline | measured | — | 0.0057213 | 0.775 | 0.76928 | 0.00021918 | 28.395 | 0.69182 |  |
| fifo_stream (N=200000) | icarus | measured | 0.0042366 | 0.0026667 | 0.55572 | 0.55305 | 0.00036057 | 7.4414 | 0.9623 |  |
| fifo_stream (N=200000) | verilator | measured | 5.6216 | 0.0013489 | 0.063251 | 0.061903 | 6.1041e-05 | 3.8281 | 8.5975 |  |
| fifo_stream (N=200000) | icarus_devel | measured | 0.0041837 | 0.0024274 | 0.47471 | 0.47228 | 0.00097188 | 7.5859 | 1.1269 |  |
| uart_loopback (N=20000) | latest | measured | — | 0.0049831 | 0.5513 | 0.54632 | 0.0010573 | 28.52 | — |  |
| uart_loopback (N=20000) | baseline | measured | — | 0.0059969 | 0.70712 | 0.70112 | 0.0025212 | 28.363 | 0.77921 |  |
| uart_loopback (N=20000) | icarus | measured | 0.0054465 | 0.0028923 | 0.33417 | 0.33128 | 0.00032353 | 7.4102 | 1.6491 |  |
| uart_loopback (N=20000) | verilator | measured | 5.6495 | 0.001321 | 0.073387 | 0.072066 | 5.8611e-05 | 3.8164 | 7.5808 |  |
| uart_loopback (N=20000) | icarus_devel | measured | 0.0040803 | 0.0026812 | 0.29352 | 0.29084 | 0.00092714 | 7.5547 | 1.8784 |  |
| bus_fabric (N=150000) | latest | measured | — | 0.0058928 | 1.4798 | 1.474 | 0.0056496 | 28.602 | — |  |
| bus_fabric (N=150000) | baseline | measured | — | 0.0061875 | 2.1463 | 2.1401 | 0.0021872 | 28.316 | 0.68873 |  |
| bus_fabric (N=150000) | icarus | measured | 0.0046389 | 0.0030919 | 0.72895 | 0.72586 | 0.0015695 | 7.4766 | 2.0306 |  |
| bus_fabric (N=150000) | verilator | measured | 5.5546 | 0.0013499 | 0.08099 | 0.079641 | 0.00018739 | 3.8242 | 18.508 |  |
| bus_fabric (N=150000) | icarus_devel | measured | 0.0045501 | 0.0029187 | 0.65951 | 0.65659 | 0.00028563 | 7.6289 | 2.2449 |  |
| hierarchy_fanout (N=100000) | latest | measured | — | 0.0091816 | 6.8984 | 6.8892 | 0.029215 | 36.496 | — |  |
| hierarchy_fanout (N=100000) | baseline | measured | — | 0.010068 | 11.321 | 11.31 | 0.014028 | 36.18 | 0.6091 |  |
| hierarchy_fanout (N=100000) | icarus | measured | 0.0087278 | 0.0088915 | 25.991 | 25.982 | 0.10113 | 8.332 | 0.26516 |  |
| hierarchy_fanout (N=100000) | verilator | measured | 5.6344 | 0.0013455 | 0.028118 | 0.026772 | 0.00070626 | 3.8516 | 257.33 | short incremental time; sensitive to timing noise |
| hierarchy_fanout (N=100000) | icarus_devel | measured | 0.0088617 | 0.0083298 | 7.9784 | 7.9701 | 0.046284 | 8.4219 | 0.86438 |  |
| event_fanout (N=50000) | latest | measured | — | 0.014016 | 2.2385 | 2.2245 | 0.0053921 | 42.48 | — |  |
| event_fanout (N=50000) | baseline | measured | — | 0.012211 | 2.8947 | 2.8825 | 0.00099075 | 42.387 | 0.77172 |  |
| event_fanout (N=50000) | icarus | measured | 0.010425 | 0.0071271 | 3.4365 | 3.4294 | 0.0010494 | 9.0781 | 0.64865 |  |
| event_fanout (N=50000) | verilator | measured | 5.8738 | 0.0013442 | 0.05468 | 0.053336 | 0.00018695 | 3.8711 | 41.707 |  |
| event_fanout (N=50000) | icarus_devel | measured | 0.0095397 | 0.0070701 | 3.367 | 3.3599 | 0.0040222 | 9.2773 | 0.66206 |  |
| word_boundary (N=4000000) | latest | measured | — | 0.004571 | 5.4372 | 5.4327 | 0.028745 | 28.441 | — |  |
| word_boundary (N=4000000) | baseline | measured | — | 0.005346 | 10.256 | 10.251 | 0.026255 | 28.309 | 0.52996 |  |
| word_boundary (N=4000000) | icarus | measured | 0.0046431 | 0.002701 | 23.931 | 23.928 | 0.054471 | 7.332 | 0.22704 |  |
| word_boundary (N=4000000) | verilator | measured | 4.7623 | 0.0012916 | 0.037958 | 0.036667 | 0.0001063 | 3.8086 | 148.16 | short incremental time; sensitive to timing noise |
| word_boundary (N=4000000) | icarus_devel | measured | 0.0034978 | 0.0025502 | 8.2356 | 8.233 | 0.036622 | 7.4883 | 0.65986 |  |
| wide_divide (N=80000) | latest | measured | — | 0.0052693 | 0.17204 | 0.16677 | 0.0011769 | 28.605 | — |  |
| wide_divide (N=80000) | baseline | measured | — | 0.0052367 | 1.1636 | 1.1584 | 0.00046875 | 28.363 | 0.14397 |  |
| wide_divide (N=80000) | icarus | measured | 0.0037215 | 0.0024171 | 1.0737 | 1.0713 | 0.0017482 | 7.3477 | 0.15567 |  |
| wide_divide (N=80000) | verilator | measured | 4.7978 | 0.0012985 | 0.0094977 | 0.0081992 | 3.7445e-05 | 0.31641 | 20.34 | short incremental time; sensitive to timing noise |
| wide_divide (N=80000) | icarus_devel | measured | 0.0035955 | 0.0022536 | 0.54547 | 0.54322 | 0.00078501 | 7.4258 | 0.30701 |  |
| packed_slice (N=1500000) | latest | measured | — | 0.0053669 | 2.5157 | 2.5104 | 0.0073117 | 28.543 | — |  |
| packed_slice (N=1500000) | baseline | measured | — | 0.0052772 | 6.1231 | 6.1178 | 0.0046381 | 28.141 | 0.41033 |  |
| packed_slice (N=1500000) | icarus | measured | 0.0044405 | 0.0027974 | 8.9139 | 8.9111 | 0.042857 | 7.3477 | 0.28171 |  |
| packed_slice (N=1500000) | verilator | measured | 4.9022 | 0.0012814 | 0.092939 | 0.091657 | 0.00021386 | 3.8086 | 27.388 |  |
| packed_slice (N=1500000) | icarus_devel | measured | 0.0038748 | 0.0025173 | 3.2855 | 3.2829 | 0.002334 | 7.4531 | 0.76467 |  |
| memory_scatter (N=5000000) | latest | measured | — | 0.04267 | 2.2707 | 2.228 | 0.0056896 | 42.48 | — |  |
| memory_scatter (N=5000000) | baseline | measured | — | 0.047248 | 5.1507 | 5.1035 | 0.0031699 | 42.324 | 0.43657 |  |
| memory_scatter (N=5000000) | icarus | measured | 0.0040139 | 0.025857 | 12.316 | 12.29 | 0.014767 | 7.8555 | 0.18129 |  |
| memory_scatter (N=5000000) | verilator | measured | 4.7677 | 0.0013776 | 0.0084254 | 0.0070477 | 3.1845e-05 | 0.31641 | 316.13 | short incremental time; sensitive to timing noise |
| memory_scatter (N=5000000) | icarus_devel | measured | 0.0035836 | 0.016466 | 7.0639 | 7.0474 | 0.0019058 | 7.9805 | 0.31615 |  |
| clock_domains (N=20000) | latest | measured | — | 0.0045192 | 0.16569 | 0.16118 | 0.00066086 | 28.484 | — |  |
| clock_domains (N=20000) | baseline | measured | — | 0.004884 | 0.21172 | 0.20684 | 0.00066265 | 28.363 | 0.77925 |  |
| clock_domains (N=20000) | icarus | measured | 0.0035693 | 0.0026627 | 0.10772 | 0.10505 | 0.00018013 | 7.3789 | 1.5342 |  |
| clock_domains (N=20000) | verilator | measured | 5.4812 | 0.0011255 | 0.072833 | 0.071708 | 0.00039529 | 3.8438 | 2.2477 |  |
| clock_domains (N=20000) | icarus_devel | measured | 0.0035223 | 0.0023164 | 0.10515 | 0.10283 | 0.00050029 | 7.5273 | 1.5674 |  |
| fourstate_arith (N=100000) | latest | measured | — | 0.0049316 | 0.13619 | 0.13126 | 0.00067384 | 28.605 | — |  |
| fourstate_arith (N=100000) | baseline | measured | — | 0.0049805 | 0.17785 | 0.17287 | 0.0020641 | 28.398 | 0.75927 |  |
| fourstate_arith (N=100000) | icarus | measured | 0.0038102 | 0.0025524 | 0.2388 | 0.23625 | 0.00038786 | 7.3203 | 0.55558 |  |
| fourstate_arith (N=100000) | verilator | unsupported | — | — | — | — | — | — | — | X/Z observations require four-state semantics; excluded before execution |
| fourstate_arith (N=100000) | icarus_devel | measured | 0.0035961 | 0.0023928 | 0.22318 | 0.22079 | 0.00028242 | 7.4922 | 0.59449 |  |
| resolved_bus (N=50000) | latest | measured | — | 0.0050774 | 0.24063 | 0.23555 | 0.001653 | 28.543 | — |  |
| resolved_bus (N=50000) | baseline | measured | — | 0.0052277 | 0.34291 | 0.33768 | 0.00063677 | 28.371 | 0.69754 |  |
| resolved_bus (N=50000) | icarus | measured | 0.0039992 | 0.0028452 | 0.47357 | 0.47073 | 0.00019709 | 7.375 | 0.5004 |  |
| resolved_bus (N=50000) | verilator | unsupported | — | — | — | — | — | — | — | X/Z observations require four-state semantics; excluded before execution |
| resolved_bus (N=50000) | icarus_devel | measured | 0.0037745 | 0.0027463 | 0.45645 | 0.45371 | 0.0012901 | 7.5469 | 0.51917 |  |

Fixed comparison sets (all members required):

- **regression-common**: 0.62401; 12/12; casez_struct, comb_chain, dyn_queue, fork_join, func_call, gate_udp, mem_rw, nba_burst, nba_shift, proc_wait, string_fmt, wide_arith
- **regression-fourstate**: 0.61558; 1/1; fourstate_mix
- **icarus-common**: 0.48278; 12/12; casez_struct, comb_chain, dyn_queue, fork_join, func_call, gate_udp, mem_rw, nba_burst, nba_shift, proc_wait, string_fmt, wide_arith
- **icarus-fourstate**: 0.33257; 1/1; fourstate_mix
- **verilator-common**: 43.348; 12/12; casez_struct, comb_chain, dyn_queue, fork_join, func_call, gate_udp, mem_rw, nba_burst, nba_shift, proc_wait, string_fmt, wide_arith
- **expanded-regression-common**: 0.58098; 22/22; casez_struct, comb_chain, dyn_queue, fork_join, func_call, gate_udp, mem_rw, nba_burst, nba_shift, proc_wait, string_fmt, wide_arith, fifo_stream, uart_loopback, bus_fabric, hierarchy_fanout, event_fanout, word_boundary, wide_divide, packed_slice, memory_scatter, clock_domains
- **expanded-regression-fourstate**: 0.68826; 3/3; fourstate_mix, fourstate_arith, resolved_bus
- **expanded-icarus-common**: 0.50072; 22/22; casez_struct, comb_chain, dyn_queue, fork_join, func_call, gate_udp, mem_rw, nba_burst, nba_shift, proc_wait, string_fmt, wide_arith, fifo_stream, uart_loopback, bus_fabric, hierarchy_fanout, event_fanout, word_boundary, wide_divide, packed_slice, memory_scatter, clock_domains
- **expanded-icarus-fourstate**: 0.45218; 3/3; fourstate_mix, fourstate_arith, resolved_bus
- **expanded-verilator-common**: 37.091; 22/22; casez_struct, comb_chain, dyn_queue, fork_join, func_call, gate_udp, mem_rw, nba_burst, nba_shift, proc_wait, string_fmt, wide_arith, fifo_stream, uart_loopback, bus_fabric, hierarchy_fanout, event_fanout, word_boundary, wide_divide, packed_slice, memory_scatter, clock_domains
- **daily-overall-icarus14**: 0.71154; 25/25; casez_struct, comb_chain, dyn_queue, fork_join, func_call, gate_udp, mem_rw, nba_burst, nba_shift, proc_wait, string_fmt, wide_arith, fourstate_mix, fifo_stream, uart_loopback, bus_fabric, hierarchy_fanout, event_fanout, word_boundary, wide_divide, packed_slice, memory_scatter, clock_domains, fourstate_arith, resolved_bus
## Latest weekly attempt

[JSON](latest-weekly.json)

**Run:** `actions-44186811554-1` — complete
2026-11-17T22:58:29.331708+00:00 → 2026-11-17T23:35:53.816729+00:00

Ratios = latest kirimasim / peer incremental elapsed; below 1 favors latest.

This is a descriptive reference on this environment. Missing/failed values are not zero.

[JSON](runs/actions-44186811554-1.json) · [Actions logs / ログ](https://github.com/kurochan001/kirimasim-tests/actions/runs/44186811554/attempts/1) · [Method / 測定方法](https://github.com/kurochan001/kirimasim-tests/blob/main/docs/daily-benchmark.md)

Environment: github-hosted-ubuntu-24.04 / AMD EPYC 7763 64-Core Processor / Linux-7.0.0-1017-azure-x86_64-with-glibc2.39

<details><summary>Measurement settings</summary>

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
  "profile": "weekly",
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

- `latest`: `441dddbd0fcd80aed298ca33311f2ee67aa8866c` — kirimasim 0.1.1 (commit 441dddbd0fcd), built with GNU 13.3.0
- `baseline`: `cfa2ccd75989c1ebb9ed63303271183377364cf0` — kirimasim 0.1.0 (commit cfa2ccd75989), built with GNU 13.3.0
- `icarus`: `dfeee909ed9f20b4870dd93423156c0170c0e1ff` — Icarus Verilog version 13.0 (stable) (dfeee90-dirty)
- `verilator`: `bbb60a403932a9f695cb6ff001ceb73de6ad9234` — Verilator 5.054 2026-11-01 rev vUNKNOWN-built20261117-bbb60a4

Definition and measurement identity: `{'config_sha256': '56c0140f54b187d0bc8506e9ab0627cbdc616b69d2a1910aa6fd9b324b2ab9b7', 'driver_sha256': '0037fb4780de47740de92f102487477aac29570998a2aa3ca095bbcbb94219fa', 'comparison_sha256': '2896f429781d5eaff2d0ecec465726de342f840892056d20304d2df179ad6be0', 'history_sha256': '50af56d972f3e551c2a9bc7ae0b8ee158405c6ab25ab7f97c36cd32bebe90f8a', 'setup_sha256': '35fd0861a6a91f6bd13719ca3a926142a8a248cb672d9499e328bfdd04c791e3', 'adapter_sha256': '4811f9d50d4a09d8794710296d644350468c49a9579a794f27af42ac9fb6b5bc', 'benchmark_commit': 'cfa2ccd75989c1ebb9ed63303271183377364cf0', 'reference_sha256': {'bench/reference_expanded.py': 'a1196d79efb88425f61cc69ba1d9ec99542f7f5dc41fac2a07ade82090b00f4a', 'bench/reference_fourstate_mix.py': '586fb643e9ef9df9e304df83e04e711aa1b875e6cb4393e6e3c98cd1707b70e1'}}`

| Case | Tool | State | Build s | T(1) median s | T(N) median s | Incremental s | MAD T(N) s | RSS MiB | latest/peer | Reason / warning |
|---|---|---|---:|---:|---:|---:|---:|---:|---:|---|
| large_hierarchy (N=20000) | latest | measured | — | 0.1501 | 30.488 | 30.338 | 0.093651 | 108.37 | — |  |
| large_hierarchy (N=20000) | baseline | measured | — | 0.15133 | 37.609 | 37.458 | 0.22551 | 108.23 | 0.80991 |  |
| large_hierarchy (N=20000) | icarus | measured | 0.18767 | 0.10443 | 88.929 | 88.824 | 0.29512 | 22.973 | 0.34155 |  |
| large_hierarchy (N=20000) | verilator | measured | 15.048 | 0.0018306 | 0.10806 | 0.10623 | 0.0010759 | 3.7969 | 285.58 |  |
| large_memory (N=500000) | latest | measured | — | 0.11288 | 29.145 | 29.032 | 0.10063 | 44.539 | — |  |
| large_memory (N=500000) | baseline | measured | — | 0.146 | 41.798 | 41.652 | 0.24891 | 44.41 | 0.69701 |  |
| large_memory (N=500000) | icarus | measured | 0.0055652 | 0.21439 | 61.457 | 61.242 | 0.016669 | 11.301 | 0.47405 |  |
| large_memory (N=500000) | verilator | measured | 8.1158 | 0.0024141 | 0.13945 | 0.13704 | 0.00082314 | 4.7266 | 211.85 |  |
| stream_pipeline (N=250000) | latest | measured | — | 0.0085583 | 29.059 | 29.051 | 0.11181 | 28.254 | — |  |
| stream_pipeline (N=250000) | baseline | measured | — | 0.010272 | 38.925 | 38.915 | 0.24568 | 28.285 | 0.74652 |  |
| stream_pipeline (N=250000) | icarus | measured | 0.0087869 | 0.0063252 | 83.492 | 83.486 | 0.28265 | 7.4883 | 0.34797 |  |
| stream_pipeline (N=250000) | verilator | measured | 8.3722 | 0.0018094 | 0.13704 | 0.13523 | 0.00030075 | 3.707 | 214.82 |  |

Fixed comparison sets (all members required):

- **weekly-regression**: 0.74973; 3/3; large_hierarchy, large_memory, stream_pipeline
- **weekly-icarus**: 0.38336; 3/3; large_hierarchy, large_memory, stream_pipeline
- **weekly-verilator**: 235.12; 3/3; large_hierarchy, large_memory, stream_pipeline

## Separate environment / definition series

### `cc3a300591d180c9`

3 runs; 2026-11-18T13:42:55.941756+00:00 → 2026-11-20T01:57:13.586055+00:00

Definition: `daily-v4-icarus14`; case count: **25**

![regression-common](charts/cc3a300591d180c94564d1f6b7c978ab008d23e394b5745165aa4940904482bd/regression-common.svg)

![regression-fourstate](charts/cc3a300591d180c94564d1f6b7c978ab008d23e394b5745165aa4940904482bd/regression-fourstate.svg)

![icarus-common](charts/cc3a300591d180c94564d1f6b7c978ab008d23e394b5745165aa4940904482bd/icarus-common.svg)

![icarus-fourstate](charts/cc3a300591d180c94564d1f6b7c978ab008d23e394b5745165aa4940904482bd/icarus-fourstate.svg)

![verilator-common](charts/cc3a300591d180c94564d1f6b7c978ab008d23e394b5745165aa4940904482bd/verilator-common.svg)

![expanded-regression-common](charts/cc3a300591d180c94564d1f6b7c978ab008d23e394b5745165aa4940904482bd/expanded-regression-common.svg)

![expanded-regression-fourstate](charts/cc3a300591d180c94564d1f6b7c978ab008d23e394b5745165aa4940904482bd/expanded-regression-fourstate.svg)

![expanded-icarus-common](charts/cc3a300591d180c94564d1f6b7c978ab008d23e394b5745165aa4940904482bd/expanded-icarus-common.svg)

![expanded-icarus-fourstate](charts/cc3a300591d180c94564d1f6b7c978ab008d23e394b5745165aa4940904482bd/expanded-icarus-fourstate.svg)

![expanded-verilator-common](charts/cc3a300591d180c94564d1f6b7c978ab008d23e394b5745165aa4940904482bd/expanded-verilator-common.svg)

![daily-overall-icarus14](charts/cc3a300591d180c94564d1f6b7c978ab008d23e394b5745165aa4940904482bd/daily-overall-icarus14.svg)

Runs, including failures:

- [actions-44656096600-1](runs/actions-44656096600-1.json): complete — `cb97fc93bf6b`
- [actions-44440143026-1](runs/actions-44440143026-1.json): incomplete — `a6222f0656d4`
- [actions-44311501813-1](runs/actions-44311501813-1.json): complete — `441dddbd0fcd`
### `25a1c78c12d65db9`

1 runs; 2026-11-18T02:38:15.609997+00:00 → 2026-11-18T02:38:15.609997+00:00

Definition: `daily-v3-expanded`; case count: **25**

![regression-common](charts/25a1c78c12d65db98513377f5b0378ea74a2d9c42643d7ac36a95e5fa701da53/regression-common.svg)

![regression-fourstate](charts/25a1c78c12d65db98513377f5b0378ea74a2d9c42643d7ac36a95e5fa701da53/regression-fourstate.svg)

![icarus-common](charts/25a1c78c12d65db98513377f5b0378ea74a2d9c42643d7ac36a95e5fa701da53/icarus-common.svg)

![icarus-fourstate](charts/25a1c78c12d65db98513377f5b0378ea74a2d9c42643d7ac36a95e5fa701da53/icarus-fourstate.svg)

![verilator-common](charts/25a1c78c12d65db98513377f5b0378ea74a2d9c42643d7ac36a95e5fa701da53/verilator-common.svg)

![expanded-regression-common](charts/25a1c78c12d65db98513377f5b0378ea74a2d9c42643d7ac36a95e5fa701da53/expanded-regression-common.svg)

![expanded-regression-fourstate](charts/25a1c78c12d65db98513377f5b0378ea74a2d9c42643d7ac36a95e5fa701da53/expanded-regression-fourstate.svg)

![expanded-icarus-common](charts/25a1c78c12d65db98513377f5b0378ea74a2d9c42643d7ac36a95e5fa701da53/expanded-icarus-common.svg)

![expanded-icarus-fourstate](charts/25a1c78c12d65db98513377f5b0378ea74a2d9c42643d7ac36a95e5fa701da53/expanded-icarus-fourstate.svg)

![expanded-verilator-common](charts/25a1c78c12d65db98513377f5b0378ea74a2d9c42643d7ac36a95e5fa701da53/expanded-verilator-common.svg)

Runs, including failures:

- [actions-44223268236-1](runs/actions-44223268236-1.json): complete — `441dddbd0fcd`
### `079515db5b1afbed`

1 runs; 2026-11-17T22:58:29.331708+00:00 → 2026-11-17T22:58:29.331708+00:00

Definition: `weekly-v1-scale`; case count: **3**

![weekly-regression](charts/079515db5b1afbed9ad8eb3b50315933d96ba21786a315eb6d8889d659fc226d/weekly-regression.svg)

![weekly-icarus](charts/079515db5b1afbed9ad8eb3b50315933d96ba21786a315eb6d8889d659fc226d/weekly-icarus.svg)

![weekly-verilator](charts/079515db5b1afbed9ad8eb3b50315933d96ba21786a315eb6d8889d659fc226d/weekly-verilator.svg)

Runs, including failures:

- [actions-44186811554-1](runs/actions-44186811554-1.json): complete — `441dddbd0fcd`
### `ff82f2d3ef6ff628`

1 runs; 2026-11-17T21:58:35.859990+00:00 → 2026-11-17T21:58:35.859990+00:00

Definition: `daily-v3-expanded`; case count: **25**

![regression-common](charts/ff82f2d3ef6ff62846952684f63f6483b672a27cef53f4412edc1f790039a58c/regression-common.svg)

![regression-fourstate](charts/ff82f2d3ef6ff62846952684f63f6483b672a27cef53f4412edc1f790039a58c/regression-fourstate.svg)

![icarus-common](charts/ff82f2d3ef6ff62846952684f63f6483b672a27cef53f4412edc1f790039a58c/icarus-common.svg)

![icarus-fourstate](charts/ff82f2d3ef6ff62846952684f63f6483b672a27cef53f4412edc1f790039a58c/icarus-fourstate.svg)

![verilator-common](charts/ff82f2d3ef6ff62846952684f63f6483b672a27cef53f4412edc1f790039a58c/verilator-common.svg)

![expanded-regression-common](charts/ff82f2d3ef6ff62846952684f63f6483b672a27cef53f4412edc1f790039a58c/expanded-regression-common.svg)

![expanded-regression-fourstate](charts/ff82f2d3ef6ff62846952684f63f6483b672a27cef53f4412edc1f790039a58c/expanded-regression-fourstate.svg)

![expanded-icarus-common](charts/ff82f2d3ef6ff62846952684f63f6483b672a27cef53f4412edc1f790039a58c/expanded-icarus-common.svg)

![expanded-icarus-fourstate](charts/ff82f2d3ef6ff62846952684f63f6483b672a27cef53f4412edc1f790039a58c/expanded-icarus-fourstate.svg)

![expanded-verilator-common](charts/ff82f2d3ef6ff62846952684f63f6483b672a27cef53f4412edc1f790039a58c/expanded-verilator-common.svg)

Runs, including failures:

- [actions-44183926839-1](runs/actions-44183926839-1.json): complete — `234f65f6b205`
### `962ea28f5124b999`

1 runs; 2026-11-17T15:00:17.437065+00:00 → 2026-11-17T15:00:17.437065+00:00

Definition: `daily-v2-thirteen`; case count: **13**

![regression-common](charts/962ea28f5124b99939a8ae6dec023cb53d2fa7f3769aecf4e0801a27d99c196d/regression-common.svg)

![regression-fourstate](charts/962ea28f5124b99939a8ae6dec023cb53d2fa7f3769aecf4e0801a27d99c196d/regression-fourstate.svg)

![icarus-common](charts/962ea28f5124b99939a8ae6dec023cb53d2fa7f3769aecf4e0801a27d99c196d/icarus-common.svg)

![icarus-fourstate](charts/962ea28f5124b99939a8ae6dec023cb53d2fa7f3769aecf4e0801a27d99c196d/icarus-fourstate.svg)

![verilator-common](charts/962ea28f5124b99939a8ae6dec023cb53d2fa7f3769aecf4e0801a27d99c196d/verilator-common.svg)

Runs, including failures:

- [actions-44103555558-1](runs/actions-44103555558-1.json): complete — `13d52dde3c49`
### `ff134f2dfe29a369`

1 runs; 2026-11-17T13:04:45.723115+00:00 → 2026-11-17T13:04:45.723115+00:00

Definition: `daily-v1`; case count: **5**

![regression-common](charts/ff134f2dfe29a369d8116a07680e0a4ea53e757ba74a0abb4811823a01606d89/regression-common.svg)

![regression-fourstate](charts/ff134f2dfe29a369d8116a07680e0a4ea53e757ba74a0abb4811823a01606d89/regression-fourstate.svg)

![icarus-common](charts/ff134f2dfe29a369d8116a07680e0a4ea53e757ba74a0abb4811823a01606d89/icarus-common.svg)

![icarus-fourstate](charts/ff134f2dfe29a369d8116a07680e0a4ea53e757ba74a0abb4811823a01606d89/icarus-fourstate.svg)

![verilator-common](charts/ff134f2dfe29a369d8116a07680e0a4ea53e757ba74a0abb4811823a01606d89/verilator-common.svg)

Runs, including failures:

- [actions-44085771320-1](runs/actions-44085771320-1.json): complete — `26f359bcd504`

</details>

# Nightly results of kirimasim-tests

The [nightly workflow](https://github.com/kurochan001/kirimasim-tests/actions/workflows/nightly.yml) of [kirimasim-tests](https://github.com/kurochan001/kirimasim-tests) writes this branch. Each night it runs every test of the suite's main branch with each simulator, adds the results to `history.json` and draws the charts below. A test matches when the simulator's normalized standard output is exactly its expected output; see the suite's README for what each status means.

Latest run: 2026-10-20 05:01 UTC, suite commit [`56508cd`](https://github.com/kurochan001/kirimasim-tests/commit/56508cdce0a414ca1623756c6856dd1f49819977), 2327 tests, [workflow run](https://github.com/kurochan001/kirimasim-tests/actions/runs/39363555028).

| Simulator | Version | Match | Differ | Known differences | Unsupported | Since the previous run |
| --- | --- | ---: | ---: | ---: | ---: | --- |
| Icarus Verilog | Icarus Verilog version 14.0 (devel) (s20260301-617-geed9291c) | 1578 (67.8%) | 0 | 749 | 0 | 151 new tests (56 match) |
| Verilator | Verilator 5.053 devel rev v5.052-507-g01770671 | 1928 (82.9%) | 0 | 399 | 0 | 15 newly match, 151 new tests (88 match) |
| kirimasim | kirimasim 0.0.0 (commit ff80adcf6051), built with GNU 13.3.0 | 1590 (68.3%) | 9 | 0 | 728 | 1 newly match, 151 new tests (59 match) |

![Tests that match their expected output](charts/overview.svg)

![Share of the tests that match](charts/rate.svg)

## Changes in the latest run

Tests that match now but did not in the previous run of the same simulator, and tests that matched then but do not now. Tests added to the suite are counted in the table above.

### Verilator

Newly match (15): `ch18/test_constraint_foreach_sum`, `ch18/test_constraint_implication_ifelse`, `ch18/test_constraint_inheritance_override`, `ch18/test_constraint_unique`, `ch18/test_dist_zero_weight`, `ch18/test_extern_constraint_function`, `ch18/test_pre_post_randomize`, `ch18/test_rand_constraints_hold`, `ch18/test_rand_mode_constraint_mode`, `ch18/test_randomize_null_checker`, `ch18/test_randomize_with_local_scope`, `ch18/test_soft_constraint_priority`, `ch18/test_static_constraint_mode`, `ch18/test_std_randomize_with`, `ch26/test_std_package_access`

### kirimasim

Newly match (1): `ch9/test_always_comb_sensitivity_exceptions`

## By chapter

![Matching tests by chapter](charts/chapters.svg)

## Each simulator over time

![Icarus Verilog: results by status](charts/status-icarus.svg)

![Verilator: results by status](charts/status-verilator.svg)

![kirimasim: results by status](charts/status-kirimasim.svg)

## Recent runs

Matching tests of each simulator, with the change since its previous run. The version is shown when it changed.

| Run (UTC) | Suite | Tests | Icarus Verilog | Verilator | kirimasim |
| --- | --- | ---: | ---: | ---: | ---: |
| [2026-10-20 05:01](https://github.com/kurochan001/kirimasim-tests/actions/runs/39363555028) | [`56508cd`](https://github.com/kurochan001/kirimasim-tests/commit/56508cdce0a414ca1623756c6856dd1f49819977) | 2327 | 1578 (+56 −0) | 1928 (+103 −0) `5.053 devel 0177067` | 1590 (+60 −0) `ff80adcf6` |
| [2026-10-19 22:42](https://github.com/kurochan001/kirimasim-tests/actions/runs/39329365210) | [`42081bd`](https://github.com/kurochan001/kirimasim-tests/commit/42081bd73c354db73c20b1b17fb076975ae5a16f) | 2176 | 1522 `14.0 devel eed9291` | 1825 `5.053 devel 60f166e` | 1530 `8b598b574` |

## Files

- `history.json`: one entry per run, with the counts of each simulator by status and by chapter, and the tests whose result changed.
- `latest/<simulator>.json`: the result of every test in the latest run of each simulator, which the next run is compared with.
- `charts/*.svg`: the charts above.

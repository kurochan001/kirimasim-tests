# Nightly results of kirimasim-tests

The [nightly workflow](https://github.com/kurochan001/kirimasim-tests/actions/workflows/nightly.yml) of [kirimasim-tests](https://github.com/kurochan001/kirimasim-tests) writes this branch. Each night it runs every test of the suite's main branch with each simulator, adds the results to `history.json` and draws the charts below. A test matches when the simulator's normalized standard output is exactly its expected output; see the suite's README for what each status means.

Latest run: 2026-10-19 22:42 UTC, suite commit [`42081bd`](https://github.com/kurochan001/kirimasim-tests/commit/42081bd73c354db73c20b1b17fb076975ae5a16f), 2176 tests, [workflow run](https://github.com/kurochan001/kirimasim-tests/actions/runs/39329365210).

| Simulator | Version | Match | Differ | Known differences | Unsupported | Since the previous run |
| --- | --- | ---: | ---: | ---: | ---: | --- |
| Icarus Verilog | Icarus Verilog version 14.0 (devel) (s20260301-617-geed9291c) | 1522 (69.9%) | 0 | 654 | 0 | first run |
| Verilator | Verilator 5.053 devel rev v5.052-506-g60f166e1 | 1825 (83.9%) | 15 | 336 | 0 | first run |
| kirimasim | kirimasim 0.0.0 (commit 8b598b574f1e), built with GNU 13.3.0 | 1530 (70.3%) | 7 | 0 | 639 | first run |

![Tests that match their expected output](charts/overview.svg)

![Share of the tests that match](charts/rate.svg)

## Changes in the latest run

Tests that match now but did not in the previous run of the same simulator, and tests that matched then but do not now. Tests added to the suite are counted in the table above.

No test changed its result since the previous run.

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
| [2026-10-19 22:42](https://github.com/kurochan001/kirimasim-tests/actions/runs/39329365210) | [`42081bd`](https://github.com/kurochan001/kirimasim-tests/commit/42081bd73c354db73c20b1b17fb076975ae5a16f) | 2176 | 1522 `14.0 devel eed9291` | 1825 `5.053 devel 60f166e` | 1530 `8b598b574` |

## Files

- `history.json`: one entry per run, with the counts of each simulator by status and by chapter, and the tests whose result changed.
- `latest/<simulator>.json`: the result of every test in the latest run of each simulator, which the next run is compared with.
- `charts/*.svg`: the charts above.

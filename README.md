# Nightly results of kirimasim-tests

The [nightly workflow](https://github.com/kurochan001/kirimasim-tests/actions/workflows/nightly.yml) of [kirimasim-tests](https://github.com/kurochan001/kirimasim-tests) writes this branch. Each night it runs every test of the suite's main branch with each simulator, adds the results to `history.json` and draws the charts below. A test matches when the simulator's normalized standard output is exactly its expected output; see the suite's README for what each status means.

Latest run: 2026-10-21 01:31 UTC, suite commit [`0cfd00b`](https://github.com/kurochan001/kirimasim-tests/commit/0cfd00b58140ba628bb18a68e439933a07312fa2), 3403 tests, [workflow run](https://github.com/kurochan001/kirimasim-tests/actions/runs/39523323680).

| Simulator | Version | Match | Differ | Known differences | Unsupported | Since the previous run |
| --- | --- | ---: | ---: | ---: | ---: | --- |
| Icarus Verilog | Icarus Verilog version 14.0 (devel) (s20260301-626-g7e3d0c6b) | 2471 (72.6%) | 0 | 932 | 0 | 71 new tests (36 match) |
| Verilator | Verilator 5.053 devel rev v5.052-520-g4c98f029 | 2512 (73.8%) | 0 | 891 | 0 | 71 new tests (35 match) |
| kirimasim | kirimasim 0.0.0 (commit 7b2b17aa1c3c), built with GNU 13.3.0 | 2405 (70.7%) | 13 | 0 | 985 | 15 newly match, 71 new tests (46 match) |
| sukimasim | sukimasim version 0.9.9.2 (commit d6f36ecb4b86) | 2576 (75.7%) | 827 | 0 | 0 | 71 new tests (22 match) |

sukimasim's repository is private: the nightly workflow builds its latest `main` from there, and only its results are published.

![Tests that match their expected output](charts/overview.svg)

![Share of the tests that match](charts/rate.svg)

## Changes in the latest run

Tests that match now but did not in the previous run of the same simulator, and tests that matched then but do not now. Tests added to the suite are counted in the table above.

### kirimasim

Newly match (15): `ch20/test_stime_time_units`, `ch20/test_timeunit_timeprecision_functions`, `ch20/test_timeunit_unit_root`, `ch21/test_file_fflush_ferror`, `ch21/test_file_fgetc_ungetc`, `ch21/test_file_fread`, `ch21/test_file_fscanf`, `ch21/test_file_lines_fgets_feof`, `ch21/test_file_seek_tell_rewind`, `ch21/test_readmem_multidim_packed`, `ch21/test_readmemh_addresses_comments`, `ch21/test_writemem_packed_data`, `ch21/test_writemem_two_state_enum`, `ch21/test_writememh_readback`, `ch33/test_config_library_binding_format`

## By chapter

![Matching tests by chapter](charts/chapters.svg)

## Each simulator over time

![Icarus Verilog: results by status](charts/status-icarus.svg)

![Verilator: results by status](charts/status-verilator.svg)

![kirimasim: results by status](charts/status-kirimasim.svg)

![sukimasim: results by status](charts/status-sukimasim.svg)

## Recent runs

Matching tests of each simulator, with the change since its previous run. The version is shown when it changed.

| Run (UTC) | Suite | Tests | Icarus Verilog | Verilator | kirimasim | sukimasim |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| [2026-10-21 01:31](https://github.com/kurochan001/kirimasim-tests/actions/runs/39523323680) | [`0cfd00b`](https://github.com/kurochan001/kirimasim-tests/commit/0cfd00b58140ba628bb18a68e439933a07312fa2) | 3403 | 2471 (+36 −0) | 2512 (+35 −0) `5.053 devel 4c98f02` | 2405 (+61 −0) `7b2b17aa1` | 2576 (+22 −0) `d6f36ecb4` |
| [2026-10-21 01:02](https://github.com/kurochan001/kirimasim-tests/actions/runs/39507186309) | [`824f574`](https://github.com/kurochan001/kirimasim-tests/commit/824f5748dd619afaf472f60fd0ce83d0a547d829) | 3332 | 2435 (+857 −0) | 2477 (+549 −0) `5.053 devel 3cc4981` | 2344 (+754 −0) `0680c67d5` | 2554 (+511 −0) `2754b2970` |
| [2026-10-20 07:49](https://github.com/kurochan001/kirimasim-tests/actions/runs/39387575855) | [`6bffc4a`](https://github.com/kurochan001/kirimasim-tests/commit/6bffc4a184134250ca4b934ef2b40af9961bc4d5) | 2327 | 1578 `14.0 devel 7e3d0c6` | — | 1590 `b1be7015e` | 2043 `02efa6d73` |
| [2026-10-20 05:01](https://github.com/kurochan001/kirimasim-tests/actions/runs/39363555028) | [`56508cd`](https://github.com/kurochan001/kirimasim-tests/commit/56508cdce0a414ca1623756c6856dd1f49819977) | 2327 | 1578 (+56 −0) | 1928 (+103 −0) `5.053 devel 0177067` | 1590 (+60 −0) `ff80adcf6` | — |
| [2026-10-19 22:42](https://github.com/kurochan001/kirimasim-tests/actions/runs/39329365210) | [`42081bd`](https://github.com/kurochan001/kirimasim-tests/commit/42081bd73c354db73c20b1b17fb076975ae5a16f) | 2176 | 1522 `14.0 devel eed9291` | 1825 `5.053 devel 60f166e` | 1530 `8b598b574` | — |

## Files

- `history.json`: one entry per run, with the counts of each simulator by status and by chapter, and the tests whose result changed.
- `latest/<simulator>.json`: the result of every test in the latest run of each simulator, which the next run is compared with.
- `charts/*.svg`: the charts above.

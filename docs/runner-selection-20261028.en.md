<a id="シミュレーションランナーの選択と分類2026-10-28"></a>

# Simulation-runner selection and classification (2026-10-28)

[English](runner-selection-20261028.en.md) / [日本語](runner-selection-20261028.md)

Fix records for Issue #13, “Simulation runners run :type: formal tests,” and Issue #14, “run_kirimasim.py checks no-expected-output before unsupported.” The target is suite `b83d0ffd` (7,740 tests).

<a id="1-変更内容"></a>

## 1. Change Content

- Excluded `:type: formal` from the default test selections in `run_kirimasim.py`, `run_icarus.py`, `run_verilator.py`, and `run_lyra.py`. Exclude even if you have explicitly specified a test. Formal tests have `:formal_case:` and are executed only by `tools/run_sby.py`. `:type: elaboration` continues to run in simulation as before.
- `run_kirimasim.py` checks `error: unsupported:` before “no expected value.” When the expectation is specific to another simulator (for example, `:expected_stdout_verilator:` only), classify it as `known` (known difference), counting it as neither failure nor match.
- `run_ghost.py`, `run_sby.py`, and `suite_results.py` have not been changed.

<a id="2-再分類される件数"></a>

## 2. Number of reclassified items

|Classification|Number of cases|
|---|---:|
|Formal tests excluded from simulation| 268 |
|Tests classified as `unsupported` while still lacking expected values| 16 |
|`known` test with expected values specific to other simulators| 2 |

The kirimasim run for 2026-10-28 had 462 failing tests. Of these, 286 tests are `no :expected_stdout:`: 268 formal, 16 unsupported, and 2 requiring test maintenance. After fixing, this 286 tests will be removed from the simulation failures. The test-side 40 tests is recorded in `docs/test-failure-triage-20261028.md` of the remaining fail 176 tests.

<a id="3-実行証跡の扱い"></a>

## 3. Handling of execution evidence.

Because `runner_digest()` in `tools/suite_results.py` includes `run_<simulator>.py` in the hash, changing runner files makes saved execution evidence stale. This round's Icarus / Verilator changes affect only test selection in `main()`; the `run()` evaluation logic (output comparison, classification of code that violates the standard, exit codes, and diagnostics) is unchanged.

Therefore, only `runner_sha256` was refreshed for the 37 snapshots of Icarus/Verilator used by `coverage/behavior-summary.json`. The state, `inputs_sha256`, version of the simulator, and runtime have not changed.

- Ghost: evidence is reused unchanged because the executable hash is unchanged.
- SymbiYosys: evidence is reused unchanged because `run_sby.py` and `suite_results.py` are unchanged.
- kirimasim / Lyra: official execution evidence contains no currently adopted snapshot.

<a id="4-再現検証"></a>

## 4. Reproduction and verification.

```sh
python3 -m unittest discover -s tools -p 'test_*.py'
python3 -m unittest discover -s tools -p 'test_runner_selection.py'
python3 tools/behavior_coverage.py --check --require-source-reviewed
python3 tools/requirement_matching.py --check
python3 tools/suite_stats.py --check
python3 tools/suite_catalog.py --check
python3 tools/coverage_depth.py --check --minimum-tests 2
python3 generators/generate.py --check
python3 tools/lint_metadata.py
git diff --check
```

<a id="予約語の規格違反テストの生成2026-10-24"></a>

# Generating standard-violation tests for reserved words (2026-10-24)

[English](keyword-tests-20261024.en.md) / [日本語](keyword-tests-20261024.md)

> Counts, percentages, and pending statuses in this document record their respective work dates.
> The current value is [Aggregated Summary](behavior-coverage-summary.en.md); the approval history for the denominator and interpretations is in
> See [Results of requirement extraction](requirement-extraction.en.md).

[Current aggregates](behavior-coverage-summary.en.md) / [requirement extraction and re-examination of the table.](requirement-extraction.en.md) / [Differences between simulators and the standard](simulator-differences.md)

The 2026-10-24 ledger review reworked reserved-word rows into requirements to detect rejection when each word is used as an unescaped identifier. We have created a test in the generation script to verify the requirement.

<a id="集計"></a>

## Aggregation

|Item|Before|After|
| --- | ---: | ---: |
|Mapped requirements (provisional requirement coverage by test design)| 3,889（31.569121%） | **4,386（35.603539%）** |
|Requirements with recorded passes for current inputs (provisional verified-execution rate)| 2,396（19.449631%） | **2,893（23.484049%）** |
|The supported requirements in this article (chapters 1 to 40, lines 9,486)| 2,779（29.30%） | 3,028（31.92%） |
|Number of tests (including generated tests)| 3,986（812） | 4,482（1,308） |

- Mapped 248 rows from Annex B, 248 edition-specific reservation rows for 22.14.2–22.14.8, and 1 VERSION-SET rows from 22.14.2 (497 rows in total).
- VERSION-SET of 22.14.2 (all reserved keywords in 1364-1995) is a AND collective witness, satisfied only when all 102 tests pass in one run.
- VERSION-SET rows for other versions are not mapped because no tests exercise earlier versions’ reserved words in those versions.
- 22.14.9 is also excluded (1800-2017 and 1800-2023 add no reserved words).
- Final values for both design and execution remain unconfirmed.

<a id="生成器"></a>

## Generator

`generators/keywords.py` writes 496 illegal-design tests to `tests/gen/`.

- `tests/gen/ch5/test_gen_kw_2023_<語>` (248 tests): each reserved word in Annex B.
- `tests/gen/ch22/test_gen_kw_<版>_<語>` (248 tests): reserved words added in each edition from 22.14.2 through 22.14.8.

Each test declares `reg <語>;` within `begin_keywords "版"` and requires an error on that line through `:expected_stderr_regex:`. The reason for placing `begin_keywords` is that the keyword set when not written is implementation dependent (22.14 ).

`generators/common.py` has also been extended to generate non-conformity tests. Cases with `should_fail_because` do not have expected-output files. Derive the error line from the body line ending in `// illegal`.

The list of reserved words is an addition to each version made from each table of 22.14. The generator checks that their union matches the 248 words of Annex B.

<a id="確認方法"></a>

## Verification method

- An independent verification agent separately extracted the reserved-word list from PDF’s tables using 2 methods. The generator's per-version lists (102, 21, 1, 97, 23, 4 words) and the 248 words in Annex B both matched exactly.
- Confirmed that the bodies of all 496 tests contain only 5 lines (`begin_keywords`, module, `reg <語>;`, endmodule, `end_keywords`). Checks also confirmed that the only error source is the reserved-word declaration and that the `:expected_stderr_regex:` line number matches the `// illegal` line.
- All 497 proposed mappings were accepted.
  - Correcting generator-comment wording changed error line numbers in 190 Annex B cases.
  - The 190 case re-numbers the lines recorded as the basis and takes over the original adoption decision.

<a id="実行証跡"></a>

## Execution evidence

|Run|Result|
| --- | --- |
| `coverage/results/keyword-tests-20261024-icarus13.json`（Icarus Verilog 13.0、v13_0-dirty） | 496 pass |
| `coverage/results/keyword-tests-20261024-verilator-seed1.json`（Verilator 5.052、seed 1） | 493 pass、3 known |
| `coverage/results/keyword-tests-20261024-verilator-seed73.json`（Verilator 5.052、seed 73） | 493 pass、3 known |

- Following generated-test conventions, `:oracle:` records only Icarus 13.0 (`spec iverilog@13.0`).
- Verilator 5.052 accepted the following 3 declarations.
  - `global` under `begin_keywords "1800-2023"` and `"1800-2009"`
  - `ifnone` under `begin_keywords "1364-1995"`
- Icarus 13.0 ignores `"1800-2017"` and `"1800-2023"` as unknown versions and uses the default keyword set. The default keyword set reserves the same words as Annex B, so the 248 tests for Annex B match. However, Icarus results do not establish the effect of `begin_keywords "1800-2023"` itself.
- Both differences were recorded in [Differences between simulators and the standard](simulator-differences.md).

<a id="確かめていない範囲"></a>

## Unverified range

- The test only checks that the word is reserved in the specified version.
- I have not verified that "the specified version does not reserve any other words" or that `begin_keywords` works instead of the default set. These are separate requirements (exceptions of 22.14.4, lines of 22.14).

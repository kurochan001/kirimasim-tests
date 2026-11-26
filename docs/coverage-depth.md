<a id="カバレッジの深さ"></a>

# Coverage depth

[English](coverage-depth.md) / [日本語](coverage-depth.ja.md)

These are citation counts, not passing behavior counts: [what two tests per clause establish](faq.en.md#q17-do-two-tests-per-clause-cover-every-behavior). For requirement numerators and denominators, see [design versus execution coverage](faq.en.md#q16-how-do-design-and-execution-coverage-differ).

[All chapters](tests/README.md). This page is written by `tools/coverage_depth.py` from the metadata of the tests; edit the tests, not this page. It counts how many tests cite each clause in `:lrm:` and which releases produce their expected outputs. A citation is not a measure of how deeply a behavior is exercised: one test can cite several clauses, and several tests can cite one clause.

<a id="要約"></a>

## Summary

| Measure | Value |
| --- | ---: |
| Tests | 17118 |
| Clauses in scope | 1086 |
| Clauses out of scope | 73 |
| Clauses with a direct test | 1086/1086 |
| Clauses with at least two direct tests | 1086/1086 |
| Clauses with one test | 0 |
| Clauses with two tests or fewer | 121 |
| Clauses with only standard-only tests | 251 |
| Clauses with one test and only a standard-only test | 0 |

| Oracle | Tests |
| --- | ---: |
| both releases | 1745 |
| Icarus Verilog 13.0 only | 7425 |
| Verilator 5.052 or 5.054 only | 3024 |
| standard only | 4924 |

<a id="章別"></a>

## By chapter

| Chapter | Title | Tests | In scope | Tests/clause | One test | Standard only |
| ---: | --- | ---: | ---: | ---: | ---: | ---: |
| 3 | Design and verification building blocks | 166 | 17 | 9.8 | 0 | 28 |
| 4 | Scheduling semantics | 485 | 27 | 18.0 | 0 | 31 |
| 5 | Lexical conventions | 533 | 16 | 33.3 | 0 | 55 |
| 6 | Data types | 924 | 76 | 12.2 | 0 | 177 |
| 7 | Aggregate data types | 1139 | 49 | 23.2 | 0 | 321 |
| 8 | Classes | 516 | 43 | 12.0 | 0 | 156 |
| 9 | Processes | 493 | 25 | 19.7 | 0 | 82 |
| 10 | Assignment statements | 770 | 18 | 42.8 | 0 | 88 |
| 11 | Operators and expressions | 2638 | 42 | 62.8 | 0 | 371 |
| 12 | Procedural programming statements | 328 | 20 | 16.4 | 0 | 78 |
| 13 | Tasks and functions (subroutines) | 764 | 15 | 50.9 | 0 | 170 |
| 14 | Clocking blocks | 174 | 15 | 11.6 | 0 | 71 |
| 15 | Interprocess synchronization and communication | 218 | 21 | 10.4 | 0 | 146 |
| 16 | Assertions | 819 | 69 | 11.9 | 0 | 658 |
| 17 | Checkers | 141 | 11 | 12.8 | 0 | 92 |
| 18 | Constrained random value generation | 302 | 44 | 6.9 | 0 | 159 |
| 19 | Functional coverage | 259 | 24 | 10.8 | 0 | 188 |
| 20 | Utility system tasks and system functions | 723 | 32 | 22.6 | 0 | 201 |
| 21 | Input/output system tasks and system functions | 971 | 48 | 20.2 | 0 | 312 |
| 22 | Compiler directives | 1332 | 22 | 60.5 | 0 | 45 |
| 23 | Modules and hierarchy | 448 | 34 | 13.2 | 0 | 99 |
| 24 | Programs | 225 | 7 | 32.1 | 0 | 149 |
| 25 | Interfaces | 282 | 12 | 23.5 | 0 | 66 |
| 26 | Packages | 271 | 6 | 45.2 | 0 | 103 |
| 27 | Generate constructs | 295 | 5 | 59.0 | 0 | 36 |
| 28 | Gate-level and switch-level modeling | 423 | 26 | 16.3 | 0 | 91 |
| 29 | User-defined primitives | 148 | 14 | 10.6 | 0 | 37 |
| 30 | Specify blocks | 73 | 23 | 3.2 | 0 | 34 |
| 31 | Timing checks | 89 | 21 | 4.2 | 0 | 70 |
| 32 | Backannotation using the standard delay format | 80 | 11 | 7.3 | 0 | 61 |
| 33 | Configuring the contents of a design | 110 | 18 | 6.1 | 0 | 94 |
| 34 | Protected envelopes | 52 | 67 | 0.8 | 0 | 26 |
| 35 | Direct programming interface | 247 | 21 | 11.8 | 0 | 111 |
| 36 | Programming language interface (PLI/VPI) overview | 101 | 20 | 5.0 | 0 | 44 |
| 37 | VPI object model diagrams | 294 | 95 | 3.1 | 0 | 273 |
| 38 | VPI routine definitions | 190 | 47 | 4.0 | 0 | 110 |
| 39 | Assertion API | 50 | 7 | 7.1 | 0 | 49 |
| 40 | Code coverage control and API | 45 | 18 | 2.5 | 0 | 42 |

<a id="優先して見直す条項テスト1本規格のみ"></a>

## Priority queue: one test, standard only

These clauses have exactly one citing test, and that test has `:oracle: spec` alone. They are the first candidates for a second test or an independent oracle.

None.

<a id="章ごとのテストが1本の条項"></a>

## One-test clauses by chapter

| Chapter | Clauses |
| ---: | ---: |

<a id="規格だけを根拠とするテストしかない条項"></a>

## Clauses with only standard-only tests

These clauses are cited, but no release produces the expected output of any of their tests.

4.4.2.5, 6.6.4.1, 6.6.4.2, 6.6.8, 6.7.2, 6.7.3, 6.22.6, 7.3.2, 7.9.8, 8.26.4, 8.26.6.2, 8.30.1, 8.30.2, 8.30.3, 8.30.4, 8.30.5, 9.4.4, 11.9, 12.4.2.1, 12.4.2.2, 12.5.3.1, 12.5.3.2, 12.6.1, 12.6.2, 12.6.3, 15.5.4, 15.5.5.3, 16.4.3, 16.4.5, 16.8.2, 16.9.1, 16.9.2.1, 16.9.5, 16.9.6, 16.9.7, 16.9.8, 16.9.10, 16.9.11, 16.11, 16.12.4, 16.12.5, 16.12.10, 16.12.13, 16.12.17, 16.12.18, 16.12.19, 16.12.20, 16.12.22, 16.13.1, 16.13.2, 16.13.7, 16.14.6.1, 16.14.6.2, 16.14.6.3, 16.14.6.4, 16.17, 17.4, 17.7.2, 17.9, 19.4.1, 19.5.1.1, 19.5.5, 19.5.6, 19.5.7, 19.6.1.1, 19.6.1.3, 19.6.1.4, 19.6.2, 19.6.3, 19.9, 19.11.3, 20.12, 20.16.1, 20.16.2, 20.16.3, 20.16.4, 21.7.3.1, 21.7.3.2, 21.7.3.3, 21.7.3.4, 21.7.3.5, 21.7.3.6.1, 21.7.3.7, 21.7.4.1, 21.7.4.2, 21.7.4.3.1, 21.7.4.3.2, 22.11.1, 23.3.3.7.1, 23.3.3.7.2, 24.6, 25.3.2, 25.6, 25.7.4, 28.15.2, 28.16.2.1, 28.16.2.2, 30.7.3, 30.7.4.1, 30.7.4.2, 31.3.1, 31.3.2, 31.3.5, 31.4.1, 31.4.2, 31.4.5, 31.7, 31.8, 31.9.3, 32.2, 32.4.2, 32.4.3, 33.3.1.1, 33.3.2, 33.4.2, 33.5.4, 33.6.1, 33.8.1, 34.5.1.1, 34.5.2.1, 34.5.2.2, 34.5.5.1, 34.5.6.1, 34.5.7.1, 34.5.7.2, 34.5.8.1, 34.5.9.1, 34.5.10.1, 34.5.11.1, 34.5.12.1, 34.5.13.1, 34.5.14.1, 34.5.15.1, 34.5.16.1, 34.5.17.1, 34.5.18.1, 34.5.19.1, 34.5.20.1, 34.5.21.1, 34.5.22.1, 34.5.23.1, 34.5.24.1, 34.5.25.1, 34.5.26.1, 34.5.27.1, 34.5.28.1, 34.5.29.1, 34.5.30.1, 34.5.30.2, 34.5.31.1, 34.5.31.2, 34.5.32.1, 35.5.1.5, 36.8.1, 36.10.1, 36.10.3, 36.12.1, 36.12.2.1, 37.3.2, 37.3.4, 37.3.6, 37.3.8, 37.6, 37.7, 37.8, 37.9, 37.11, 37.13, 37.15, 37.18, 37.19, 37.20, 37.21, 37.22, 37.23, 37.24, 37.25, 37.26, 37.29, 37.30, 37.31, 37.32, 37.33, 37.34, 37.35, 37.36, 37.38, 37.40, 37.41, 37.44, 37.45, 37.46, 37.47, 37.48, 37.49, 37.50, 37.51, 37.52, 37.53, 37.54, 37.55, 37.56, 37.57, 37.58, 37.59, 37.60, 37.61, 37.62, 37.63, 37.64, 37.65, 37.66, 37.67, 37.68, 37.69, 37.70, 37.71, 37.72, 37.73, 37.74, 37.75, 37.76, 37.77, 37.78, 37.79, 37.80, 37.81, 37.82, 37.83, 37.84, 38.7, 38.9, 38.36.1.1, 38.36.1.2, 38.36.1.3, 39.3.1, 39.3.2, 39.4.1, 39.4.2.1, 39.5.1, 39.5.2, 39.5.3, 40.2.1, 40.2.2, 40.3.2.1, 40.3.2.2, 40.3.2.3, 40.3.2.4, 40.3.2.5, 40.5.2, 40.5.3

<a id="対象外の印が付いた引用条項"></a>

## Cited clauses with an out-of-scope tag

These clauses are cited by tests but carry a tag in `tools/clauses.txt` that says they are out of scope. Either the tag or the citation needs a review.

- `3.2`: tag `none`
- `3.3`: tag `none`
- `3.4`: tag `none`
- `3.5`: tag `none`
- `3.6`: tag `none`
- `3.7`: tag `none`
- `3.8`: tag `none`
- `3.9`: tag `none`
- `3.10`: tag `none`
- `3.11`: tag `none`
- `6.2`: tag `none`
- `6.15`: tag `none`
- `8.2`: tag `none`
- `8.3`: tag `none`
- `10.2`: tag `none`
- `11.6.2`: tag `none`
- `12.2`: tag `none`
- `12.3`: tag `none`
- `12.4.2.1`: tag `tool`
- `12.4.2.2`: tag `tool`
- `12.5.3.1`: tag `tool`
- `12.5.3.2`: tag `tool`
- `13.2`: tag `none`
- `14.2`: tag `none`
- `15.2`: tag `none`
- `16.2`: tag `none`
- `16.12.20`: tag `none`
- `16.12.21`: tag `none`
- `17.1`: tag `none`
- `17.9`: tag `none`
- `19.2`: tag `none`
- `19.6.1.1`: tag `none`
- `20.12`: tag `none`
- `21.7.1.5`: tag `dump`
- `21.7.3.1`: tag `dump`
- `21.7.3.2`: tag `dump`
- `21.7.3.3`: tag `dump`
- `21.7.3.4`: tag `dump`
- `21.7.3.5`: tag `dump`
- `21.7.3.6.1`: tag `dump`
- `21.7.3.7`: tag `dump`
- `21.7.4.1`: tag `dump`
- `21.7.4.2`: tag `dump`
- `21.7.4.3.1`: tag `dump`
- `21.7.4.3.2`: tag `dump`
- `22.2`: tag `none`
- `22.11.1`: tag `tool`
- `23.3.3.1`: tag `tool`
- `23.3.3.6`: tag `tool`
- `24.2`: tag `none`
- `25.2`: tag `none`
- `25.3.2`: tag `none`
- `25.7.4`: tag `none`
- `27.2`: tag `none`
- `29.2`: tag `none`
- `30.2`: tag `none`
- `30.7.2`: tag `tool`
- `30.7.3`: tag `tool`
- `31.2`: tag `none`
- `31.9.2`: tag `tool`
- `31.9.3`: tag `tool`
- `31.9.4`: tag `tool`
- `32.2`: tag `none`
- `33.2.1`: tag `tool`
- `33.3.1.1`: tag `tool`
- `33.3.2`: tag `tool`
- `33.3.3`: tag `tool`
- `33.5.1`: tag `tool`
- `33.5.2`: tag `tool`
- `33.5.4`: tag `tool`
- `33.6.1`: tag `tool`
- `33.8.1`: tag `tool`
- `34.2`: tag `excluded`
- `34.3.1`: tag `excluded`
- `34.3.2`: tag `excluded`
- `34.4`: tag `excluded`
- `34.5.1.1`: tag `excluded`
- `34.5.1.2`: tag `excluded`
- `34.5.2.1`: tag `excluded`
- `34.5.2.2`: tag `excluded`
- `34.5.3.1`: tag `excluded`
- `34.5.3.2`: tag `excluded`
- `34.5.4.1`: tag `excluded`
- `34.5.4.2`: tag `excluded`
- `34.5.5.1`: tag `excluded`
- `34.5.5.2`: tag `excluded`
- `34.5.6.1`: tag `excluded`
- `34.5.6.2`: tag `excluded`
- `34.5.7.1`: tag `excluded`
- `34.5.7.2`: tag `excluded`
- `34.5.8.1`: tag `excluded`
- `34.5.8.2`: tag `excluded`
- `34.5.9.1`: tag `excluded`
- `34.5.9.2`: tag `excluded`
- `34.5.10.1`: tag `excluded`
- `34.5.10.2`: tag `excluded`
- `34.5.11.1`: tag `excluded`
- `34.5.11.2`: tag `excluded`
- `34.5.12.1`: tag `excluded`
- `34.5.12.2`: tag `excluded`
- `34.5.13.1`: tag `excluded`
- `34.5.13.2`: tag `excluded`
- `34.5.14.1`: tag `excluded`
- `34.5.14.2`: tag `excluded`
- `34.5.15.1`: tag `excluded`
- `34.5.15.2`: tag `excluded`
- `34.5.16.1`: tag `excluded`
- `34.5.16.2`: tag `excluded`
- `34.5.17.1`: tag `excluded`
- `34.5.17.2`: tag `excluded`
- `34.5.18.1`: tag `excluded`
- `34.5.18.2`: tag `excluded`
- `34.5.19.1`: tag `excluded`
- `34.5.19.2`: tag `excluded`
- `34.5.20.1`: tag `excluded`
- `34.5.20.2`: tag `excluded`
- `34.5.21.1`: tag `excluded`
- `34.5.21.2`: tag `excluded`
- `34.5.22.1`: tag `excluded`
- `34.5.22.2`: tag `excluded`
- `34.5.23.1`: tag `excluded`
- `34.5.23.2`: tag `excluded`
- `34.5.24.1`: tag `excluded`
- `34.5.24.2`: tag `excluded`
- `34.5.25.1`: tag `excluded`
- `34.5.25.2`: tag `excluded`
- `34.5.26.1`: tag `excluded`
- `34.5.26.2`: tag `excluded`
- `34.5.27.1`: tag `excluded`
- `34.5.27.2`: tag `excluded`
- `34.5.28.1`: tag `excluded`
- `34.5.28.2`: tag `excluded`
- `34.5.29.1`: tag `excluded`
- `34.5.29.2`: tag `excluded`
- `34.5.30.1`: tag `excluded`
- `34.5.30.2`: tag `excluded`
- `34.5.31.1`: tag `excluded`
- `34.5.31.2`: tag `excluded`
- `34.5.32.1`: tag `excluded`
- `35.2.2.1`: tag `none`
- `35.3.1`: tag `none`
- `35.3.2`: tag `none`
- `35.5.1.6`: tag `none`
- `36.2`: tag `none`
- `36.6`: tag `none`
- `36.7`: tag `none`
- `36.11`: tag `none`
- `36.12.1`: tag `tool`
- `36.12.2.1`: tag `tool`
- `36.12.3`: tag `tool`
- `37.4.2`: tag `none`
- `37.4.3`: tag `none`
- `37.45`: tag `tool`
- `38.1`: tag `none`
- `38.7`: tag `none`
- `38.9`: tag `tool`

<a id="toolsclausestxtにない引用条項"></a>

## Cited clauses missing from tools/clauses.txt

6.3.3, 6.12.2

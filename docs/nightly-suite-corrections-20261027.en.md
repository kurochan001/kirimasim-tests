<a id="nightlyのdifferから見つかったテスト側の問題の修正"></a>

# Fixed test-side issues found in Nightly's Difference

[English](nightly-suite-corrections-20261027.en.md) / [日本語](nightly-suite-corrections-20261027.md)

[Nightly run 40333187203](https://github.com/kurochan001/kirimasim-tests/actions/runs/40333187203) in 2026-10-26 classified 174 tests as Differ on suite `5fb3c45d` and kirimasim `5563871fcd96`. Among these, checked 27 tests with diagnostic-location mismatches and 1 positive packed union tests against the standard, and fixed 28 tests in total. This is a fix based on user instructions from 2026-10-27.

The base of the correction is the suite `9783d9fd`. The aggregate before/after comparison uses this snapshot and excludes additions from concurrent requirement-mapping work.

Differ is the number of failing tests. This includes output differences, compile failures, acceptance of standard-violating code, and diagnostic/exit-code differences; it is not a count of independent bugs. This investigation does not establish correctness of all 174 tests.

<a id="設計自体を直した4本"></a>

## 4 tests whose designs were corrected

|Test|Problems and corrections|Standard rationale|
| --- | --- | --- |
| `ch7/test_packed_struct_union_dimensions_and_rand_member` |Ordinary `union packed` members were 6 and 3 bits wide. Both were made 6 bits wide. The `matches` display argument is also changed to display the bit determined by the `if` condition. Expected-output `packed 12 12 5a9 56a` and `tag 1 rand 1 3` are unchanged|7.3.1, 12.6.2, and Annex A syntax|
| `ch20/test_illegal_bits_function_dynamic_return` |The syntax `function int[] f()` was rejected first, and it did not reach the intended violation of `$bits(f())`. Applied typedef to the dynamic-array type to make the function declaration standard-compliant. Restrict diagnostics to the `$bits` line|20.6.2, the syntax of the return type of the function|
| `ch33/test_illegal_config_design_is_config` |The top selection error occurred because there was no information to select objects from multiple configs. Check for violations using config as a design cell by specifying `:top_module: cfgdc`| 33.4.1.1 |
| `ch33/test_illegal_config_instance_inside_other_config` |Specify `:top_module: cfgio` similarly. Checks for violations of other configs applying instance rules to the specified hierarchy| 33.4.2 |

The existing `ch7/test_illegal_hard_packed_union_sizes` continues to check rejection of unequal member widths in a packed union. This is also included in the rerun contrast.

<a id="診断を検査する位置と内容"></a>

## The location and content of the diagnostic examination.

Diagnostics for standard-violating code may identify the declaration or expanded body, as well as the use site causing the violation. The following 24 tests are accepted with the associated location explicitly stated. The diagnostic contents showing the intentional violation are also checked, and success by syntax non-compliance or unrelated errors is prevented.

|Target|Test count|Accepted locations and contents|
| --- | ---: | --- |
| final deferred assertion | 1 |Writes in the Postponed region from an action call or a called task|
| `$inferred_clock` | 1 |Default actual argument, clock usage site, or assertion instance. Diagnosis of unresolved clock|
|Negation and strong operators in recursive properties| 7 |The violating use site, or the recursive body at the expansion target. Diagnosis pointing to a prohibited operation on a recursive property|
|Conformance after expanding a property actual| 1 |The instance or expansion target. Diagnostic that a property expression cannot be used as a sequence|
|local output of sequence| 1 |Formal argument, sequence body, or instance. Diagnostic identifying an unassigned value|
|PLA memory-index direction| 1 |The memory declaration or system-task call. Diagnostics identifying the ascending-order requirement|
|ANSI / non-ANSI port re-declaration| 4 |The original port declaration or re-declaration. Diagnosis of duplicate declarations|
|Number and type of modport prototypes| 2 |The prototype or corresponding function declaration. Number and type of arguments not matching|
|package import conflict| 3 |The violating declaration/import, or the earlier reference importing the name. Import-conflict diagnostics|
|Missing `endtable` in UDP| 1 |The next `endprimitive`, or the end of the preceding table. The latter is restricted to diagnostics requiring `endtable`|
|Fork-join in function / join_any| 2 |`fork`, or the closing `join` / `join_any`. Diagnosis of time-control prohibition|
|Total| **24** ||

The remaining 3 tests that violate the standard are the 1 function-declaration tests and 2 config-selection tests in the preceding section. Metadata checks now also permit declared configs as `:top_module:`, while still rejecting nonexistent names. There is no change to accept a config selection error as a diagnosis of an intentional non-conformity.

Some regexes also check English concept words to connect locations with relevant error content. The diagnostic text of a specific tool is not fixed, but when adding a synonymous diagnosis of another tool, it is necessary to judge by comparing with the standard.

<a id="誤ったoracle認定の訂正"></a>

## Correcting erroneous oracle certification

For the 8 tests involving recursive properties and related constructs, 1 local-output tests, and 2 modport-prototype tests, Icarus 13.0—described as unsupported in body comments—was registered in `:oracle:`. Raw diagnostics showed that unsupported-syntax errors and their cascading errors had matched the location-only check. `iverilog@13.0` was withdrawn from 11 tests in total; `spec` was retained.

Thus, the initial machine-generated count stating that “83 of 174 tests succeeded with Icarus or Verilator” also includes false positives. This 83 tests is not treated as an independently verified number of items on the standard.

26 requirement mappings and 6 deferred decisions were rechecked, and input hashes, diagnostic rationales and review records were updated. Baseline hashes for 8 composite-evidence entries were also updated with reasons. No requirements were removed; pass conditions and group membership are unchanged.

Recalculation retained the 12,319-requirement denominator and 10,209 design mappings, while execution confirmation increased from 5,639 to 5,634 requirements (45.734232%). This follows from not using revoked approvals or successes on old inputs as current execution evidence.

<a id="mainへの統合後の集計"></a>

## Aggregates after integration into main

Integration into main `6094cbaf` preserved 148 tests and requirement mappings added in parallel. No duplicate files with the test object. After integration: 7,292 tests in total, a denominator of 12,319 requirements, and 10,434 design mappings. The 5,727 item before the modification of main is executed, and the 5,722 item (46.448575%) after the modification.

The content of the requirement, the set of corresponding tests, and the membership of the compound proof are unchanged from main. Updated baselines comprise 8 entries bound to diagnostics/input hashes and their update reasons. All 116 items in the rerun of the 4 runs below also match the input runner hash after the merger.

<a id="検証結果と残る差分"></a>

## Verification results and remaining differences

Reran a total of 29 tests: 28 modified tests and 1 existing packed union negative tests.

|Execution environment|Result|Evidence|
| --- | --- | --- |
| Icarus Verilog 13.0 | 9 pass、20 known、0 fail | [JSON](../coverage/results/nightly-suite-corrections-20261027-icarus13.json) |
| Verilator 5.052、seed 1 | 8 pass、21 known、0 fail | [JSON](../coverage/results/nightly-suite-corrections-20261027-verilator-seed1.json) |
| Verilator 5.052、seed 73 | 8 pass、21 known、0 fail | [JSON](../coverage/results/nightly-suite-corrections-20261027-verilator-seed73.json) |
|Local kirimasim `a2aa75737147`| 27 pass、1 unsupported、1 fail | [JSON](../coverage/results/nightly-suite-corrections-20261027-kirimasim.json) |

The 27 successful kirimasim tests include 26 tests requiring correction and 1 existing negative tests. After unrelated compilation errors were removed, the positive packed union test reports the tagged union itself as unsupported. The `$bits` negative test, corrected to use the return type specified by the standard, is still accepted by kirimasim, Icarus, and Verilator, leaving the intended violation undetected. Tests were not weakened to obtain success.

This local kirimasim is a different commit from Nightly. Determine how much the 174 count decreases by running the next Nightly under the same conditions. Success on standard-violating code under kirimasim is not approved as a fixed-version oracle, so the 27 passes above are not directly added to execution verification coverage.

Then built main `f0799b3c04d4` of kirimasim, confirmed the failure to detect `$bits` with an independent minimal example using a standard-compliant function declaration, and filed [Bug Issue #53](https://github.com/kurochan001/kirimasim/issues/53). Separate issues from the same Nightly investigation, confirmed against the standard and minimal examples, are recorded separately in [foreach break # 52](https://github.com/kurochan001/kirimasim/issues/52), [Priority of conditional operators and logical implications #54](https://github.com/kurochan001/kirimasim/issues/54), [Empty named port connection #55](https://github.com/kurochan001/kirimasim/issues/55), [Extension of unsized X/Z literals #56](https://github.com/kurochan001/kirimasim/issues/56), and [Atoreal's scan # 57](https://github.com/kurochan001/kirimasim/issues/57). Both are labeled `bug` and do not contain any copying of the specification text or code from other projects.

[Diagnostic fixtures](../tools/fixtures/nightly_diagnostics_20261027.json) and [Regression check of 6](../tools/test_nightly_diagnostics.py) include verified diagnostics, unsupported-feature errors from fixed-version tools, and synthesized unrelated/unsupported errors. Only the correct diagnosis example of `$bits` is listed as a synthesis example, not a real measurement of the solver or simulator.

```sh
python3 -m unittest discover -s tools -p 'test_nightly_diagnostics.py'
python3 tools/suite_stats.py --check
python3 tools/suite_catalog.py --check
python3 tools/coverage_depth.py --check --minimum-tests 2
python3 tools/behavior_coverage.py --check --require-source-reviewed
python3 tools/requirement_matching.py --check
```

All 205 existing unit tests and 6 additional regression checks passed. README Consistency checks of aggregation, generation test, catalog, number of tests by article, metadata, operation coverage rate, and requirements matching are also successful. Formal evidence for the base 40 models and 111 added cases still matches current sources; solvers were not rerun.

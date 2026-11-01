<a id="既存テストの要求照合コンパイラ指令2026-10-23"></a>

# Requirement matching for existing tests: compiler directives (2026-10-23)

[English](existing-test-matching-preprocessor-20261023.en.md) / [日本語](existing-test-matching-preprocessor-20261023.md)

> Counts, percentages, and pending statuses in this document record their respective work dates.
> The current value is [Aggregated Summary](behavior-coverage-summary.en.md); the approval history for the denominator and interpretations is in
> See [Results of requirement extraction](requirement-extraction.en.md).

[Current coverage](behavior-coverage-summary.en.md) / [Comparison ledger for all tests](test-requirement-matching.en.md) / [Mapping progress and findings](existing-test-matching-review-20261022.en.md)

Reviewed 22.2–22.14.9 in the provided IEEE 1800-2023, along with related 3.14.2.1–3.14.2.3 and 5.6.4. Read stimulus and expected results for 48 tests in Chapter 22 and 7 tests in other chapters concerning time settings, macros, and cell tagging. Also checked included declarations/macros and the C sources for VPI in 2 tests reading cell state. 55 The following is a record of the scope of the confirmed observation, and it is not treated as the completion of the inspection of all functions of the tests.

<a id="今回の進捗"></a>

## Progress in this round

- Registered bindings: 943 → 975 tests (32 added, 3,938 total).
- Mapped requirements: 792 → 810 rows (18 added). Added 85 mapping-evidence entries from 38 tests.
- Execution-verified requirements: 700 → 718 rows (18 added).
- Provisional requirement coverage (test design): 6.58% (810/12,319).
- The provisional execution confirmation rate is 5.83% ( 718/12,319 ).
- Finalized values: both design and execution remain unfinalized. Denominator approval, deduplication, and resolution of pending interpretations remain outstanding.
- The test of the unregistered response to the requirement: 2,963 tests. Mappings based on verification content for every case remain incomplete.

12,319 requirement definitions, the denominator identifier, and standard-material audit results are unchanged. Previous mappings, set evidence, and pending assessments are retained. Existing test stimuli, expected values, metadata, and runners are unchanged. No new tests were added either. Mappings were made by AI and have not been verified by an independent person.

<a id="採用した観測"></a>

## Observations used

[test_include_file_declarations.sv](../tests/ch22/test_include_file_declarations.sv) inserts typedef and a function from an include into the module, then observes the member's 3/10 and function result 13. [test_include_from_incdirs.sv](../tests/ch22/test_include_from_incdirs.sv) checks value 12 and strings from files resolved through search directories passed to the runner. Do not infer content substitution merely from names or include statements.

[test_directive_effect_from_read_point.sv](../tests/ch5/test_directive_effect_from_read_point.sv) uses LEVEL defined inside the first module in the next module too. In a single run, observe preservation of value 3, 5 after redefinition, and undefined status after undef, as 3/5/0. This does not establish that macros cannot leak between separate compilation units.

In [test_macro_concat.sv](../tests/ch22/test_macro_concat.sv), used multiline expansion invoking DECLARE_SIGNAL. The MAKE_NAME definition-only is not registered as a validation of the identifier link. [test_macro_args.sv](../tests/ch22/test_macro_args.sv) distinguishes the default of SCALE (5) from the explicit value of SCALE (5,3).

[test_vpi_celldefine.sv](../tests/ch22/test_vpi_celldefine.sv) and [C helper](../tests/ch22/test_vpi_celldefine.c) read vpiCellInstance and use 1/0/1/0 to verify 2 cell activations and deactivation by endcelldefine/resetall. Cell tags are not inferred from logical signal values alone.

[test_begin_keywords_versions.sv](../tests/ch22/test_begin_keywords_versions.sv) registered 3 permissions to individual requirements, making config/cell/design the identifier in noconfig. Do not treat this as verification of every keyword set or restoration from nesting.

<a id="追加した集合証拠"></a>

## Added set-level evidence

Added set-level evidence to 5 requirement rows, bringing the total to 50. Count whole-row execution success only when all members succeed on the same simulator in the same run.

- Empty macros: `test_ieee_ch22_directives_edge`'s defined status and actual empty expansion in `test_directive_corner_cases`. Because the latter alone could pass when undefined macros become empty with a warning, require both.
- Conditional placement: an include outside the module in `test_define_selects_included_file`, a declaration region in `test_compiler_directives`, and procedural statements in `test_ifdef_nested`.
- undefineall: inside the module in `test_undefineall` and outside the module in `test_undefineall_clears_nested_macro_expansion`.
- timescale: relative unit scales in `test_timescale_child_units_in_parent`, rounding in `test_timescale_delay_rounded_to_precision`, replacement in `test_timescale_replaced_by_next`, and precedence of the explicit local setting in `test_timeunit_with_precision`.
- Optional pairing in unconnected_drive: explicit pairing in `test_unconnected_drive`, and direct switching from pull1 to pull0 in `test_unconnected_drive_instances_restore`.

<a id="実行証跡と対照確認"></a>

## Execution evidence and control checks

The original tests' full suite was not rerun here. Checked current input SHA-256 and runner identifiers against [The saved experimental results of Icarus and 13.0 are shown in the table below.](../coverage/results/icarus.json), [The saved experimental results of Verilator and 5.052 are shown in the table below.](../coverage/results/verilator.json), and registered partial runs. All 18 new rows have valid recorded pass results. Known/unsupported/stale evidence does not count as success; partial successes from separate runs are not combined into set evidence.

To check distinguishing power without modifying original files, compiled and executed 5 temporary source variants.

- All original expected output still matched with Verilator for 3 mutation types: removing the MULTI_LINE call, changing \`V inside the literal to same-length 22, and changing only kw_2001_after to 1364-1995. These demonstrate, respectively, unobserved multiline handling, length-only comparison, and insufficient identification of the restored keyword set.
- Changing default2 in SCALE to 3 produced the FAIL line under Verilator.
- Changing the first addition 10 in conditional to 00 removed the final PASS on both runners, Icarus 13.0 and Verilator 5.052. Verified that this assertion distinguishes the behavior in the 2 environment.

The variation of 3 type that passed is a lack of observation of the test and not a violation of the simulator's specification. Temporary-variant results are not registered as coverage execution evidence.

<a id="m52ラベルと定義だけでは機能を確認できない"></a>

## M52: labels and definitions alone do not verify functionality

REG_NAME / STRINGIFY in `test_compiler_directives_comprehensive`, CONCAT in `test_macro_args`, and STR_MACRO / CONCAT_MACRO in `test_ieee_ch22_directives_edge` are unused. The token-concatenation concept in `test_directive_corner_cases` directly reads var1. The recursion-prevention test likewise uses no recursive macro and displays fixed PASS. timescale occurs after endmodule, with no delay observation. The relevant label is not reused as mapping evidence.

<a id="m53値内容を確認しない成功表示"></a>

## M53: success display without checking values or contents

MULTI_LINE in `test_directive_corner_cases` only writes a local temporary. __FILE__/__LINE__ also only checks for non-empty and positive values. `test_macro_redefine_string_literal` only checks the length of the literal 14. Based on these controls, kept multiline, exact-position, and nonreplacement-inside-ordinary-literals requirements pending. Actual distinguishable ordinary-macro expansion in the same file is accepted as separate evidence.

<a id="m54直後の再定義がundefの欠落を隠す"></a>

## M54: immediate redefinition conceals missing undef

Immediately after undef, `test_compiler_directives_comprehensive` defines DATA_WIDTH as 16. This is not a check for undef alone, because ignoring undef will overwrite the latest definition to 16. Retain existing mappings for dedicated tests observing undefined status with ifdef after undef and before redefinition.

<a id="m55単純な入れ子では展開時期や再置換を区別できない"></a>

## M55: simple nesting cannot distinguish expansion timing or resubstitution

Defining OUTER after INNER and reading without redefinition produces the same result even with premature expansion at definition time. Nested ADD using only numeric constants also cannot distinguish erroneous resubstitution of a same-named formal introduced from inside. STRINGIFY(hello_world) checks formal substitution into quotes, not expansion of embedded macros within quotes. The broad requirement line that includes these is not addressed as such.

<a id="m56正常系テストと規格違反テストが混在する要求単位"></a>

## M56: requirement units mixing positive and standard-violation tests

Some requirement-row kinds differ from test kinds, including the default wire / reset versus rejection with none in default_nettype, normal behavior versus prohibited placement in unconnected_drive, and positive keyword-set tests versus rejection of reserved identifiers. Even valid standard-violation tests for a prohibited condition do not transfer success to other conditions on the same row. General resetall rules also cannot establish retention of macros and related settings from cell deactivation or implicit wire alone. Did not increase mappings by changing requirement definitions/kinds; recorded remaining cleanup work.

<a id="m57部分的な境界復元を全条件へ広げない"></a>

## M57: do not generalize partial boundary/restoration checks to all conditions

2 hierarchyinclude does not check for the guarantee of the minimum 15 hierarchy. A design using the same include in helper/main passes whether they share a compilation unit or use separate units, so it does not verify unit separation. The 500/501 display in line is enabled, but the inclusion position is not verified until save/restore or resetall. Also avoid counting restoration by nounconnected_drive as a resetall effect.

<a id="m58keywordの復元先を区別する入力が必要"></a>

## M58: inputs must distinguish keyword restoration targets

kw_2001_after in `test_begin_keywords_versions` uses logic/uwire as identifiers. Both words are nonkeywords in both 1364-1995/2001 sets, so incorrectly restoring 1995 gives the same output. The actual specification also contains no 1800-2012/2017; the 2023 portion is a fixed done display. This does not establish complete coverage of all 9 specifications, keyword sets, or stack restoration. Accepted the 3 config/cell/design words excluded by noconfig individually because their values are actually displayed.

<a id="保留台帳と管理ツールの検査"></a>

## Pending-ledger and management-tool checks

Added 41 judgments to [Judgment table by range](../coverage/test-matching-reviews.json). The ledger's scope increased from 317 to 345 files, and its decisions from 424 to 465. Preserved existing assessments and attached this work's date/reviewer to added assessments of the same files. This count is neither a complete-file-review count nor the requirement-coverage numerator.

The 74 test of the management tool, the hash of the specification document, the consistency of the compliance, judgment, and execution evidence, and the consistency of the catalog, statistics, depth, product, and metadata were examined. Also mechanically verified preservation of existing requirement definitions, mappings, set evidence, pending assessments, and test inputs.

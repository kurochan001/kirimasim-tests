<a id="全テスト内容レビュー2026-10-22"></a>

# Review of all test contents (2026-10-22)

[English](test-content-review-20261022.en.md) / [日本語](test-content-review-20261022.md)

> The following review results apply to the listed target commits.
> For subsequent fixes and remaining work, see [Follow-up review](test-content-review-followup-20261022.en.md),
> See [Nightly derived correction](nightly-suite-corrections-20261027.en.md) and [Test-side fixes](test-side-fixes-20261028.en.md).

<a id="結果"></a>

## Result

Identified 12 groups of problems requiring fixes in 24 distinct tests. Issues include standard-invalid code treated as positive cases, expected output inconsistent with stimuli, C code failing even with conforming VPI implementations, and judgments accepting API failure as success. This includes problems that are not found by matching with existing oracle alone.

In this review, the test body, expected value, and metadata are not changed.

<a id="対象と方法"></a>

## Scope and method

- Commit: `c118d54d6be3e9bbc85ebf60c9b545caf4649739`. We did not limit ourselves to the uncommitted differences, but we also examined all 3,801 tests of `tests/`.
- Breakdown: 3,629 positive cases and 172 negative cases requiring errors. The generated test 812 is included.
- 2,526 cases use Icarus as an oracle and 944 use Verilator (171 belong to both); 502 rely on the standard alone.
- Checked the metadata, expected output, additional sources, 208 C files for DPI / VPI, and the generator's expected-value model and execution/evaluation procedures.
- Performed syntax, semantic, and procedural analysis of every case in SystemVerilog 2023 mode (pyslang 12.0.0, including additional sources, includes, defines, and top specifications). We also performed syntax checks with warnings for all C code 208 files.
- In addition to sites with diagnostics, manual comparison against the standard focused on tests using only the standard as an oracle, scheduling, 4-state values, types/widths/signedness, assertions, checkers, timing checks, SDF, DPI / VPI, and coverage.
- Diagnostics were not automatically treated as defects. The findings below are supported by the standard text, derivation from stimulus or small reproductions. The standard compliance of all cases is not formally proven.

The primary sources are the designated [IEEE Std 1800-2023 PDF](../../IEEE_1800-2023_SystemVerilog/IEEE_Std_1800-2023_SystemVerilog.pdf) and [Extracted text from the same PDF](../../IEEE_1800-2023_SystemVerilog/out/lrm_pdftotext_layout.txt), both in the materials directory outside the repository. The following clause numbers apply to this edition. Page numbers shown alongside citations are printed page numbers.

<a id="指摘"></a>

## Observations

<a id="f01-procedural-assigndeassign-の左辺にpart-selectを使っている"></a>

### F01 : using part-select on the left side of procedural assign/deassign

Scope: [test_sched_procedural_assign_part_select.sv 28 at that time](https://github.com/kurochan001/kirimasim-tests/blob/a77a826cd89ad478617ac82b18be9df7d99e3571/tests/ch4/test_sched_procedural_assign_part_select.sv#L28), line 36 in the same source. Because the code was removed by the fix, links point to the commit at the time of the finding.

We treat `assign q[3:0] = d[3:0]` and `deassign q[3:0]` as the correct operation according to the specification, and we expect partial overwrite suppression. However, 10.6.1 (p. 257) bit-select/part-select is not allowed on the left side of the variable of the procedural continuous assignment. This is neither an ordinary continuous assignment to a net nor force/release.

Impact: requires as a positive case code that a conforming implementation rejects. Icarus 13.0 and Verilator 5.052 match the expected values, but this constraint remains unchanged. In pyslang, the left‐side error was detected.

Amendment: Make the partial selection a negative example to be rejected. To test override suppression as positive behavior, use assign/deassign on an independent whole variable and update the description and expected values.

<a id="f02-wildcard-importの候補を実際にimportされた名前として再exportしている"></a>

### F02 : re-exporting wildcard import candidates as actual imported names

Scope:

- [test_package_export_all.sv:28](../tests/ch26/test_package_export_all.sv#L28)
- [test_package_export_named_wildcard.sv:35](../tests/ch26/test_package_export_named_wildcard.sv#L35)

The former `mid_pkg` refers only to `import base_pkg::*; export *::*;`, and does not refer to `base_x` or `twice`. The latter `ew_mid` also performs `export ew_g::*;` without referencing `ga`, `gb`, or `gsum`.

26.6 （p. Wildcard export in 815) applies to actually imported declarations and does not expose unreferenced import candidates. The export with a name has a rule that generates an import, but you cannot apply that rule to a wildcard export. Therefore code using these names in downstream modules is invalid. pyslang also reports an undeclared name; acceptance by Verilator does not establish conformance.

Proposed fix: explicitly import required names in the exporting package, then test wildcard export. Also provide a separate negative case showing that an unreferenced candidate is not re-exported. Also change the description claiming 26.5 specifies export to 26.6.

<a id="f03-outputで駆動される接続先変数に宣言時の手続き的初期化がある"></a>

### F03: The destination variable driven by output has a declaration-time procedural initialization.

Scope:

- [test_timeunit_program.sv:33](../tests/ch3/test_timeunit_program.sv#L33)
- [test_program_clocking_output.sv:36](../tests/ch24/test_program_clocking_output.sv#L36)
- [test_program_clocking_default_skew.sv:43](../tests/ch24/test_program_clocking_default_skew.sv#L43)
- [test_checker_output_actual.sv:33](../tests/ch17/test_checker_output_actual.sv#L33)

Variables initialized with `logic q = 0` or `logic [1:0] qv = 0` are also connected to program/checker outputs. 6.5 （pp. 90–91) also counts declaration initialization as procedural assignment, rejecting its mixture with implicit continuous assignments from output connections. Continuous assignment from checker outputs to actual arguments is also explicit in 17.3.

Impact: a positive test combines prohibited driving methods. In particular, for the 2 program clocking-output cases, initializing the receiver with 0 does not set the uninitialized output formal to 0, so the expected value before the first drive is also invalid. pyslang also diagnoses the mixed assignments.

Proposed fix: remove destination initialization and provide required initial values at the driver. In the checker case, the internal `delay` is already initialized to 0, so the receiving side does not need initialization for the observed `qv[1]`.

<a id="f04-programの終了でモジュール側の観測より先にシミュレーションが終わる"></a>

### F04 : program ends, simulation ends before module side observation

Scope:

- [test_timeunit_program.sv:27](../tests/ch3/test_timeunit_program.sv#L27)
- [test_coverage_control_program_scope.sv:24](../tests/ch40/test_coverage_control_program_scope.sv#L24)

24.3 （p. 776) specifies that when programs have initial blocks, simulation ends through implicit `$finish` after all threads originating from all program initial blocks terminate. This rule does not wait for remaining waiting threads in modules.

In the former, the program's `#1` is 10 ns, so the program ends at 10 ns before reaching the module's `$display` at 10.5 ns. In the latter case, the program ends at time 2, so the module never reaches its coverage query at time 5.

Amendment: To put a procedure to survive until the necessary observation in the program, or to perform the observation itself in the program. The former also requires correcting F03.

<a id="f05-予約語-before-を変数名にしている"></a>

### F05: uses reserved word `before` as a variable name

Scope: [test_coverage_save_after_stop.sv:25](../tests/ch40/test_coverage_save_after_stop.sv#L25), lines 33 and 39 in the same file.

`before` in `int stopped, before, after, saved, merged;` is a SystemVerilog reserved word in 5.6 and Annex B. Because it is not an escaped identifier either, it causes a syntax error even in an implementation supporting coverage API. The syntax diagnosis of pyslang and Verilator also confirms this.

Proposed fix: change to `value_before` or a similar form. Distinguish inability to execute due to unsupported API from syntax errors in the source itself.

<a id="f06-クロックを決定できない-expect-がある"></a>

### F06: contains `expect` whose clock cannot be determined

Scope: [test_vpi_statement_control_kinds.sv:38](../tests/ch37/test_vpi_statement_control_kinds.sv#L38)。

`expect (en);` has no explicit clock, no default clocking, and no clock that can be inferred from the procedural context. The expect property following 16.15(f), 16.17 requires a single leading clock. `expect` is not an immediate assertion.

Impact: positive source for inspecting VPI objects becomes invalid. Never calling the task does not waive clock-resolution constraints. pyslang procedural analysis also reports the missing clock.

Amendment: Give an explicit clock, for example `expect (@(posedge en) en);`. This task is not called, so you can still prepare the expect object without generating an execution.

<a id="f07-checker-2が失敗するクロックエッジが刺激に存在しない"></a>

### F07: the stimulus lacks the clock edge at which checker 2 would fail

Scope: [test_checker_package_context.sv:64](../tests/ch17/test_checker_package_context.sv#L64)、 [Expected output](../tests/ch17/test_checker_package_context.expected)。

posedge of `fast_clk` is 6, 18, 30, 42, and 54. `fast_ok` is 0 only from time 31 inclusive to 40 exclusive, so no posedge samples 0. Nevertheless, the expected output requires `checker 2 at 42: sig low`.

According to 16.5.1, 17.3, and 17.4, `fast_ok` is already 1 at 42, so this failure message does not appear. The reset deassertion time 24 does not change this. The checker 1 failure at time 15 agrees with the stimulus.

Proposed correction: if 42 is intended to observe checker 2 failing, move the return of `fast_ok` to 1 until after 42. If the stimulus is to be maintained in the status quo, the line of the checker 2 in the expected output is deleted.

<a id="f08-vpi_get_str-の共有一時バッファを複数の文字列として保持している"></a>

### F08: The temporary buffer of `vpi_get_str()` is kept as multiple strings.

Target C files (each affects the same-named SV test):

- [test_vpi_module_binding_properties.c:27](../tests/ch33/test_vpi_module_binding_properties.c#L27)
- [test_vpi_assertion_objects.c:82](../tests/ch37/test_vpi_assertion_objects.c#L82) (same as 110 and later)
- [test_vpi_task_function_properties.c:65](../tests/ch37/test_vpi_task_function_properties.c#L65)
- [test_vpi_ref_obj_actual.c:44](../tests/ch37/test_vpi_ref_obj_actual.c#L44)
- [test_vpi_io_decl_ref_objs.c:55](../tests/ch37/test_vpi_io_decl_ref_objs.c#L55) (same as 116 and later)
- [test_vpi_virtual_interface_vars.c:44](../tests/ch37/test_vpi_virtual_interface_vars.c#L44)
- [test_vpi_iterators_time_queue_events.c:177](../tests/ch37/test_vpi_iterators_time_queue_events.c#L177)
- [test_vpi_nettype_declarations.c:44](../tests/ch37/test_vpi_nettype_declarations.c#L44)
- [test_vpi_typespec_relations.c:142](../tests/ch37/test_vpi_typespec_relations.c#L142)

38.11 （p. 1097 specifies that `vpi_get_str()` returns a pointer into a temporary buffer shared by all calls, and instructs callers to copy it if it must survive a later call. The above cases either save multiple returned pointers before using them or make multiple calls within the arguments of the same `printf`-family call. The `str()` and `name_of()` wrappers do not copy either. Fixing C/C++ argument evaluation order does not resolve buffer overwriting.

For example, the first file retrieves name, library, cell, and config before comparing name. The name can already be overwritten in the last config string, so the correctly existing `u` is lost. A reproduction that included the original C file unchanged and connected a VPI stub using 1 shared buffer(s) for 4 properties produced ** `u not found` ** instead of the expected 3 line.

Impact: Incorrectly failing the VPI implementation that reuses the temporary buffer according to the specification. A particular implementation returning stable separate buffers may conceal the issue.

Proposed fix: copy each `vpi_get_str()` result into owned storage before the next call, and compare/format only the copied strings. Do not pass multiple borrowed results into 1 formatted-output call(s).

<a id="f09-再入するdpi-exported-taskの引数がstaticで共有される"></a>

### F09 : Re-enter DPI exported task arguments are shared static

Scope: [test_dpi_import_task_reentrant_wait.sv:35](../tests/ch35/test_dpi_import_task_reentrant_wait.sv#L35)。

`task sv_wait_level(input int n); wait (level >= n); endtask` is a static task in a module, so concurrent calls share argument `n` (13.3.1, 13.3.2). 35.5.1.5, which permits reentry of a DPI imported task, does not automatically make the exported SV task automatic.

`c_visit(1)` and `c_visit(2)`, starting at time 0, overwrite the same `n` with 1 or 2. Therefore, the expectation of returning at the individual times 5 and 10 is not guaranteed. In a reproduction starting the same task from pure SV, with call 1 at time 0 and call 2 at time 1, confirmed that both return at time 10 on Icarus 13.0.

Amendment: `task automatic sv_wait_level(input int n);`. This preserves the original purpose: sharing C-side static variables while keeping SV-side wait conditions independent.

<a id="f10-setup違反をクロックより前のデータ変更時刻で報告するとしている"></a>

### F10: expects setup violations to be reported at the data-change time before the clock

Scope: [test_sdf_separate_setup_hold.expected:1](../tests/ch32/test_sdf_separate_setup_hold.expected#L1)、 [Source description and stimulus](../tests/ch32/test_sdf_separate_setup_hold.sv#L13)。

In SDF, set the setup limit to 4; data occurs at time 7, and the reference event posedge clk occurs at time 10. 31.3.1 、Table 31-1 （p. In the case of the 898, the data event is a timestamp event and the reference event is a timecheck event, so the time 10 is used to judge the violation. Expecting the notifier to change at time 7, before the future reference event has occurred, is incorrect. SDF changes limits; it does not reverse the roles of timing-check events (32.4.2).

Proposed fix: change the first line to `10: setup=1 hold=0` and correct the comment describing time 7 as the setup-violation reporting time. The hold violation and the final notifier value of the time 12 remain unchanged by this fix.

<a id="f11-recremのイベント順序と独立したremoval-checkへの注釈の期待が誤っている"></a>

### F11: incorrect RECREM event ordering and expected annotation of an independent removal check

Scope: [test_sdf_recrem_limits.sv:13](../tests/ch32/test_sdf_recrem_limits.sv#L13), lines 27–28 and 46 of the same file, and [Expected output](../tests/ch32/test_sdf_recrem_limits.expected).

The stimulus sets `d`, corresponding to an asynchronous control, to 7/12 and changes the clock to 10; SDF is `(RECREM d (posedge clk) (4) (3))`. However, SV is in reverse order to `$recrem(posedge clk, d, ...)`. 31.3.6 （pp. For recrem in 903–904), asynchronous-control deassertion is event 1, and the clock is event 2. This is also confirmed by equivalent examples of `$recrem(posedge clear, posedge clk, ...)` and `$recovery` / `$removal` in the standard.

Furthermore, 32.4.2, Table 32-2 (p. 926) specifies that RECREM is annotated not only onto matching `$recrem`, but also onto `$recovery` and `$removal`. The description/expectation that an independent `$removal` for the same event retains limit 1 does not hold.

Proposed fix: change both SV checks to `(d, posedge clk, ...)` to match the intended stimulus. Rebuild expected values assuming limit 3 also applies to `$removal` on the same event. Under this configuration, the recovery violation is evaluated at 10 and the removal violation at 12; the latter also changes an independent removal notifier. Use a check on another event as the control for an unannotated check. Also correct metadata `31.4.6` to `31.3.6`, which specifies recrem.

<a id="f12-coverage制御がすべてerrorでも全判定が合格する"></a>

### F12: every check passes even if all coverage controls return ERROR

Scope: [test_coverage_definition_control.sv:68](../tests/ch40/test_coverage_definition_control.sv#L68), line 80–94 of the same file.

The failure of the operation itself becomes a condition of success under the conditions `reset_u1 != SV_COV_OK || ...`, `stop_def != SV_COV_OK || ...`, and `start_u1 != SV_COV_OK || ...`. In 40.3.2.1, Table 40-1, `SV_COV_ERROR` indicates operation failure. This does not distinguish `NOCOV` and similar results for absent coverage from API implementation errors.

Ran a copy replacing all `$coverage_control`, `$coverage_get`, and `$coverage_get_max` with `(-1)` (`SV_COV_ERROR`), retaining all other stimulus and checks; on Icarus 13.0, all expected 4 lines still matched as 1. This test passes even without implementing RESET / STOP / START or instance selection. The source comment also implies the failure, but the action listed in the test description cannot be verified.

Fix: Check the return values of each operation and reference, and fail ERROR. NOCOV etc. are explicitly distinguished as unverified, and in the configuration that can be collected normally, operation success and actual coverage change are required. Even if only the validity of the return value is checked first, this prevents false positives of all ERROR.

<a id="実行した確認"></a>

## Checks performed

- `tools/suite_stats.py --check` : Success.
- `generators/generate.py --check` : Success.
- `tools/suite_catalog.py --check` : Success.
- `tools/coverage_depth.py --check` : Success.
- `tools/lint_metadata.py`: 3,801 cases, 0 new issues, 378 known issues, 0 resolved issues. Known presentation issues are excluded from this review's 12 findings.
- Icarus Verilog 13.0: passed all 3,801 cases to the runner; 2,526/2,526 oracle-backed cases matched. The 1,275 case is a known difference frame. Including 50 actual matches outside the target scope, JSON has 2,576 passes.
- Verilator 5.052: all 944/944 oracle-target cases agree. Neither Icarus nor Verilator had a new mismatch on existing oracle-backed cases, but this does not rule out discrepancies with the standard such as F01–F04.
- pyslang 12.0.0: All 3,801 items have been parsed. The number of diagnoses is not treated as the number of problems because there are some diagnoses due to non‐compatible functions, etc.
- C11 syntax check (`-Wall -Wextra -Wformat=2 -Wuninitialized`): 0 compile errors across 208 files. Warnings: 1 unused variables. F08 is a API buffer-lifetime issue not detected by compiler warnings.
- Additional reproduction: confirmed the shared buffer of F08, shared static arguments of F09, and false positives when F12 is all ERROR.

Rerun command for existing major checks (run in repository path):

```sh
python3 tools/suite_stats.py --check
python3 generators/generate.py --check
python3 tools/suite_catalog.py --check
python3 tools/coverage_depth.py --check
python3 tools/lint_metadata.py
python3 tools/run_icarus.py --iverilog-bin /opt/homebrew/Cellar/icarus-verilog/13.0/bin -j 6 --json /tmp/kirimasim-review-icarus.json
python3 tools/run_verilator.py -j 4 --json /tmp/kirimasim-review-verilator.json
```

<a id="診断と規格を照合して指摘から除外した例"></a>

## Examples excluded from findings after checking diagnostics against the standard

The reason that the additional analyzer refused is not judged as a violation of the standard. For example, whole-UDN force/release (6.6.7), narrow associative-array traversal arguments (7.9.8), nettype aliases and type identity (6.22.6), interconnect connections to primitive terminals (23.3.3.7.2), and configuration selection from sources containing config (33.5.4) were excluded from this round's findings after confirming the main text's permission rules.

The 502 standard-only cases do not establish independent reproduction of positive expected values on 2 existing simulators. In particular, advanced VPI, checkers, SDF timing checks, and coverage API were evaluated mainly through comparison with the standard's text and local reproductions.

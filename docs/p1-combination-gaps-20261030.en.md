<a id="p1組合せの不足の具体例2026-10-30"></a>

# P1: concrete examples of missing combinations (2026-10-30)

[English](p1-combination-gaps-20261030.en.md) / [日本語](p1-combination-gaps-20261030.md)

Scope: main `51cda3143aed9db377b4ea570f6b8ec0bf8bc513` 。 This investigation makes concrete the earlier remaining-work category “8. Missing combinations.” Independent major areas such as classes, VPI, specify, FST, and `%p`/`%v` are handled separately. The specification, existing expected value, and the pass condition of P1 are not changed.

See [Issue #21 support matrix and execution results](p1-combination-regressions-20261030.en.md) for subsequent regression integration. Mapped 74 new and 14 existing cases to 20 items, separately recording interpretation holds and areas not verified on native API. The following text and measurement JSON record the initial investigation of `51cda3143aed`. Do not reinterpret these observations as the latest feature-support status.

<a id="kirimasim-testsでの初期取り込み方針配置当時"></a>

## Initial intake policy at kirimasim-tests (when this document was placed)

This document ports inputs/observation records created on the kirimasim side for future regression tests. The links to the implementation and specification are fixed to the observed kirimasim commit. The contents of JSON retain the original observation records.

- First check whether existing tests have the same stimuli/observations, then map reusable tests and cases needing additions.
- `unsupported` diagnostics reflect the implementation state at that time. Do not fix as the expected value of a valid positive test. Derive correct values, times, update targets, lifetimes, and related results from the standard and an independent model.
- Parser rejection alone does not establish that every such input is illegal. Design positive and negative tests by distinguishing between the standard prohibitions, the legal out-of-range operations, and the strict diagnostics of the implementation.
- Placing this document did not change `tests/`, generators, expectations, requirement mappings, the existing population or denominator. Counts of observations from 34 inputs are not added to suite pass counts or requirement coverage.
- The comparison with the Icarus compatibility range and the verification of the standard compliance are carried out in the future test design. Please check [Rules for :lrm:, :oracle: and related fields](../README.md#metadata) when adding.

For design and registration procedures, see [Feature-interaction verification method](interaction-verification-method.en.md) and [From requirements to tests](requirements-to-tests-method.en.md).

<a id="1-組合せの不足とは"></a>

## 1. Meaning of missing combinations

Even if the functions can be executed individually, the combination of type, memory area life, argument passing, reserved update, and execution area may not be connected to the processing of transformation and retention.

For example, automatic scalar events and event members of static structures work. On the other hand, if an event member is placed in an automatic structure, it is not supported. Ordinary delay NBA and ref arguments work individually, but delayed NBA through `ref static` is unsupported.

These categories provide an overview of the work. One cause may block several forms, so item counts are not counts of required PR, implementation effort, or mandatory P1 features.

<a id="2-今回の確認範囲"></a>

## 2. Scope checked in this round

Using `kirimasim 0.0.0 (commit 51cda3143aed)` built from the current source, checked independently created 34 inputs with `parse` and `--dump-sir`. For 6 inputs that successfully generated SIR, also verified normal execution.

- 25 Input: conversion to SIR for execution is not supported. `parse` reports `unsupported` with 0, and `--dump-sir` with 2.
- 5 Input: a control example that runs normally. Events, ordinary delay NBA, fixed packed parents, queue monitors, and similar cases.
- 1 Input: lack of waveform scope. The execution is successful, but the program/interface signal does not come out to VCD.
- 3 input: rejected by the frontend. This is not included in the number of cases of native implementation shortages.

Sources, exit codes, diagnostics, and control stdout for all inputs are saved in [Measurement JSON](measurements/2026-10-30/p1-combination-gaps.json). `probe` in the text is `id` of that JSON. The complete source of the code fragment can also be found in the same JSON.

This time, we did not perform a comparison with Icarus 13.0. `parse` success alone cannot prove the conformity of individual forms to the standard or the P1 necessity independently. The following records current implementation boundaries; it does not make every 25 input a new mandatory condition of P1.

<a id="3-eventイベント制御プロセスの組合せ"></a>

## 3. Combinations of events, event controls, and processes

<a id="e01automaticな構造体--eventメンバー"></a>

### E01: automatic structure × event member

The working forms are a standalone automatic event and an event member of a static structure. The missing form constructs the following structure inside an automatic task.

```systemverilog
module top;
  typedef struct { event go; int n; } item_t;
  task automatic check_value();
    item_t item;
    -> item.go;
  endtask
  initial check_value();
endmodule
```

`probe: event_struct_auto` is `unsupported: automatic event variable`. Both `event_struct_static_control` and `event_scalar_auto_control` output `1` and exited successfully.

The necessary connection is to pass the event leaf of the structure to the initialization, typed root, and capture of the automatic frame. Verify per-call event independence, retention across forks/waits, and reclamation after termination. Rationale: [Structure frame conversion](https://github.com/kurochan001/kirimasim/blob/51cda3143aed9db377b4ea570f6b8ec0bf8bc513/src/front/lower_struct.cpp) 、 [The automatic capture contract](https://github.com/kurochan001/kirimasim/blob/51cda3143aed9db377b4ea570f6b8ec0bf8bc513/docs/notes/automatic-capture-proposal.md) 。

<a id="e02event値--関数戻り値条件式からの初期化"></a>

### E02: event value × initialization from a function result / conditional expression

Direct waits/triggers on named events, supported declaration-initialization copies and input arguments work. On the other hand, the path to copy from the event-calculated expression is lacking, as shown in the following example.

```systemverilog
function automatic event identity(input event e);
  return e;
endfunction
// event source_eventがある文脈で：
// static event copied = identity(source_event);
// static event selected = choose ? first_event : second_event;
```

Both `probe: event_return, event_conditional` passed parsing and stopped at `unsupported: assignment to this kind of target`. The function call stops while copying the event values of the function call and conditional expression, so this result alone is not treated as having reached the return value processing of the function body.

Function-return forwarding, event identity, single evaluation of expressions and the GC root must be connected. Before implementation, resolve semantics left open by the existing limited event contract, including unknown conditional-expression conditions. Rationale: [event copying](https://github.com/kurochan001/kirimasim/blob/51cda3143aed9db377b4ea570f6b8ec0bf8bc513/src/front/lower_sub.cpp) 、 [Expression conversion](https://github.com/kurochan001/kirimasim/blob/51cda3143aed9db377b4ea570f6b8ec0bf8bc513/src/front/lower_expr.cpp) 、 [Event transfer](https://github.com/kurochan001/kirimasim/blob/51cda3143aed9db377b4ea570f6b8ec0bf8bc513/docs/notes/event-transfers.md) 。

<a id="e03always_ff--計算したエッジ式"></a>

### E03: `always_ff` × calculated edge expression

Ordinary signal edges and expression monitoring in general event controls are supported. In `always_ff @(posedge (a ^ b))`, there is a lack of connection with the form using the equation.

`probe: always_ff_expression` is `unsupported: always_ff with an event control on an expression`. Preserve the same event control while checking expression changes, edges, and scheduling regions. Rationale: [Procedure and sensitivity conversion](https://github.com/kurochan001/kirimasim/blob/51cda3143aed9db377b4ea570f6b8ec0bf8bc513/src/front/lower.cpp) 、 [event control](https://github.com/kurochan001/kirimasim/blob/51cda3143aed9db377b4ea570f6b8ec0bf8bc513/src/front/lower_stmt.cpp) 。

<a id="e04iffガード--変数を書き換える関数"></a>

### E04: `iff` guard × a function that changes a variable

Guards that read values work. The form in which the function called by guard writes the variable is not supported.

```systemverilog
function automatic bit bump();
  count++;
  return 1;
endfunction
// @(posedge clk iff bump());
```

`probe: guard_writes_value` is `unsupported: iff condition that writes a variable or net`. Evaluation counts and timing, plus renotification and reentry on writes, must be specified and verified. Distinguish this from the form below where Slang rejects writing `count++` directly in a guard. Rationale: [Guard conversion](https://github.com/kurochan001/kirimasim/blob/51cda3143aed9db377b4ea570f6b8ec0bf8bc513/src/front/lower_stmt.cpp) 。

<a id="e05非ブロッキングevent-trigger--event-control"></a>

<a id="e05ノンブロッキングイベントトリガ--イベント制御"></a>

### E05: non-blocking event trigger × event control

The normal `->`, `->>`, the supported triggers with delay and the event-NBA are triggered. Forms using `->> @(posedge clk) go;` are a separate unsupported path.

`probe: event_trigger_control` is `unsupported: ->> with an event control`. Connect control registration, event-value retention, and cleanup on release/process termination. Rationale: [Conversion of event trigger](https://github.com/kurochan001/kirimasim/blob/51cda3143aed9db377b4ea570f6b8ec0bf8bc513/src/front/lower_stmt.cpp) 。

<a id="e06名前付きfork--名前を指定したdisable"></a>

### E06: named fork × named disable

`fork` / `join` and the supported `disable fork` will move. The form of stopping `fork : workers ... join` with `disable workers;` is not supported.

`probe: named_fork_disable` is `unsupported: disable of this block`. Connect fork execution units with named scopes so target child processes, waits, and pending updates terminate correctly. This cannot be treated like disabling an ordinary sequential block. Rationale: [disable](https://github.com/kurochan001/kirimasim/blob/51cda3143aed9db377b4ea570f6b8ec0bf8bc513/src/front/lower_stmt.cpp) 、 [Capture processing](https://github.com/kurochan001/kirimasim/blob/51cda3143aed9db377b4ea570f6b8ec0bf8bc513/src/front/lower_capture.cpp) 。

<a id="4-予約する代入--ref選択対象"></a>

## 4. Scheduled assignments × ref and selected targets

<a id="n01ref-static引数--遅延nba"></a>

### N01: `ref static` argument × delay NBA

`value <= #1 5;` to ordinary static variables works; the control example also confirmed `5`. The ID of this example is `nba_slot_delay_control`. Scheduling through a ref argument referencing the same static variable is missing.

```systemverilog
module top;
  int value;
  task automatic put(ref static int r);
    r <= #1 5;
  endtask
  initial begin put(value); #2; end
endmodule
```

`probe: nba_ref_delay` is `unsupported: delayed nonblocking assignment through a ref`. Need to preserve the value, time, and actual static target when scheduling, and write to the correct destination even after the task returns. This does not relax the prohibition on NBA targeting automatic variables. Rationale: [Write to ref](https://github.com/kurochan001/kirimasim/blob/51cda3143aed9db377b4ea570f6b8ec0bf8bc513/src/front/lower_expr.cpp) 、 [SIR reference contract](https://github.com/kurochan001/kirimasim/blob/51cda3143aed9db377b4ea570f6b8ec0bf8bc513/docs/spec/SIR_SPEC.md) 。

<a id="n02event-nba--ref固定配列の要素"></a>

### N02: event-NBA × ref fixed-array element

event-NBA targeting direct static-array elements is supported. `r[1] <= @(posedge clk) 5;` through `ref static int r[2]` is unsupported.

`probe: nba_ref_event_array` is `unsupported: event-NBA to an array element through a ref`. Preserve the array referenced by ref and the scheduled index throughout the event wait.

<a id="n03event-nba--ref先の入れ子packed選択"></a>

### N03: event-NBA × nested packed selection at the ref target

This uses `ref static logic [1:0][7:0] r` to produce `r[0][i] <= @(posedge clk) 1;`. Simple ref targets and supported bit selections alone cannot represent selections with this parent range.

`probe: nba_ref_event_window` is `unsupported: event-NBA to a nested packed selection through a ref`. Capture parent width/position/bounds and child position, scheduling only writable bits. Rationale for N02 and N03: [Target capture for event-NBA](https://github.com/kurochan001/kirimasim/blob/51cda3143aed9db377b4ea570f6b8ec0bf8bc513/src/front/lower_nba.cpp), [event-NBA contract](https://github.com/kurochan001/kirimasim/blob/51cda3143aed9db377b4ea570f6b8ec0bf8bc513/docs/notes/event-nba-proposal.md).

<a id="n04文字列の文字選択--遅延nba"></a>

### N04: string character selection × delayed NBA

Ordinary assignments to strings/characters work. `text[i] <= #1 8'h41;` is not supported for static strings.

`probe: nba_string_char_delay` is `unsupported: delayed nonblocking assignment to a string character`. Connect the destination and update rules for strings whose values, lengths, or indices change while an assignment is pending to existing string semantics. Rationale: [Writes to character selections](https://github.com/kurochan001/kirimasim/blob/51cda3143aed9db377b4ea570f6b8ec0bf8bc513/src/front/lower_expr.cpp) 。

<a id="5-固定の複合型--automatic引数copyback"></a>

## 5. Fixed compound type × automatic, argument, copyback

<a id="a01unpacked構造体--ref引数"></a>

### A01: unpacked Structure × ref argument

The values of fixed structures, supported input/output/inout transfers, and scalar and fixed array references can be used. The form of passing `typedef struct { int n; } item_t;` to `task put(ref item_t r);` is not supported.

`probe: struct_ref` reports `argument 'r' of an array of structures or a ref structure`. A whole-structure ref must be assigned to its leaves while retaining the actual target through waits, forwarding and const restrictions. Rationale: [Conversion of subroutine arguments](https://github.com/kurochan001/kirimasim/blob/51cda3143aed9db377b4ea570f6b8ec0bf8bc513/src/front/lower_sub.cpp) 。

<a id="a02構造体配列--automatic記憶域配列引数"></a>

### A02: structure arrays × automatic storage / array arguments

Supported operations on static structure arrays work. There are gaps in the automatic task’s `item_t items[2];` and in `input item_t items[2]`.

`probe: struct_array_auto` is `automatic unpacked array in a structure or of structures`, and `struct_array_input` is `argument 'r' of an array of structures or a ref structure`. Connect automatic storage of leaf arrays, argument copies, and per-call independence. The forms in which the function returns a structure array are explicitly rejected in the source, but are not included in this execution verification. Rationale: [Structure memory](https://github.com/kurochan001/kirimasim/blob/51cda3143aed9db377b4ea570f6b8ec0bf8bc513/src/front/lower_struct.cpp) 、 [Arguments and returns](https://github.com/kurochan001/kirimasim/blob/51cda3143aed9db377b4ea570f6b8ec0bf8bc513/src/front/lower_sub.cpp) 。

<a id="a03構造体の固定配列メンバー--automatic記憶域"></a>

### A03: fixed array member of the structure × automatic memory area.

This concerns using the following types as local variables in an automatic task.

```systemverilog
typedef struct { int words[2]; } item_t;
// task automatic内：item_t item; item.words[0] = 1;
```

`probe: struct_array_member_auto` is `unsupported: automatic unpacked array in a structure or of structures`. Handle not only scalar structure leaves but also array-leaf frame representations, initialization, and copying. Rationale: [Structure frame](https://github.com/kurochan001/kirimasim/blob/51cda3143aed9db377b4ea570f6b8ec0bf8bc513/src/front/lower_struct.cpp) 。

<a id="a04固定配列スライス--outputinoutの書き戻し"></a>

### A04: fixed-array slices × output/inout copyback

Supported array-slice reads and whole-array arguments are available. The form of sub-array as the output real argument is not supported.

```systemverilog
module top;
  int values[4];
  task put(output int r[2]); r = '{1, 2}; endtask
  initial put(values[1:2]);
endmodule
```

`probe: array_slice_copyback` is `unsupported: an output or inout array argument of this actual`. The custom inputs in this round test output only; inout is documented with the same limitation in the support table/source. The evaluation of the real arguments must be connected to the retention of the object range, declaration direction, and other elements when returning. Rationale: [Array actual-argument conversion](https://github.com/kurochan001/kirimasim/blob/51cda3143aed9db377b4ea570f6b8ec0bf8bc513/src/front/lower_sub.cpp) 、 [Copyback from SIR](https://github.com/kurochan001/kirimasim/blob/51cda3143aed9db377b4ea570f6b8ec0bf8bc513/docs/spec/SIR_SPEC.md) 。

<a id="6-選択streamingの組合せ"></a>

## 6. Combination of selection and streaming.

<a id="s01位置が動くpacked親--実行時の子選択"></a>

### S01: a moving packed parent × runtime child selection

Fixing the parent as in `values[1][bit_index] = 1;` works; the control printed `0800`. The ID of this example is `packed_parent_fixed_control`. Selecting the parent at runtime is unsupported.

```systemverilog
module top;
  logic [1:0][7:0] values;
  int row = 1, bit_index = 3;
  initial begin
    values = '0;
    values[row][bit_index] = 1;
  end
endmodule
```

`probe: packed_parent_runtime` is `unsupported: a runtime select of this parent packed range`. Evaluate parent/child positions once each and preserve positions and bounds so a child selection beyond the parent cannot write adjacent elements. Rationale: [packed write target](https://github.com/kurochan001/kirimasim/blob/51cda3143aed9db377b4ea570f6b8ec0bf8bc513/src/front/lower_expr.cpp) 。

<a id="s02streaming--with文字列の宛先入れ子の宛先"></a>

### S02: streaming × `with` / string destination / nested destination

Supported streaming of fixed arrays/structures and delayed NBA are implemented. The following 3 representative forms remain.

- `probe: stream_with` ： `{>>{values with [1:2]}}` 。 Rejected with `streaming with a with clause`.
- `probe: stream_string_target` ： `{>>{text}} = 16'h4142;` 。 Rejected with `unpacking this stream`.
- `probe: stream_nested_target` ： `{>>{{>>{value}}}} = 8'h41;` 。 Rejected with `unpacking into this target`.

Selected element counts/order, string lengths, nested bit reordering and per-destination truncation must connect to shared conversion and write operations. Rationale: [Conversion of streaming](https://github.com/kurochan001/kirimasim/blob/51cda3143aed9db377b4ea570f6b8ec0bf8bc513/src/front/lower_expr.cpp) 、 [SIR's streaming contract](https://github.com/kurochan001/kirimasim/blob/51cda3143aed9db377b4ea570f6b8ec0bf8bc513/docs/spec/SIR_SPEC.md) 。

<a id="7-ファイル波形監視の組合せ"></a>

## 7. File, waveform, and monitoring combined.

<a id="f01fread--動的メモリ複雑な構造体メモリ"></a>

### F01: `$fread` × Dynamic memory/Complex structure memory

Integer scalars, multidimensional fixed integer memories, and supported 1-dimensional structure memories with integer leaves work. The following 4 representative forms remain.

- `probe: fread_dynamic`: Loading to `byte values[]`. The destination path of the dynamic memory is not supported.
- `probe: fread_struct_array_member`: memory whose structure contains `byte values[2]`. The array member is not compatible.
- `probe: fread_struct_real_member`: memory whose structure contains `real value`. The real member is not supported.
- `probe: fread_struct_multidim`: `rows[2][2]` of the structure. The multidimensionalization of the structure memory is not supported.

Both 4 inputs parsed successfully, then were rejected at `$fread into a memory of this kind` or `$fread into a structure with a member of type ...`. These inputs did not reach file-opening code. Element traversal order, start/count, partial input, preservation of pre-input values and copyback-target capture must be integrated. Rationale: [Input targets and layout](https://github.com/kurochan001/kirimasim/blob/51cda3143aed9db377b4ea570f6b8ec0bf8bc513/src/front/lower_expr.cpp) 、 [System-task contract](https://github.com/kurochan001/kirimasim/blob/51cda3143aed9db377b4ea570f6b8ec0bf8bc513/docs/spec/SYSTEM_TASKS.md) 。

<a id="f02programinterface内部の変数--vcdスコープ"></a>

### F02: Variable inside program/interface × VCD Scope

The module’s VCD output works. This time, we instantiated the interface and program in the top module, updated their internal variables, and executed `$dumpvars(0, top)`.

`probe: vcd_program_interface` succeeded in parsing, SIR generation, and ordinary execution, but the generated VCD contained only `$scope module top` and `module_bit`; the interface's `bus_bit` and the program's `program_bit` were absent. This is a shortcoming that is not understood by the exit code alone.

Connect hierarchy traversal, scope kinds, and registration of corresponding signals to the waveform path. Rationale: [Dump-hierarchy construction](https://github.com/kurochan001/kirimasim/blob/51cda3143aed9db377b4ea570f6b8ec0bf8bc513/src/front/lower_dump.cpp) 、 [Waveform specification](https://github.com/kurochan001/kirimasim/blob/51cda3143aed9db377b4ea570f6b8ec0bf8bc513/docs/spec/WAVEFORM.md) 。

<a id="h01動的コンテナの値--暗黙の感度"></a>

### H01: Value of dynamic container × implicit sensitivity

Explicit waits on dynamic arrays/queues and supported heap-dependency monitoring work. Inferred sensitivity forms such as `always_comb result = values.size();` have gaps.

`probe: heap_implicit_sensitivity` is `unsupported: implicit sensitivity to dynamic container values`. Sensitivity connections must reflect container changes, replacement and element changes, not just static slot ranges. `always_latch`, `always @*`, and continuous assignments have the same matrix restriction; only `always_comb` was execution-verified here. This duplicates the earlier category “4. Remaining dynamic-container work” and is not counted twice as remaining work. Rationale: [Implicit sensitivity test](https://github.com/kurochan001/kirimasim/blob/51cda3143aed9db377b4ea570f6b8ec0bf8bc513/src/front/lower.cpp) 、 [Container scope](https://github.com/kurochan001/kirimasim/blob/51cda3143aed9db377b4ea570f6b8ec0bf8bc513/docs/P1_SUPPORT.md) 。

<a id="u01heapを読むfile-monitor--全コンテキスト再入登録未確認"></a>

### U01: a heap-reading file monitor × all contexts/reentrant registration (unverified)

Basic monitor tracking of queue-element changes and file-monitor closing, descriptor reuse, and callback termination are already checked. This `postponed_heap_control` also outputs `1` and `2` for the same queue element change.

On the other hand, the re-entry registration from callback and the combination coverage in all source contexts are not confirmed in the correspondence table. This does not mean the missing implementation or defect was first discovered here. Check registration-time growth/shrinkage together with file closure, replaced heap values, callback ownership, and cleanup. Rationale: [File-monitor lifetime checks](https://github.com/kurochan001/kirimasim/blob/51cda3143aed9db377b4ea570f6b8ec0bf8bc513/docs/notes/heap-file-monitor-lifetime.md) 、 [Correspondence table](https://github.com/kurochan001/kirimasim/blob/51cda3143aed9db377b4ea570f6b8ec0bf8bc513/docs/P1_SUPPORT.md) 。

<a id="8-実装不足の件数に含めないもの"></a>

## 8. Items excluded from missing-implementation counts

The following 3 inputs were rejected during parsing by the strict frontend configuration used here. Do not relax these diagnostics to enable native conversion.

- `automatic_nba_illegal_control`: NBA targeting automatic locals. `nonblocking assignment to automatic variable ... is not allowed` 。 In N01, we used `ref static` to avoid this by accepting the actual static object.
- `strobe_auto`: refers to the automatic variable directly from `$strobe`. `automatic variable ... cannot be traced` 。 This is a limitation on the corresponding table, but in this environment it is a diagnosis of the Slang stage.
- `packed_parent_outside`: constant packed index outside the declared range. `cannot refer to element 2 ... [-Windex-oob]` is an error. This is an observation of strict diagnosis, and there is no generalization that "the choice of the constant outside the range is always standard error".

Similarly, attempts to write `count++` directly to the guard were rejected by Slang. What we have seen in E04 is another way of rewriting variables inside a function.

<a id="9-既に完了した範囲とこの記録の使い方"></a>

## 9. The scope of the already completed and how to use this record

Already implemented areas that must be distinguished from these gaps include `foreach` with mixed fixed/dynamic dimensions, supported runtime dimension queries, automatic scalar/fixed-array events, basic event-NBA, delayed NBA for fixed aggregates, and basic heap-backed monitors. Recent strength-qualified force work covers only the kernel foundation; source integration belongs to the separate category “5. Remaining nets and switches.”

When using these records for future implementation, choose 1 target form and check the following.

1. Determine whether this is mandatory scope under [P1_SCOPE](https://github.com/kurochan001/kirimasim/blob/51cda3143aed9db377b4ea570f6b8ec0bf8bc513/docs/spec/P1_SCOPE.md) or a candidate requiring comparison and specification checks.
2. Check existing semantics and acceptance/rejection expectations. Separate any needed specification change or expectation migration first.
3. Retain individual successes and combined failures; check values, evaluation counts, times, regions, and lifetimes.
4. After support is added, retain these dated observations and update the support matrix and regressions for the new version.

<a id="10-保存した入力の再現方法"></a>

## 10. Method of reproducing the saved input

For example, the complete input of E01 is extracted from JSON. Run from the root directory of kirimasim-tests. The simulator used is kirimasim, built separately from this repository. Set `KIRIMASIM_BIN` to the executable path. Use the commits above for historical reproduction and the latest version checked immediately before execution for future implementation assessment; record `--version`.

```sh
export KIRIMASIM_BIN=/path/to/kirimasim
"$KIRIMASIM_BIN" --version
mkdir -p build/combination-audit
python3 - <<'PY'
import json
from pathlib import Path
data = json.loads(Path('docs/measurements/2026-10-30/p1-combination-gaps.json').read_text())
probe = next(item for item in data['probes'] if item['id'] == 'event_struct_auto')
Path('build/combination-audit/probe.sv').write_text(probe['source'] + '\n')
PY
"$KIRIMASIM_BIN" parse build/combination-audit/probe.sv
"$KIRIMASIM_BIN" --dump-sir build/combination-audit/probe.sv
```

In the recorded version, the former is 0, and the latter is 2. Diagnostic locations change when the input is reformatted. When switching probes, change `id` and inspect the saved results in `parse` and `sir`. In the waveform example, we use an independent working directory because `probe.vcd` is created in the working directory. Future implementations may make these cases succeed. This material is not an automatically registered test suite and was not added to the then-current 8,311 cases in kirimasim itself or to the pass/fail counts in kirimasim-tests.

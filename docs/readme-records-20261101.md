<a id="readmeから移した記録2026-10-252026-11-01"></a>

# Archived README records: 2026-10-25 to 2026-11-01

[日本語](readme-records-20261101.ja.md)

These records were moved from the README on 2026-11-01. Counts, versions and
observations describe the recorded runs. For the current suite, use the
[README](../README.md).

The generator table below preserves the former manual README inventory. Use the
[generated catalog](generators.md) for the complete current list and counts.

<a id="シミュレーション速度"></a>

## Simulation speed

The suite checks what simulators compute, not how fast. For reference, the
kirimasim repository keeps a comparison of their speed on small designs of
its own ([bench/](https://github.com/kurochan001/kirimasim/tree/main/bench)).
Its latest run, on Linux under WSL2 (AMD Ryzen 9 7950X) on 2026-10-25, used
each simulator's newest development commit and eleven designs, and gave the
times in the first four columns: the median of five runs at the stated count
less the median of five runs with `+n=1`. The Ghost column is a later
measurement on the same machine (2026-10-28); because a full run takes much
longer, it is extrapolated as described in the notes.

| Design | `+n=` | kirimasim | Icarus Verilog 14.0 devel | Verilator 5.053 devel | Lyra (LLVM backend) | Ghost* |
| --- | :---: | :---: | :---: | :---: | :---: | :---: |
| `comb_chain` | 3,000,000 | 9.249 s | 9.796 s | 0.223 s | 2.878 s | 1,153 s* |
| `nba_shift` | 1,000,000 | 25.486 s | 26.585 s | 0.196 s | 5.900 s | 2,707 s* |
| `proc_wait` | 1,000,000 | 6.786 s | 5.688 s | 2.283 s | 6.164 s | 1,816 s* |
| `fork_join` | 4,000,000 | 4.837 s | 5.023 s | 1.190 s | 4.860 s | 909 s* |
| `wide_arith` | 1,500,000 | 4.944 s | 2.036 s | 0.086 s | 0.380 s | 131.4 s |
| `mem_rw` | 4,000,000 | 4.937 s | 3.645 s | 0.696 s | 2.705 s | 1,258 s* |
| `func_call` | 1,500,000 | 4.917 s | 7.511 s | 0.005 s | 0.395 s | 291 s* |
| `string_fmt` | 500,000 | 5.003 s | 8.080 s | 0.135 s | 0.279 s | 477 s* |
| `dyn_queue` | 4,000,000 | 4.112 s | 6.686 s | 0.083 s | 0.412 s | 400 s* |
| `gate_udp` | 400,000 | 5.378 s | 3.517 s | 0.046 s | not supported | 835 s* |
| `casez_struct` | 5,000,000 | 3.976 s | 4.117 s | 0.018 s | 0.466 s | 525 s* |

`*` Full count for `wide_arith`; otherwise extrapolated from reduced counts.

- kirimasim was at commit `b66834254c65`, Icarus Verilog at 14.0 devel
  `2b8d42dc088f`, Verilator at 5.053 devel `1838b6ed035c` and Lyra at
  `63922502ff0a`, built with `bazel build -c opt`. These benchmark measurements
  use the recorded commits; Nightly resolves the latest upstream commits for
  each run. The Lyra column uses its LLVM backend at `-O 0`. In these
  measurements, omitting `--backend` selected its C++ backend: on these
  designs it was 3.3 to 67 times slower than the LLVM backend, and its times
  are in kirimasim's benchmark details linked below.
  Every measured run gave the expected result; Lyra does not support gates or
  UDPs yet, so it built no program for `gate_udp`. The times do not include
  building a design (Verilator's C++, Lyra's program).
- Ghost was at commit `a2420294`, measured on
  2026-10-28 on the same WSL2/Ryzen 9 7950X machine. A full run takes 2 to
  45 minutes per run for Ghost, so most of its column is extrapolated: three
  runs at each of two reduced counts, the second twice the first
  (10,000/20,000, 2,000/4,000, or 1,000/2,000); the larger count took 1.97 to
  2.09 times as long as the smaller, and the slope was applied to the stated
  count.
  The full-count `wide_arith` run (131.4 s) matches its extrapolation within
  about 2% and its result line was checked. The other columns are the
  2026-10-25 medians.
- Ghost was 27 to 268 times slower than kirimasim on these designs (the
  smallest gap is `wide_arith`, the largest `proc_wait`) and 39 to 345 times
  slower than Icarus Verilog. These are the default runtime options of its
  release build; the column shows a large performance gap, not a functional
  difference.
- The first four designs exercise `always_comb` chains, nonblocking
  assignments, waiting processes and `fork`/`join`. The other seven use
  256-bit arithmetic (`wide_arith`), a 1024-word memory (`mem_rw`), task and
  recursive function calls (`func_call`), `$sformatf` (`string_fmt`), a queue
  and a dynamic array (`dyn_queue`), gates and a UDP (`gate_udp`), and `casez`
  into a packed struct (`casez_struct`).
- kirimasim was slower than Icarus Verilog on `proc_wait`, `wide_arith` (2.4
  times), `mem_rw` and `gate_udp`, clearly faster on `func_call`,
  `string_fmt` and `dyn_queue`, and within about 6% on the other four. On
  `dyn_queue` its peak memory grows with the count (547 MiB at 4,000,000).
  Comparisons with earlier runs are in the [history](history.md).
- Small designs on one machine do not stand for the speed of real designs.
  Build times, startup, memory and the commands that reproduce the runs are
  in kirimasim's
  [benchmark details](https://github.com/kurochan001/kirimasim/blob/main/docs/BENCHMARKS.md#development-versions-on-linux-wsl2-2026-10-25).

<a id="nightlyの保存結果2026-10-31"></a>

## Nightly snapshot: 2026-10-31

**Verified Nightly (2026-10-31):** [Nightly](https://github.com/kurochan001/kirimasim-tests/actions/runs/41141958886)
completed all five simulator jobs and `publish`. The
[results snapshot](https://github.com/kurochan001/kirimasim-tests/blob/a587ba92e91e4fe2217710c7408614c6649d84e7/README.md)
was generated at 11:16 JST (02:16 UTC) for suite
[`73af6e95`](https://github.com/kurochan001/kirimasim-tests/commit/73af6e954828221c3c7447dd13cd3a271ae5bb55)
(**9,203 tests**). Lyra was built from
[`e13a017966a5`](https://github.com/hankhsu1996/lyra/commit/e13a017966a5).
This snapshot predates the current suite; use the [live report](https://github.com/kurochan001/kirimasim-tests/tree/results#readme)
for subsequent published runs.
Matching tests / recorded results:

- Icarus Verilog: **5,701 / 8,935**.
- Verilator: **5,265 / 8,935**.
- kirimasim: **6,468 / 8,935**.
- Lyra: **6,933 / 8,935**.
- Ghost: **8,036 / 8,935**.

`differ`, `known difference` and `unsupported` results remain in the denominator.
All five runners exclude the 268 formal tests in this run. Workflow success does
not mean every test matched. The SymbiYosys results are reported separately above.

<a id="クロスモデルの追加と引き継ぎの記録"></a>

## Cross-model additions and handoff records

The newest model crosses event-handle rebinding with event-control registration,
task input/ref arguments and wakeup regions (chapters 6 and 15). It selects **27
tests from 648 legal assignments**, preserving 138 pairs, 69 focused triples and
six mandatory cases. All 27 parse, but kirimasim cannot execute their event-value
operations. Fixed Icarus 13.0 and Verilator 5.052 reject them at build time, so
there are no confirmed execution passes for this model. See the
[design and limitations](interaction-verification.en.md#イベント変数の再結合と登録済み待機の保持).

The mailbox model crosses class-handle identity with mailbox FIFO operations,
peek/get, bounded capacity, alias writes and null messages. It selects **36 tests
from 3,456 legal assignments**, retaining 245 pairs, 92 focused triples and nine
mandatory cases. kirimasim reports all 36 as unsupported mailbox types. Fixed
Verilator 5.052 matches 11 of the 12 known-input cases at both seeds 1 and 73;
it rejects the remaining legal typeless case at build time. The other 24 cases
require four-state observation. See the
[design, scope and evidence](interaction-verification.en.md#mailboxのclassハンドルと別名経由の更新).

To continue this work, see the [2026-10-31 handoff](codex-handoff-20261031.en.md)
for the repository state, the open issues and the resumption commands, and the
[2026-10-30 handoff](claude-code-handoff-20261030-cross-verification.en.md) for
the cross-model procedure and the verified builds behind it.
The [follow-up review of issues #40–#44](issues-40-44-review-20261031.en.md)
records the test corrections, fixed-tool results and remaining implementation limits.

[Issue #21's regression report](p1-combination-regressions-20261030.en.md) and
[reviewed registry](../coverage/combination-gaps.json) link existing witnesses to 74 new
tests: nine event, sixteen NBA, eighteen aggregate, thirteen I/O and eighteen
file-monitor cases. Only the eighteen file-monitor cases join a registered finite
interaction model; the other 56 exercise mechanism boundaries and are kept outside
the t-way coverage totals. The report records unresolved interpretations, separate
native-API work and results for each saved simulator run.
Use `python3 tools/combination_gaps.py --check` to check registry/report consistency,
and `python3 tools/combination_gaps.py --list-tests` to list all bound regression
tests, including reused tests. The consistency check does not require simulator passes.

<a id="sva検証記録2026-10-29"></a>

## SVA verification record: 2026-10-29

The reference evaluator reproduced 45 test outputs. The formal rerun covered
the full 267-case catalogue: 267 BMC checks, 44 unbounded PDR proofs, 267 covers,
and five expected failures from deliberately incorrect models.

All 111 cases of the separate parameter-boundary sweep passed BMC and PDR.
Its suite bindings identified 127 sequence fragments in 91 directives across
28 tests. The two formal sets overlap and are not added as distinct models,
and these model counts do not increase suite totals or change oracle categories.

Both saved reports were regenerated on 2026-10-29, and checks of current-source
identity and required-task completeness passed. See the
[SVA guide](sva-reference-formal-verification.en.md) and
[boundary-sweep report](sva-formal-expansion-20261026.en.md) for evidence and commands.

<a id="readmeに掲載していた生成器の説明"></a>

## Generator descriptions formerly listed in the README

This is the previous partial list, retained as a dated record. The current complete list is the [generated catalog](generators.md).

| Generator | Chapter | What it varies |
| --- | ---: | --- |
| `scheduling` | 4 | How a variable is written (blocking, nonblocking, nonblocking with an intra-assignment delay, through a continuous assignment, by `force`), how it is read (in the same process, by another process waiting for it, `$strobe`, `$monitor`), where the write is (initial, always, task, function, fork branch, interface, generate block) and after which delay (none, `#0`, `#1`); only the combinations whose result the standard fixes |
| `interaction_nba` | 10 | Constrained pairwise combinations of width (1, 32, 33, 64, 65, 129), bit/logic, known/X/Z values, scalar/fixed unpacked array, array direction, initial/automatic task and immediate/delayed NBA; selected triples and boundary witnesses additionally check value/index capture before mutation and task return |
| `interaction_expr` | 11 | Operand widths/signs, destination width and add/subtract/multiply; 51 selected cases with four input pairs each check context extension, carries and truncation |
| `interaction_select` | 11 | Packed-vector width/direction, +:/-: indexed slices, span/position, bit/logic and known/X/Z data; 36 selected cases check reads, writes and unselected-bit preservation |
| `interaction_cond` | 11 | Branch signs, condition 0/1/X/Z, known/X/Z branch patterns, destination width and bit/logic; 32 selected cases check selection, bitwise merge and conversion |
| `interaction_shift` | 11 | Operator/count/sign, source and destination width, known/X/Z values and bit/logic; 56 selected cases check context extension, boundary counts, X/Z sign fill and unknown counts |
| `interaction_compound` | 11 | Width/state/sign, scalar/array-element/packed-slice targets, three compound shifts and signed 8/65-bit counts; 40 cases check once-only LHS evaluation, full containers, guard bits and widened reads |
| `interaction_inside` | 11 | Set/needle widths and signs, bit/logic set elements, explicit list/fixed/dynamic/queue storage, size and X/Z patterns; 46 cases check wildcard comparison before four-state OR, empty sets, reverse lists and result conversion |
| `interaction_range` | 11 | Bound/needle widths and signs, bit/logic bounds, closed/reversed/`$`-bounded/absolute- and relative-tolerance ranges, X/Z and ranges mixed with values; 46 cases check bound extension at the comparison type, empty ranges, swapped and truncated tolerance bounds, and X/Z in a range against X/Z in a value |
| `interaction_case_inside` | 12 | Case-expression/item widths and signs, bit/logic items, a first item that is a value, range, fixed array or list, X/Z, no qualifier or `unique0`, and a third item held in a variable or returned by a counting call; 34 cases check that an X comparison moves on to later items, item extension, one evaluation of the case expression and evaluation after a match |
| `interaction_cast` | 6 | Source sign/value, size/signing/typed casts, cast width, later addition and destination state; 32 selected cases distinguish intermediate conversion from final conversion |
| `interaction_task` | 13 | Width/state/value, input/output/inout/ref, scalar/array-element actuals and immediate/delayed return; 36 selected cases check copy-in, copy-out, immediate reference updates and neighbor preservation |
| `interaction_binding` | 13 | Width/state/value, input/ref/const ref, fixed/dynamic/queue elements and later selector changes; 36 cases check original-element binding, private input copies, live reference reads, bidirectional updates and guard preservation |
| `interaction_clocking` | 14 | Width/state/value, local/interface/virtual-modport access, #1step/#0 input skew, clock edge and blocking/NBA updates; 36 cases distinguish pre-edge samples from Observed values, state conversion, live values and clocking wake counts |
| `interaction_assertion` | 16 | Width/state/value, Boolean expression, clock edge, blocking/NBA, update before/at/after the edge and module/interface; 36 cases check sampled predicates, pass/fail actions, Reactive live values and final values |
| `interaction_wait` | 9 | Width/state/value, dynamic array/queue, create/grow/shrink/clear/replace, size/element/both predicates and already-true/blocked waits; 36 cases check resumption time, unrelated changes and captured contents |
| `interaction_class_method` | 8 | Width/state/value, direct/virtual/nonvirtual receiver dispatch, function/task, input/ref/const-ref and recursive depth; 36 cases observe private frames, property aliases and A/B/A receiver identity |
| `interaction_return` | 13 | Width/state/value, for/while/repeat, head/middle/tail/no hit, and local/package function state; 36 cases check early return, scan effects, unreachable statements and shared-state ownership |
| `interaction_loop_nba` | 10 | Width/state/value, for/while/repeat, 2/3/5 iterations, scalar/same/rotated array targets, blocking/NBA and module/interface; 36 cases check feedback, queued write order and per-instance state |
| `interaction_process` | 9 | Width/state/value, comb/latch, direct/function, module/interface, 0/1/X/Z enable and idle value/hold; 36 cases observe implicit sensitivity, startup, disabled updates, unrelated changes and separate instance state |
| `interaction_generate` | 27 | Width/state/value, wildcard import/package qualification, optional local type/constant shadows, nesting and if/case generate; 36 cases check hierarchical paths, selected widths, genvar constants and continuous updates |
| `interaction_default` | 13 | Width/state/value, module/interface, variable/function defaults and five omitted/empty/named/explicit passing forms; 36 cases check declaring-instance scope, call-time values, formal binding and default evaluation counts |
| `interaction_event_task` | 15 | Module/interface/package event sources, input/ref tasks, direct/task blocking/NBA triggers, 1/2/3 listeners, source order and early/late arrival; 13 cases check event identity, fanout, rearming and Active/NBA payload visibility |
| `interaction_delay` | 10 | Scalar and 2/32/33/64/65/129-bit vectors, bit/logic, known/X/Z, one/two/three delays, short/long pulses and direct/inverted sources; 63 cases check delay selection, inertial cancellation, values and transition times/counts |
| `interaction_import` | 23 | Width/sample state/value, wildcard/explicit package imports, optional local shadow and five wildcard/named/qualified/constant connections; 39 cases check source selection, child defaults, live updates and scope isolation |
| `interaction_memfile` | 21 | Width, source/target bit/logic, plain/enum words, known/X/Z, binary/hex, full/middle/single ranges, declaration and read direction; 36 cases check snapshots, independent input, guards, overwrite and comment-aware address checks |
| `interaction_program` | 24 | Natural/direct/task exit, one/two initials, delay/event/level waits, children/grandchildren, partial progress, join_none/join_any and independent program lifetimes; 18 cases check cancellation, live counterparts and implicit finish |
| `interaction_nettype` | 22 | Six default net keywords, widths through 129 bits, ANSI/non-ANSI declarations, implicit/explicit vector wire, binary/four-state drivers and two reset forms; 40 cases compare resolved values and scalar/vector widths before and after the directive reset |
| `interaction_ifgenerate` | 27 | Per-element interface widths, one/two/three generate elements, if/case-selected routes, whole/modport access, bit/logic and known/X/Z data; 36 cases check active/guard identity, conversion order, widths and reader bindings |
| `interaction_reactive` | 24 | Width/state/value, one/two/three module NBA stages, blocking/NBA source updates, continuous/blocking/NBA program producers and direct/inverted output; 36 cases compare early/settled values, reservation counts, sampled context and readback before Re-NBA updates |
| `interaction_struct` | 7 | Member order, whole/member signs, width/state/value, member/whole writes and blocking/NBA updates; 36 selected cases check tag preservation, packed layout and independent sign extension |
| `interaction_case` | 12 | Selector/item widths and signs, case/casez/casex, X/Z and item patterns; 36 selected cases check exact/wildcard matching, duplicate-item priority and fallback branches |
| `interaction_port` | 23 | Source width/sign/value, input/output, sink width, named/positional binding, ANSI/non-ANSI declaration and sample state; 36 selected cases check values through hierarchy and final sampling conversion |
| `interaction_array` | 7 | Equivalent array element types, width/sign/state, source/destination index order, value and whole/slice copy; 36 cases observe declaration order, source independence and an untouched guard element |
| `interaction_query` | 20 | Width, state, argument shape, value/position and countbits controls; 60 cases check bit counts, one-hot/unknown predicates and duplicate controls |
| `interaction_stream` | 11 | Width, direction, slice size, tag, pack/unpack, target state and value; 36 cases check partial blocks and inverse unpack permutations |
| `interaction_compare` | 11 | Operand widths/signs, ten comparison operators and known/X/Z patterns; 100 cases check extension, asymmetric wildcards and one-bit results stored into wider logic/bit variables |
| `interaction_method` | 7 | Element width/state/sign, fixed/dynamic/queue storage, five reduction methods and four conversion forms; 72 cases check conversion before reduction, overflow and return-type extension |
| `interaction_index` | 11 | Width, range origin/direction, bit/logic, index sign/class and write value; 44 cases check variable reads/writes, invalid-access defaults and preservation of other bits |
| `interaction_queue` | 7 | Element width/state/sign, capacity, initial size, six operations and value; 48 cases check ordering, overflow warnings/discard, empty-pop defaults and independent copies |
| `interaction_queue_ref` | 7 | Width/state, capacity, held position, ten operations and known/X/Z writes; 60 cases check persistent element identity, outdated references after removal or replacement, two writes and independent value copies |
| `interaction_divide` | 11 | Operand widths/signs, assignment width/state, division/remainder and zero/X/Z values; 72 cases check rounding toward zero, remainder signs and context before final conversion |
| `interaction_resize` | 7 | Element width/state/sign/value, old/new sizes and copy/self/reset construction; 38 cases check retained prefixes, type defaults, truncation and independent copies |
| `interaction_concat` | 11 | Total/split/RHS widths, source/member signs, mixed bit/logic fields, blocking/NBA and known/X/Z values; 72 cases check resizing before partition, per-field conversion, capture and member/concatenation extension |
| `interaction_logic` | 11 | Width, input/result state, expression shape, value and position; 70 cases each observe six packed reductions and logical negation, controlling bits, state conversion order and unsigned one-bit result extension |
| `interaction_shortcircuit` | 11 | Operand widths/states/truth classes and result state; 92 cases each check four binary logical operators, call counts, independent side effects, X/Z truth and conversion order |
| `interaction_edge` | 9 | Width/state, event expression, changed position, before/after values and blocking/NBA; 64 cases each observe both backgrounds and three event counts after setup has settled |
| `interaction_iff` | 9 | Event OR spelling, signal/named/mixed sources, edge, guarded term, known/X/Z/mixed guards and blocking/NBA; 27 cases check per-term filtering, guard-only silence and repeated named triggers |
| `combination_events` | 6, 9, 15 | Nine mechanism-boundary cases for automatic event lifetimes, returned/selected event handles, computed event controls, `iff`, deferred triggers and named-fork cleanup |
| `combination_nba` | 10, 13 | Sixteen mechanism-boundary cases for delayed/event-controlled NBA through `ref static`, captured indices and values, string characters and array-slice copyback |
| `combination_aggregates` | 6, 11, 13 | Eighteen mechanism-boundary cases for unpacked-structure references and lifetimes, array input copies, nested packed selections and streaming into strings/nested targets |
| `combination_io` | 9, 10, 21 | Thirteen mechanism-boundary cases for `$fread` destinations and byte order, heap-backed implicit sensitivity and VCD contents read back inside SV |
| `combination_monitors` | 21 | Eighteen selected cases for `heap_file_monitor_context@1`: registration context × queue/dynamic array × MCD/FD; file readback checks Postponed values, selectors, size, replacement, `$monitoroff` independence and cancellation after close |
| `width_sign` | 11 | Operands and targets of 63 to 1000 bits, signed and unsigned, with the operators whose result size and sign 11.6 to 11.8 decide |
| `xz_propagation` | 11 | Operands with x and z bits for every operator of 11.4 that has rules for them |
| `strength` | 28 | Two drivers of a net with different strengths and values, on wire, tri, wand, triand, wor, trior, tri0 and tri1 nets and through bufif gates, shown with `%v` |
| `wide_paths` | 6, 7, 11, 13 | Values of 63, 64, 65, 127, 128, 129 and 200 bits, 2-state and 4-state with x and z above bit 64, signed and unsigned, on the paths a value takes: assignments to wider, narrower and 2-state targets, part-selects and slices of packed arrays and writes to them, concatenation, replication, shifts past the width, comparisons and `?:` with an x condition, `$bits`, and function results, task inputs, output and ref arguments; shown with `%h`, `%b` and `%0d` |
| `keywords` | 5, 22 | Illegal designs: each reserved keyword of IEEE 1800-2023 (Annex B) declared as a variable name under ``begin_keywords "1800-2023"``, and each keyword that a version of 22.14 adds declared so under ``begin_keywords`` of that version; a tool has to reject the declaration |

<a id="lyraの所要時間の記録"></a>

## Lyra runtime records

Earlier hosted-runner observations recorded 42–89 minutes for an uncached Bazel build including LLVM and 35–70 minutes for the test execution. These were historical timings retained from the README during its 2026-11-01 reorganization, not current runtime guarantees. Current execution and cache behavior is described in the [README](../README.md#workflows).

<a id="機能間クロス検証の補助証跡"></a>

# Auxiliary evidence for cross-functional verification

[English](README.en.md) / [日本語](README.md)

This directory stores records of fixed-version verification-source selection, independent recalculation, minimal examples, fault injection, and build-version checks. See [ `interaction-results/` ](../interaction-results/) for regression runs matching the current inputs and [Interaction verification report](../../docs/interaction-coverage.en.md) for qualification status. The number of normal and fault conditions of the auxiliary evidence is not added to the number of suites that pass and the requirement coverage. The record of the input hash that has become old is kept as a history, and the re-verification is recorded separately without being written over to the new hash. The "latest" build is the one at the time of verification of each record. Please check the commit and the time.

<a id="固定リリースの確認元選別"></a>

## Selecting verification sources from fixed releases

`20261029-query/` is a JSON with pre-confirm and re-execution in Icarus Verilog 13.0. The first run executed 132 cases for the additional 3 models; the following 5 runs executed 60 cases for the bit-vector-function model. The match counts for these 60 cases are 54, 52, 55, 56, 53, and 54, respectively; 51 cases matched in all 6 runs. Results varied for 9 concatenation/replication-expression cases wider than 64 whose argument width is not a multiple of 32.

Do not register the Oracle of Icarus on this 9 item. The 2 value case that matches both seeds of Verilator is verified by Verilator, and the rest is maintained as the expected value based on the specification. It is not a record to exclude from the denominator of the model or to relax the expected value.

Later, in [Ubuntu 24.04 environment for Check](https://github.com/kurochan001/kirimasim-tests/actions/runs/40893253924), `$countones` differences also appeared in 12 cases that had matched in the local 6 runs. [Failed line excerpt](20261029-query-linux-check.log) is saved with the commit and job URL from that time. The argument widths of the 12 added cases are 2, 33, and 34 bits. Together with the preceding 9 cases, no Icarus oracle is registered for the 21 cases whose argument width after concatenation/replication is not a multiple of 32. Mark the remaining 39 cases as verified with Icarus. The 12 item is classified as a 4 value case and is excluded from the verification object of Verilator. Do not relabel it as verified with Verilator; retain standard-only status.

JSON preserves the input hash before adding the oracle metadata and the difference comment. Do not use for current run coverage. Rerun against the current source and save the results separately in [ `interaction-results/` ](../interaction-results/). Do not overwrite the hash of JSON to the current value.

<a id="複合シフト代入の確認"></a>

## Verify the assignment of the compound shift

[ `20261030-compound-shift.json` ](20261030-compound-shift.json) stores the upstream commit of kirimasim checked at execution start, binary fingerprints before/after the build, independent expected-value checks, fault injection evaluating the left-hand-side index 2 times, and detailed output for both seeds of 2 Verilator part-select cases. The source of the fault injection is not adopted for the regression test, but for the detection confirmation. This file will not be added to your current pass score. Rerun the check if the input changes.

<a id="集合所属判定の確認"></a>

## Checking set membership

[ `20261030-inside.json` ](20261030-inside.json) contains evidence of the kirimasim build version and binary fingerprint checked immediately before execution, a 2/3-bit minimal example comparing arrays/individual enumeration/direct comparison, bit / logic and signedness controls, and fault injection that reads only the first individually enumerated element. The implementation inconsistency and the inspector fault detection are saved separately and are not added to the normal execution coverage. The current regression result is `interaction-results/cross27-*.json`.

[ `20261030-inside-fc4cc356.json` ](20261030-inside-fc4cc356.json) is a re-verification of the same day. The binary fingerprint of the build of the upstream main `fc4cc356` verified just before execution, the rerun of the 2 minimum instance above, the additional minimum instance with the value and number of elements changed on the left, the same comparison evaluated as a constant, the output of the kirimasim of the handwritten test [ `test_inside_array_set_mixed_sign_width` ](../../tests/ch11/test_inside_array_set_mixed_sign_width.sv) and the output in the seed 1 and 73 of the Verilator 5.052 are saved. In the additional minimal examples, array-form results shift in opposite directions for left-hand sides `111` and `011`, showing that the array's signed elements are sign-extended for comparison. The comparison evaluated as a constant is as expected.

<a id="範囲指定の確認"></a>

## Checking range specifications

[ `20261030-range.json` ](20261030-range.json) is the verification record of `membership_range@1`. The binary fingerprint of the build of the upstream main `f303beca`, which was verified just before execution, the independent expected value comparison method, a small example of the range with `$` as the endpoint, and the output in the seed 1 and 73 of the kirimasim and Verilator 5.052 are saved. kirimasim is as expected, while Verilator is the same result but different from the expected value for both seeds. The number of cases of output changes is also recorded for the 7 type of fault injections, which replaced one rule of the reference model by an error one by one. The fault injection is for the detection power verification, and it is not added to the normal suite or execution coverage. The current regression result is `interaction-results/cross28-*.json`.

<a id="case-insideの確認"></a>

## Check case inside

[ `20261030-case-inside.json` ](20261030-case-inside.json) is the verification record of `case_inside_selection@1`. Stores the build version/binary fingerprint of upstream main `f303beca` checked immediately before execution, independent expected-value checks, a 2/3-bit minimal example comparing a signed-array item with an equal-valued item and its kirimasim output, kirimasim output from the mismatching generated test, and the minimal example's build failure with Verilator 5.052. The number of cases where the observation changes is also recorded for the 7 type of fault injections which replaced the rules of the reference model one by one with errors. The fault injection is for the detection power verification, and it is not added to the normal suite or execution coverage. The current regression result is `interaction-results/cross29-*.json`.

<a id="イベントorとiffの確認"></a>

## Checking events OR and iff

[ `20261031-event-iff.json` ](20261031-event-iff.json) is the verification record of `event_or_iff@1`. On kirimasim `17b7192b4f05`, whose version was checked against upstream main, all 4 selected lines agreed; all 7 error types were detected through output differences: confusing conditions, incorrectly conditioning both terms, omitting the right term, waking on a condition, rejecting a mix of known 1 and X, omitting repeated named-event triggers, and making NBA immediate. The original generator, the verification tool, the fingerprint of the SV and the expected values, each change and the judgement are saved. The fault injection is not added to the number of items and the execution coverage of the normal suite.

Immediately before rechecking, fetch/build the latest upstream and confirm version agreement, then run as follows. Please specify a new filename without overwriting the past evidence.

```sh
python3 tools/qualify_event_iff.py --kirimasim BIN --commit VERIFIED_COMMIT \
  --json coverage/interaction-qualification/NEW-event-iff.json
```

The common save executions are `interaction-results/cross30-kirimasim-17b7192b.json` and `interaction-results/event-or-iff-20261031-*.json`.

<a id="キュー要素の参照の確認"></a>

## Checking references to queue elements

[ `20261031-queue-ref.json` ](20261031-queue-ref.json) is the verification record of `queue_element_reference@1`. With kirimasim `29ad73153518` whose build was checked against upstream main, 4 selected positive controls matched, and 8 fault types were detected: selecting the wrong element, passing by value, replacing a method with whole-object assignment, omitting writes, incorrectly retaining references after whole-object assignment, writing from a deleted reference into the current queue, omitting capacity limits, and converting logic input to bit. Syntax errors, non-supported, and abnormal termination are not counted as fault detection. Saves build and binary, generator, verification tool, SV and expected value fingerprint, changes and judgements. The fault injection is not added to the normal execution coverage.

After you get the latest upstream and build and compare the versions, you can specify a new save location and run again.

```sh
python3 tools/qualify_queue_ref.py --kirimasim BIN --commit VERIFIED_COMMIT \
  --json coverage/interaction-qualification/NEW-queue-ref.json
```

The common save executions are `interaction-results/cross31-kirimasim-29ad7315.json` and `interaction-results/queue-ref-20261031-*.json`. [ `20261031-queue-ref-verilator.json` ](20261031-queue-ref-verilator.json) records a rerun of the fixed version with identical options for 1 bounded-concatenation assignment cases that the normal runner recorded as producing no output. The build was successful and both seeds ended with SIGBUS. The source code has not been checked.

<a id="引数の結合と添字変更の確認"></a>

## Checking argument binding and index changes

[ `20261031-binding.json` ](20261031-binding.json) is the verification record of `argument_binding_index@1`. On kirimasim `a08e3489b8ab`, whose build version was checked against upstream main, all 4 selected positive controls agreed; detected all 8 error types: binding to the wrong element, passing ref by value, omitting ref writes, passing const ref by value, passing input by reference, omitting a later parent update, converting logic to bit, and corrupting guard elements. Syntax errors, unsupported behavior, and abnormal termination do not count as detection; detection is confirmed by output differences after normal termination. Save fingerprints of binaries, generators, verification tools, created SV and expected values, together with each mutation site and judgment. Failure injection is not added to the normal suite or execution coverage.

After you get the latest upstream and build and compare the versions, you can specify a new save location and run again.

```sh
python3 tools/qualify_binding.py --kirimasim BIN --commit VERIFIED_COMMIT \
  --json coverage/interaction-qualification/NEW-binding.json
```

The common save executions are `interaction-results/cross32-kirimasim-a08e3489.json` and `interaction-results/binding-20261031-*.json`.

<a id="mailboxのclassハンドルと別名経由の更新"></a>

## Mailbox class handles and updates through aliases

[ `20261101-mailbox.json` ](20261101-mailbox.json) is an auxiliary record of [ `mailbox_class_alias` ](../../docs/interaction-verification.en.md#mailboxのclassハンドルと別名経由の更新). With fixed Verilator 5.052, the required 6 known-value, typed cases matched as normal controls; output differences after normal termination detected 19 fault types, including FIFO, shared handles, bidirectional updates, capacity/null, and independence of separate mailboxes. Compilation errors and abnormal termination are not counted as fault detection. Typeless and X/Z are not subject to this fault injection.

[ `20261101-mailbox-build.json` ](20261101-mailbox-build.json) records the upstream commit, build version, and binary fingerprint of kirimasim checked immediately before the full regression, and preservation of the inputs/result categories of the existing 2,292 cases. [ `20261101-mailbox-prior-digests.json` ](20261101-mailbox-prior-digests.json) records the fingerprint of not changing the conventional product, save execution, model planning, and aggregation results. The auxiliary record is not added to the normal pass number.

```sh
python3 tools/qualify_mailbox.py --verilator verilator --seed 1 \
  --output coverage/interaction-qualification/NEW-mailbox.json
```

Please specify a new file as the output destination, which will not overwrite existing evidence.

<a id="イベント変数の再結合と登録済み待機の保持"></a>

## Re-association of event variables and retention of registered waits

[ `20261101-event-rebind-build.json` ](20261101-event-rebind-build.json) records agreement between the upstream and built versions of kirimasim used to run [ `event_rebinding` ](../../docs/interaction-verification.en.md#イベント変数の再結合と登録済み待機の保持), binary immutability, successful syntax and semantic analysis for 27 cases, and preservation of the inputs and result categories of the existing 2,328 cases. [ `20261101-event-rebind-prior-digests.json` ](20261101-event-rebind-prior-digests.json) fingerprints the existing 6,786 generated files, plans for 54 models, 157 saved runs, and existing model aggregates.

The behavior is unsupported by kirimasim and fails to build with fixed Icarus / Verilator, so there is no record that SystemVerilog fault injection ran successfully. The observational sensitivity to abstract errors of the 13 species confirmed by the independent reference model is not added to the number of fault detections in the run.

<a id="dpiの書戻しとnbaの確認"></a>

## DPI copyback and NBA checks

[`dpi-nba.json`](dpi-nba.json) records independent bit-string/C ABI checks of all 144 rows, a passing control and four faults detected by output differences.
[`dpi-nba-build.json`](dpi-nba-build.json) records the latest kirimasim commit verified before execution, the binary fingerprint, 18 successful parses and the full cross-run location.
Both fixed Verilator seeds have 14 pass and 4 known; the 18 new cases need unsupported C loading in kirimasim. Partial successes are not merged, and auxiliary experiments are not added to normal pass counts.
See [scope and reproduction](../../docs/interaction-verification.en.md#dpi-copyback-and-nba-capture).

<a id="継承制約と失敗時の値の保持の確認"></a>

## Constraint inheritance and failure-retention checks

[`constraint-inheritance.json`](constraint-inheritance.json) records independent named-block composition/candidate enumeration for all 96 rows, two passing controls and five faults detected by output differences.
[`constraint-inheritance-build.json`](constraint-inheritance-build.json) records the verified latest upstream kirimasim commit, binary fingerprint, 13 successful parses and full-run location.
Both fixed Verilator seeds pass all 13 cases; randomize is unsupported in kirimasim. Auxiliary experiments are not added to normal pass counts.
See [scope and reproduction](../../docs/interaction-verification.en.md#constraint-inheritance-and-failure-retention).

<a id="clocking変数とアサーションの確認"></a>

## Clocking-input and assertion checks

[`clockassert.json`](clockassert.json) records an independent time/region-history comparison for all 288 rows, two passing controls and five faults detected by output differences.
[`clockassert-build.json`](clockassert-build.json) records the verified latest upstream kirimasim commit, binary fingerprint, 18 successful parses and full-run location.
Both fixed Verilator seeds pass all 18 cases; concurrent assertions are unsupported in kirimasim. Auxiliary experiments are not added to normal pass counts.
See [scope and reproduction](../../docs/interaction-verification.en.md#clocking-inputs-and-assertion-clocks).

<a id="dpi-open-arrayの形状と書戻しの確認"></a>

## DPI open-array shape and copyback checks

[`dpi-array.json`](dpi-array.json) records independent checks of all 168 rows, the real C helper against a test ABI for all rows at two output initialization poisons, one passing control and five output-difference faults.
The ABI stub uses separated elements and canaries; it does not verify simulator marshalling of dynamic arrays or queues.
[`dpi-array-build.json`](dpi-array-build.json) records the latest-upstream-verified kirimasim version, binary fingerprint and all 30 parse outcomes.
The normal runner stops all 30 before execution for unsupported C loading; separate parsing accepts 24 and rejects 6 legal queue cases during type matching.
Both fixed Verilator seeds pass 18 static-array cases; 12 dynamic-array/queue cases have known build failures.
See [scope and reproduction](../../docs/interaction-verification.en.md#dpi-open-array-shape-and-copyback).

<a id="クラスの浅いコピーと配列の確認"></a>

## Class shallow-copy and array checks

[`class-array.json`](class-array.json) records an independent object-graph comparison for all 240 rows, two passing controls and six faults detected by output differences.
[`class-array-build.json`](class-array-build.json) records the latest-upstream-verified kirimasim version, binary fingerprint, 18 successful parses and full-run location.
Both fixed Verilator seeds pass all 18 cases; kirimasim passes 6 fixed-array cases and reports 12 unsupported dynamic-array/queue cases. Auxiliary experiments are not added to normal pass counts.
See [scope and reproduction](../../docs/interaction-verification.en.md#class-array-storage-and-shared-elements).

<a id="解決済み駆動強度の表示の確認"></a>

## Resolved-strength formatting checks

[`strength-format.json`](strength-format.json) records an independent drive-contribution/priority comparison for all 180 rows, three format-API controls and five faults detected by output differences.
[`strength-format-build.json`](strength-format-build.json) records the latest-upstream-verified kirimasim version, binary fingerprint, 31 successful parses and full-run location.
Fixed Icarus Verilog 13.0 passes all 31 cases. The addition-time unsupported-`%v` record for kirimasim `f2d9a1136576` is retained; current kirimasim `80859f34f0aa` passes all 31. Auxiliary experiments are not added to normal pass counts.
See [scope and reproduction](../../docs/interaction-verification.en.md#resolved-strength-formatting).

<a id="クラス内virtual-interfaceの再結合の確認"></a>

## Class-held virtual-interface rebinding checks

[`vif-class.json`](vif-class.json) records independent binding graphs for all 192 rows, three passing controls and six output-difference faults.
[`vif-class-build.json`](vif-class-build.json) records the latest-upstream-verified kirimasim version, binary fingerprint, 13 successful parses and full-run location.
Both fixed Verilator seeds pass all 13 cases; kirimasim reports unsupported class-held virtual-interface types. Auxiliary experiments are not added to normal pass counts.
See [scope and reproduction](../../docs/interaction-verification.en.md#class-virtual-interface-rebinding).

<a id="clocking-eventのiffとサンプル保持の確認"></a>

## Clocking-event iff and sample-retention checks

[`clockiff.json`](clockiff.json) records independent event queues for all 288 rows, three controls and six output-difference faults.
Two vector auxiliary controls use an explicit reduction-OR condition; their success is separate from the original cases.
[`clockiff-build.json`](clockiff-build.json) records the latest-upstream-verified kirimasim version, binary fingerprint, 12 successful parses and full-run location.
Each fixed Verilator seed passes 4 scalar-guard cases; 8 vector cases have known internal build errors. kirimasim reports unsupported guarded clocking events.
See [scope and reproduction](../../docs/interaction-verification.en.md#clocking-event-guards-and-held-samples).

<a id="連想配列問い合わせの独立検算"></a>

## Independent associative-query checks

[`assocquery.json`](assocquery.json) compares all 216 `associative_array_queries@1` rows with a separate entry list and boundary table.
Selected-case expectations distinguish six Python specification-model mutations. These are neither executed SystemVerilog faults nor successful simulator normal controls.
Both fixed Verilator seeds have output differences on all 18 cases; fixed Icarus rejects all 18 builds. No fixed oracle is added.
[`assocquery-build.json`](assocquery-build.json) records the latest kirimasim commit verified immediately before execution, build version, binary fingerprint and parse results.
All 18 parse successfully but encounter unsupported typed associative-array variables at runtime. Normal saved runs are `interaction-results/cross64-*.json`.
See [design and limits](../../docs/interaction-verification.en.md#associative-array-domains-and-allocation).

<a id="配列リダクション制約と補助対照"></a>

## Array-reduction constraints and auxiliary controls

[`randreduce.json`](randreduce.json) independently checks all 192 rows with literal endpoints and bit-serial arithmetic.
Four fixed-array auxiliary controls add an element-type cast only to the natural observation, preserving constraints and expected output. Seven faults produce output differences after normal termination.
These are neither original-case passes nor execution qualification of dynamic size retention. Both fixed Verilator seeds differ on all 13 original cases; fixed Icarus rejects the builds.
[`randreduce-build.json`](randreduce-build.json) records the upstream commit verified immediately before execution, build version, binary fingerprint and parsing.
All 13 parse: 8 fixed cases encounter unsupported randomize, and 5 dynamic cases encounter unsupported class-array operations. Normal saved runs are `interaction-results/cross65-*.json`.
See [design and limits](../../docs/interaction-verification.en.md#array-reduction-constraints-and-retention).

<a id="件数制限付きランダム比較の導入確認"></a>

## Bounded random comparison qualification

[`random-cross.json`](random-cross.json) records local validation on kirimasim `866abf4d86d1`, built after verifying upstream main immediately before execution.
Seeds 1/73 pass 96 cases each and seed 20261102 passes 256: 448 total. One saved-stimulus replay has byte-identical SV/expectations.
An intentional SV operator change terminates normally and is detected by output difference. Fixed Icarus Verilog 13.0 also matches 12 samples across the three profiles.
[`random-cross-manifest.json`](random-cross-manifest.json) retains the actual 96-case corpus.
Random runs, replay and fault injection do not increase fixed-suite counts or passing-model counts and are not successful GitHub Nightly execution.
See [scope, limits and replay](../../docs/random-cross-verification.en.md).

<a id="aggregate-event-lifetime-checks"></a>

<a id="構造体内イベントの寿命の独立検算"></a>

## Independent aggregate-event lifetime checks

[`eventlife.json`](eventlife.json) records independent interpretation of all 432 SV stimulus rows using objects, frames and an event queue, checked against expected output.
Eight source mutations produce interpreted output differences or stranded waits. These are not executed SV faults or successful runtime controls.
Fixed Icarus/Verilator reject all 18 builds; no oracle is added.
[`eventlife-build.json`](eventlife-build.json) records the upstream commit checked immediately before execution, build version, binary fingerprint, 18 successful parses and the full cross-run location.
kirimasim execution lacks event-value operations. See [design and limits](../../docs/interaction-verification.en.md#aggregate-event-lifetime).

<a id="sv-dpi-array-query-checks"></a>

<a id="svdpi配列問い合わせの独立検算と実行"></a>

## Independent SV/DPI array-query checks and execution

[`dpiquery.json`](dpiquery.json) records independent declaration/query checks for all 1,152 rows and 2,304 calls to the actual C probe through a test-owned ABI stub.
Synthetic shapes do not qualify simulator marshalling. Three original normalized-packed controls and six SV/C mutants all execute with exit zero; faults are detected through output differences.
These controls do not qualify offset-packed or open-packed execution. Normal fixed Verilator runs record 11 pass and eight known results.
[`dpiquery-build.json`](dpiquery-build.json) records the build checked against latest upstream, binary fingerprint, 19 successful parses and full cross-run location.
The kirimasim runner classifies C-backed tests as unsupported before execution, leaving DPI execution unconfirmed.
See [design and limits](../../docs/interaction-verification.en.md#sv-dpi-array-queries).

<a id="sdf-conditional-path-checks"></a>

<a id="sdf条件付きパスの検算と実行"></a>

## SDF conditional-path checks and execution

[`sdfpath.json`](sdfpath.json) records independent parsing/event-heap checks for all 288 emitted specify/SDF/stimulus rows.
Three original plain/ABSOLUTE controls and six SV/SDF mutants execute on fixed Icarus with exit zero; faults are detected through output differences.
Three COND/CONDELSE/INCREMENT mutations are interpreted only and are kept separate from runtime fault detection.
Normal fixed Icarus runs record three pass and 15 known results; both fixed Verilator seeds record 18 known results.
[`sdfpath-build.json`](sdfpath-build.json) records the upstream commit checked immediately before execution, build version, binary fingerprint, 18 successful parses and full cross-run location.
kirimasim execution lacks conditional paths or $sdf_annotate. See [design and limits](../../docs/interaction-verification.en.md#sdf-conditional-paths).

<a id="checker-assertion-sampling-checks"></a>

<a id="checkerサンプリングの独立検算と実行"></a>

## Independent checker-sampling checks and execution

[`checksample.json`](checksample.json) records independent region-model checks of all 1,296 emitted connection/clocking/stimulus rows.
Five original controls and seven SV mutants all execute with exit zero; faults are detected through output differences.
Two separate known-difference replays are not counted as controls or detected faults. A one-bit-vector same-slot NBA makes checker and module reference record the same old live value.
Both fixed Verilator seeds record 25 pass and two known results; fixed Icarus rejects all 27 builds.
[`checksample-build.json`](checksample-build.json) records the build checked against latest upstream, binary fingerprint, 27 successful parses and full cross-run location.
kirimasim execution lacks checker instances. See [design and common-error detection](../../docs/interaction-verification.en.md#checker-assertion-sampling).

[`checksample-m4.json`](checksample-m4.json) records seven matches and 44 explicit deferrals using existing M4 input traces.
The two new checker candidates remain source-hashed, reasoned M4 deferrals, separate from cross-specific checks or simulator replays.

<a id="program-assertion-attempt-checks"></a>

<a id="programアサーション試行の独立検算と実行"></a>

## Independent program-assertion attempt checks and execution

[`progassert.json`](progassert.json) records independent interpretation of all 648 emitted connection/stimulus/property/action rows.
Six original plain/overlapped controls and seven actual SV faults execute with exit zero; output differences detect faults.
Two known nonoverlapped replays are not controls or detected faults.
Both fixed Verilator seeds record 18 pass and nine known results. In the two separate replays, program and module both count a success before the first
next-cycle attempt completes, so independent attempt-start/completion expectations supplement implementation comparison.
[`progassert-build.json`](progassert-build.json) records upstream fetched immediately before execution, revision, binary hash,
parsing and full cross-run results. See [design and limits](../../docs/interaction-verification.en.md#program-assertion-attempts).

[`progassert-m4.json`](progassert-m4.json) records seven matches and 53 deferrals using existing input traces.
Nine new candidates receive source-hashed deferral reasons, not M4 passes or new simulator executions.

<a id="container-coverage-sampling-checks"></a>

<a id="コンテナ更新とsampleの独立検算実行"></a>

## Independent container-mutation and sample checks

[`cgsample.json`](cgsample.json) records separate interpretation of storage, copies, mutations, sample order, arguments, guards and bin histories for all 1,056 rows.
Six original controls and seven actual SV faults execute with exit zero; output differences detect faults.
Both fixed Verilator seeds match all 33 cases. Use a singleton empty-container bin and set at_least directly on each coverpoint.
Single-coverpoint groups expose percentages; coverpoint-query APIs, ref outputs and group-default inheritance are outside scope.
[`cgsample-build.json`](cgsample-build.json) records upstream fetched immediately before execution, revision, binary hash, 33 successful parses and full cross results.
kirimasim covergroup execution remains unsupported. See [design and limits](../../docs/interaction-verification.en.md#container-coverage-sampling).

<a id="deferred-disable-report-checks"></a>

<a id="disableと遅延報告の独立検算再現"></a>

## Independent disable/deferred-report checks and replays

[`deferdis.json`](deferdis.json) records independent AST/control-flow/per-process queue and input-capture checks for all 720 rows.
Six fixed-Verilator controls, seven SV faults and three known replays all exit zero; known differences are not controls or detected faults.
Both normal seeds record 13 pass and 18 known results. These controls do not qualify label cancellation, outer flushing or Reactive timing.
[`deferdis-build.json`](deferdis-build.json) records latest-upstream build/parsing of all 31 inputs, 26 pass and five label-cancellation failures.
[`deferdis-native.json`](deferdis-native.json) records a fresh-fetch/build replay of all five output differences, with complete outputs.
Other sites and input-evaluation counts match; four inner/task/outer/live controls pass. Only stderr execution paths are replaced for publication.
A separate empty-target-report cover control does not establish successful label cancellation.
See [design and limits](../../docs/interaction-verification.en.md#deferred-disable-reports).

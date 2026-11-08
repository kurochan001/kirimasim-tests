<a id="機能間クロス検証の補助証跡"></a>

# Auxiliary evidence for cross-functional verification

[English](README.en.md) / [日本語](README.md)

This directory stores records of fixed-version verification-source selection, independent recalculation, minimal examples, fault injection, and build-version checks. See [ `interaction-results/` ](../interaction-results/) for regression runs matching the current inputs and [Interaction verification report](../../docs/interaction-coverage.en.md) for qualification status. The number of normal and fault conditions of the auxiliary evidence is not added to the number of suites that pass and the requirement coverage. The record of the input hash that has become old is kept as a history, and the re-verification is recorded separately without being written over to the new hash. The "latest" build is the one at the time of verification of each record. Please check the commit and the time.

<a id="current-evidence-checkpoint"></a>

## Current evidence checkpoint (2026-11-06 JST)

The selection now contains 110 models / 4,416 cases; see [scoped-class, case-literal and structure-literal qualification](#scope-case-literal-qualification).
[`handoff-ci-67321079-20261106.json`](handoff-ci-67321079-20261106.json) records successful Check/Nightly workflows and all jobs on baseline 67321079. Individual artifacts remain uninspected; retain the older detailed checkpoints below separately.
[`check-9c39d865-20261106.json`](check-9c39d865-20261106.json) confirms Check’s pinned comparisons/static checks for the preceding 86-model suite.
[`formal-ci-19cd790a-20261105.json`](formal-ci-19cd790a-20261105.json) records an 82-model formal Nightly/publish and 96 random passes; these are separate runs.
The new 36 cases have not run in Check/Nightly. The 252 cases added since generated loops remain outside this earlier artifact-reviewed Nightly.

<a id="checkpoint-9926160a"></a>

## Previous formal evidence (2026-11-04 JST)

[`formal-ci-9926160a-20261104.json`](formal-ci-9926160a-20261104.json) records successful Check and Nightly on suite `9926160a`,
including successful publication. All 2,922 finite selected cases on kirimasim `9113955914d8` retain the input fingerprints and statuses
of cross79: 2,389 pass, 529 unsupported and four config failures; 52 full-selection-pass models across 114 mapped chapter pairs.
All 96 random cases across thirteen profiles are valid passes, separately from fixed-suite evidence.
The record hashes the original artifacts and verifies all saved random outputs; independent saved-SV interpretation covers 14 array and eight package programs.
These are read-only checks of existing evidence, not new simulator executions or additional coverage.
The fixed suite also records five ordinary specify-condition tests improving from unsupported to pass;
their identities and unchanged input fingerprints are recorded separately from the finite selection and ratchet gate.
The [previous checkpoint](formal-ci-e8d991a9-20261104.json) remains unchanged.
See the [current formal checkpoint](../../docs/nightly-results.en.md#latest-verified-checkpoint) for versions, times and workflow links.

Random development evidence remains dated and separate:

- Extension records and actual replay manifests: [five](random-cross-five-profiles.json) / [manifest](random-cross-five-profiles-manifest.json),
  [seven](random-cross-seven-profiles.json) / [manifest](random-cross-seven-profiles-manifest.json),
  [nine](random-cross-nine-profiles.json) / [manifest](random-cross-nine-profiles-manifest.json),
  [eleven](random-cross-eleven-profiles.json) / [manifest](random-cross-eleven-profiles-manifest.json),
  [thirteen](random-cross-thirteen-profiles.json) / [manifest](random-cross-thirteen-profiles-manifest.json).
- [Thirteen-profile stabilization](random-stabilization-20261103.json): 1,152 local passes, 864 independently interpreted saved array/package programs;
  288 packed-write programs use the existing execution/reference comparison. See [scope and commands](../../docs/random-cross-verification.en.md#thirteen-profile-stabilization).

The latest finite-model additions are [deferred arguments](deferarg.json), [generated enums](genenum.json),
[package NBA capture](pkgnba.json) and [package change observers](pkgwatch.json).
Each retains separate `*-build.json` and `*-fixed-replays.json` records in this directory.
Their designs, controls, fixed-release known differences and limits are in the [model guide](../../docs/interaction-verification.en.md).
Original failures and introduction-time uncommitted-build records below remain historical evidence.

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

<a id="class-method-package-lookup-checks"></a>

## Class method/package lookup qualification

[`classimp-final.json`](classimp-final.json) independently interprets all 3,264 legal emitted programs using declared types,
lexical imports, object identities and integer value/X/Z planes. Four native controls and eight actual SV faults
all terminate normally; output differences detect every fault. These are auxiliary checks, not extra suite passes.
[`classimp-build-final.json`](classimp-build-final.json) records a latest-main fetch/configure/build, 34 successful parses and
one complete 2,956-case native run: 2,423 pass, 529 unsupported and four existing config failures.
All 34 additions pass; the preceding 2,922 inputs and statuses are unchanged. Matrices use this single local snapshot,
with 80 models / 115 chapter pairs and 53 full-selection-pass models; formal CI still covers the preceding selection.
[`classimp-fixed-replays-final.json`](classimp-fixed-replays-final.json) identifies pinned Verilator seeds 1/73 (18 pass, 16 known each)
and pinned Icarus 13.0 (34 known build rejections), along with driver/runtime executable fingerprints.
Only the 18 non-fourstate cases matching both fixed Verilator seeds gain its oracle; other expectations are unchanged.
See [design, limits and rerun commands](../../docs/interaction-verification.en.md#class-method-package-lookup).

[`classimp-metadata-correction.json`](classimp-metadata-correction.json) preserves eight required four-state input-tag corrections. SV bodies/expectations are unchanged; earlier snapshots retain their old fingerprints and are not merged into final successes.

<a id="generated-subroutine-qualification"></a>

## Generated subroutine/array binding qualification

[`gensub.json`](gensub.json) independently elaborates and interprets all 2,304 legal emitted programs.
Four native controls and nine real SV faults terminate normally, and all faults are detected by output differences.
Source, input and binary fingerprints are stable across qualification. [`gensub-build.json`](gensub-build.json) identifies
latest-main core `162222153c57`, 36 successful parses and a single complete 2,992-case run:
2,459 pass, 529 unsupported and four existing config failures. All 36 additions pass; the preceding 2,956 inputs/statuses are unchanged.
At that addition, matrices used this run: 81 models, 117 chapter pairs and 54 full-selection-pass models.
[`gensub-fixed-replays.json`](gensub-fixed-replays.json) records pinned Icarus 13.0 (36 pass) and Verilator 5.052 seeds 1/73 (11 pass, 25 known each).
All 36 receive Icarus oracles; two-state observations are not four-state qualification.
[`gensub-known-replays.json`](gensub-known-replays.json) retains full original-task outputs and an
[exact function control](gensub-function-control/) with unchanged expectations. Only retained results differ in the original task case;
Icarus and both Verilator seeds match the function control. These controls are outside the fixed suite and add no pass or coverage counts.
See [design, limits and rerun commands](../../docs/interaction-verification.en.md#generated-subroutine-binding).

<a id="class-selection-qualification"></a>

## Class conditional-return qualification

[`classsel.json`](classsel.json) independently interprets the actual SV for all 1,296 legal rows.
The interpreter follows static/virtual dispatch, typed returns, X/Z merging, control flow and handle identity without primary reference helpers.
Five native controls and nine real SV faults all exit normally, with every fault detected by output difference.
[`classsel-build.json`](classsel-build.json) records a fresh main fetch/configure/build on `162222153c57`, 36 successful parses and
one full 3,028-case snapshot: 2,495 pass / 529 unsupported / four existing config failures. All new cases pass; all preceding 2,992 inputs/statuses are unchanged.
There are 82 models / 119 mapped pairs / 55 full-selection-pass models; 8×12 maps only the 24 if/case cases.
[`classsel-fixed-replays.json`](classsel-fixed-replays.json) identifies pinned Icarus (36 known class-handle-comparison build rejections)
and Verilator seeds 1/73 (12 pass / 24 known each). Only known-input passes obtain Verilator oracles.
[`classsel-known-replays.json`](classsel-known-replays.json) retains unchanged expectations, representative X outputs for both seeds,
Z build diagnostics and an Icarus rejection. Two-state observations do not validate X/Z behavior; external four-state confirmation remains unverified.
These are local/auxiliary records, separate from formal CI, fixed requirement coverage and the thirteen random profiles.
See [design, commands and limits](../../docs/interaction-verification.en.md#class-conditional-return).

<a id="generated-loop-qualification"></a>

## Generated-loop qualification

[`genloop.json`](genloop.json) independently elaborates and executes the actual SV for all 6,912 legal rows.
Five normal native controls and nine executable source faults validate private arrays, transfer targets, accumulation, clock edges and guards.
[`genloop-build.json`](genloop-build.json) identifies freshly fetched/built core `50a897dee62a`, 36 successful parses and one complete 3,064-case run:
2,531 pass / 529 unsupported / four existing config failures. All additions pass; all preceding 3,028 inputs/statuses are unchanged.
At that checkpoint, totals were 83 models / 121 chapter pairs / 56 full-selection-pass models.
[`genloop-fixed-replays.json`](genloop-fixed-replays.json) records Icarus 13.0 at 31 pass / five known and Verilator seeds 1/73 at 12 pass / 24 known each.
[`genloop-known-replays.json`](genloop-known-replays.json) retains all five repeat-count-one build rejections and two independent count-three controls;
[control SV/expectations](genloop-repeat-controls/) stay outside fixed tests. No expected value or failure record is replaced.
See [design, scope and rerun commands](../../docs/interaction-verification.en.md#generated-process-loop-transfer).

<a id="interface-query-qualification"></a>

## Interface-query qualification

[`ifquery.json`](ifquery.json) independently interprets actual SV declarations, queries, typed calls and walks for all 4,608 rows.
Five normal controls and nine real source faults execute natively, all exit normally and every fault is detected by output difference.
[`ifquery-build.json`](ifquery-build.json) identifies freshly fetched/built `50a897dee62a`, 36 successful parses and one complete 3,100-case run.
It records 2,567 pass / 529 unsupported / four existing config failures; all additions pass and preceding 3,064 inputs/statuses are unchanged.
Totals are 84 models / 124 chapter pairs / 57 full-selection-pass models.
[`ifquery-fixed-replays.json`](ifquery-fixed-replays.json) identifies Icarus 13.0 (36 pass), Verilator 5.052 seed 1 (12 pass / 24 known) and seed 73 (13 pass / 23 known).
Only the twelve known-input cases matching both seeds obtain Verilator oracles. The incidental bit/X match at seed 73 does not validate four-state behavior.
All 36 retain Icarus oracles. See [design, scope and commands](../../docs/interaction-verification.en.md#interface-array-query-walk).

<a id="generated-expression-qualification"></a>

## Typed-constant/generate qualification

[`genexpr.json`](genexpr.json) independently interprets all 6,912 actual SV programs, including typed constants, branches, loops and continuous assignments.
Five normal controls and nine real source faults all exit normally; every fault is detected by output difference.
[`genexpr-build.json`](genexpr-build.json) identifies freshly fetched/built `92001039e896`, 36 successful parses and one full 3,136-case snapshot.
It records 2,603 pass / 529 unsupported / four existing config failures; additions pass and preceding 3,100 inputs/statuses are unchanged.
Totals are 85 models / 126 chapter pairs / 58 full-selection-pass models. [Pinned comparisons](genexpr-fixed-replays.json) distinguish Icarus’s 36 pass from each Verilator seed’s 12 pass / 24 known.
Existing inputs/expectations are unchanged; two-state results do not qualify X/Z behavior. See [design and commands](../../docs/interaction-verification.en.md#generated-constant-expression-shape).

<a id="formatted-scan-qualification"></a>

## Formatted-scan qualification

[`scansel.json`](scansel.json) independently interprets actual strings/formats, stopping points and typed partial writes for all 5,760 rows.
Six normal controls and nine faults exit normally; every fault is detected by output difference. The [build record](scansel-build.json) identifies one full 3,172-case run:
2,639 pass / 529 unsupported / four existing config failures. All 36 additions parse/pass and preceding 3,136 inputs/statuses are unchanged.
[Pinned comparisons](scansel-fixed-replays.json) distinguish Icarus’s 17 pass / 19 known from each Verilator seed’s 3 pass / 33 known.
Preserve [all nineteen original differences and three Verilator examples](scansel-known-replays.json), plus [twelve separate literal controls](scansel-literal-controls/);
seven control matches do not replace original results. Totals: 86 models / 128 chapter pairs / 59 full-selection-pass models.
See [design, limits and commands](../../docs/interaction-verification.en.md#formatted-scan-partial-write).

<a id="program-task-frame-qualification"></a>

## Program/task-frame qualification

[`progframe.json`](progframe.json) independently interprets all 3,456 actual SV programs using typed private frames and event queues.
Six normal controls and nine executable faults exit normally; every fault is detected by output difference.
The [build record](progframe-build.json) identifies freshly fetched/built `6f5c69841228`, 36 successful parses and one complete 3,208-case run.
Totals are 2,675 pass / 529 unsupported / four existing config failures; all additions pass and preceding 3,172 inputs/statuses are unchanged.
[Pinned comparisons](progframe-fixed-replays.json) record Icarus at 6 pass / 30 known and Verilator at 36 known for both seeds.
Preserve [all thirty Icarus diagnostics and representative Verilator replays](progframe-known-replays.json), retaining original expectations.
Totals are 87 models / 130 chapter pairs / 60 full-selection-pass models. See [design, limits and reruns](../../docs/interaction-verification.en.md#program-task-frame-lifetime).

<a id="package-query-qualification"></a>

## Package-query qualification

[`pkgquery.json`](pkgquery.json) independently interprets actual arrays, types, lexical lookup, queries and scans for all 3,456 rows.
Six normal controls and nine executable faults exit normally; every fault is detected by output difference.
The [build record](pkgquery-build.json) identifies freshly fetched/built `6f5c69841228`, 36 successful parses and one complete 3,244-case run.
All additions pass and preceding 3,208 inputs/statuses are unchanged: totals are 2,711 pass / 529 unsupported / four existing config failures.
[Pinned comparisons](pkgquery-fixed-replays.json) record Icarus at 36 known, Verilator seed 1 at 12 pass / 24 known and seed 73 at 13 pass / 23 known.
Retain [all thirty-six Icarus diagnostics and representative X/Z outputs at both seeds](pkgquery-known-replays.json); an incidental bit/X match does not qualify four-state behavior.
Totals are 88 models / 131 chapter pairs / 61 full-selection-pass models. See [design, limits and reruns](../../docs/interaction-verification.en.md#package-array-query-scope).

<a id="event-loop-qualification"></a>

## Event-loop qualification

[`eventflow.json`](eventflow.json) interprets all 2,016 actual programs with independent Active/NBA queues, loop transfers, waiting and cancellation.
Six normal controls and nine faulty SV programs exit normally; every fault is detected by output difference.
The [build record](eventflow-build.json) identifies one complete 3,280-case run on `6f5c69841228`: 2,747 pass / 529 unsupported / four existing failures.
All 36 additions pass and preceding 3,244 inputs/statuses are unchanged. Totals: 89 models / 132 chapter pairs / 62 full-selection-pass models.
[Pinned comparisons](eventflow-fixed-replays.json) record Icarus at 36 known and Verilator at 8 pass / 28 known for both seeds.
Retain [original diagnostics/outputs](eventflow-known-replays.json) and [four separate blocking-trigger controls](eventflow-blocking-controls/).
Their eight Verilator matches do not qualify original NBA cases. See [design and reruns](../../docs/interaction-verification.en.md#named-event-loop-transfer).

<a id="time-literal-gate-qualification"></a>

## Time-scope, literal and gate-array qualification

[`timescope.json`](timescope.json) checks all 8,064 rows, [`literal.json`](literal.json) all 6,552 and [`gatearray.json`](gatearray.json) all 4,464 by independent interpretation.
Normal controls are five, six and six; faulty SV programs are nine each, all detected by an output difference after a normal exit.
The [build record](timelitgate-build.json) identifies one complete 3,445-case run on `60c26d7c8113`: 2,912 pass / 529 unsupported / four existing failures.
All 165 additions pass and preceding 3,280 inputs/statuses are unchanged. Totals: 92 models / 151 chapter pairs / 65 full-selection-pass models.
[Pinned comparisons](timelitgate-fixed-replays.json) record Icarus 144 pass / 21 known and Verilator 38 pass / 127 known at both seeds.
[All Icarus differences and representative Verilator outputs](timelitgate-known-replays.json) are retained.
The [all-row record](timelitgate-all-rows.json) is one run of all 19,080 rows and enters neither the fixed suite nor requirement coverage. It also records the correction of the literal expectation.
See the [design and rerun](../../docs/interaction-verification.en.md#time-scope-delay).

<a id="macro-force-sense-qualification"></a>

## Macro, force/release and implicit-sensitivity qualification

[`macro.json`](macro.json) checks all 7,679 rows, [`force.json`](force.json) all 2,160 and [`sense.json`](sense.json) all 630 by independent interpretation.
Normal controls are nine, eight and nine; faulty SV programs are ten, ten and nine, all detected by an output difference after a normal exit.
The [build record](macroforcesense-build.json) identifies one complete 3,692-case run on `97d5b0001e7c`: 3,159 pass / 529 unsupported / four existing failures.
All 247 additions pass and preceding 3,445 inputs/statuses are unchanged. Totals: 95 models / 168 chapter pairs / 68 full-selection-pass models.
[Pinned comparisons](macroforcesense-fixed-replays.json) record Icarus 192 pass / 55 known and Verilator 179 pass / 68 known at both seeds.
[All Icarus differences and representative Verilator outputs](macroforcesense-known-replays.json) are retained.
The [all-row record](macroforcesense-all-rows.json) is one run of all 10,469 rows and enters neither the fixed suite nor requirement coverage. kirimasim has no difference.
See the [design and rerun](../../docs/interaction-verification.en.md#macro-expansion-context).

<a id="interface-loop-literal-qualification"></a>

## Interface-expression, loop-control and literal-format qualification

[`ifexpr.json`](ifexpr.json) checks all 2,940 rows, [`loopsched.json`](loopsched.json) all 165 and [`litfmt.json`](litfmt.json) all 1,778 by independent interpretation.
Normal controls are seven, six and nine; faulty SV programs are seven, six and nine, all detected by an output difference after a normal exit.
The [build record](ifexprloopfmt-build.json) identifies one complete 3,887-case run on `6e32b04ed6ec`: 3,404 pass / 479 unsupported / four existing failures.
All 195 additions pass, preceding 3,692 inputs are unchanged, and 50 cases moved from unsupported to pass. Totals: 98 models / 173 chapter pairs / 74 full-selection-pass models.
[Pinned comparisons](ifexprloopfmt-fixed-replays.json) record Icarus 134 pass / 61 known and Verilator 188 pass / 7 known at both seeds.
[All Icarus differences and representative Verilator outputs](ifexprloopfmt-known-replays.json) are retained.
The [all-row record](ifexprloopfmt-all-rows.json) is one run of all 4,883 rows and enters neither the fixed suite nor requirement coverage. kirimasim has no difference.
Icarus cannot parse interface ports, so all rows of the interface and loop models also ran once on Verilator.
See the [design and rerun](../../docs/interaction-verification.en.md#interface-member-expression).

<a id="param-assert-literal-qualification"></a>

## Parameter-override, assertion-query and literal-argument qualification

[`paramtype.json`](paramtype.json) checks all 252 rows, [`assertquery.json`](assertquery.json) all 450 and [`litarg.json`](litarg.json) all 472 by independent interpretation.
Normal controls are eight, six and eight; faulty SV programs are eight, six and eight, all detected by an output difference after a normal exit.
The parameter controls avoid the `defparam` rows that kirimasim gets wrong; those rows appear as failures of selected cases.
The [build record](paramassertlit-build.json) identifies one complete 4,023-case run on `eee8cd16ba1d` (3,536 pass / 479 unsupported / eight fail) and keeps the reasons of the four new failures.
Preceding 3,887 inputs and statuses are unchanged. Totals: 101 models / 177 chapter pairs / 76 full-selection-pass models.
[Pinned comparisons](paramassertlit-fixed-replays.json) record Icarus 111 pass / 25 known and Verilator 111 pass / 25 known at both seeds.
[All Icarus differences and representative Verilator outputs](paramassertlit-known-replays.json) are retained.
The [all-row record](paramassertlit-all-rows.json) is one run of all 1,174 rows and enters neither the fixed suite nor requirement coverage. kirimasim differs only on the 24 parameter rows.
To cover rows that Icarus does not accept, all rows of the parameter and literal-argument models also ran once on Verilator.
See the [design and rerun](../../docs/interaction-verification.en.md#parameter-override-type).

<a id="hier-array-qualification"></a>

## Hierarchical-process-control, %m and array-query-loop qualification

[`hierproc.json`](hierproc.json) checks all 252 rows, [`hiername.json`](hiername.json) all 177 and [`arrayloop.json`](arrayloop.json) all 440 by independent interpretation.
Each has seven normal controls and seven faulty SV programs, all detected by an output difference after a normal exit.
The [build record](hierloop-build.json) identifies one complete 4,170-case run on `28c6c1a1cb83` (3,683 pass / 479 unsupported / eight fail). All 147 additions pass.
Preceding 4,023 inputs and statuses are unchanged, and the failures are the same four config and four `defparam` cases as before. Totals: 104 models / 181 chapter pairs / 79 full-selection-pass models.
[Pinned comparisons](hierloop-fixed-replays.json) record Icarus 95 pass / 52 known and Verilator 136 pass / 11 known at both seeds.
[All Icarus differences and representative Verilator outputs](hierloop-known-replays.json) are retained. The one Icarus run that never ends is cut at 60 seconds and recorded so.
The [all-row record](hierloop-all-rows.json) is one run of all 869 rows and enters neither the fixed suite nor requirement coverage. kirimasim has no difference.
To cover rows that Icarus does not accept, all rows of the three models also ran once on Verilator.
See the [design and rerun](../../docs/interaction-verification.en.md#hierarchical-process-control).

<a id="delay-package-escape-qualification"></a>

## Delay-value, package-lookup and escaped-name qualification

[`delayval.json`](delayval.json) checks all 222 rows, [`pkglookup.json`](pkglookup.json) all 148 and [`escname.json`](escname.json) all 126 by independent interpretation.
Each has seven normal controls and seven faulty SV programs, all detected by an output difference after a normal exit.
The [build record](delaypkgesc-build.json) identifies one complete 4,296-case run on `28c6c1a1cb83` (3,809 pass / 479 unsupported / eight fail). All 126 additions pass.
Preceding 4,170 inputs and statuses are unchanged, and the failures are the same four config and four `defparam` cases as before. Totals: 107 models / 185 chapter pairs / 82 full-selection-pass models.
[Pinned comparisons](delaypkgesc-fixed-replays.json) record Icarus 126 pass, and Verilator 112 pass / 14 known at seed 1 and 109 pass / 17 known at seed 73.
Icarus has no difference, and the Verilator known results are only x and z delays read as two-state values, so the representative outputs in the [replay record](delaypkgesc-known-replays.json) are empty.
The [all-row record](delaypkgesc-all-rows.json) is one run of all 496 rows and enters neither the fixed suite nor requirement coverage. kirimasim and Icarus have no difference.
See the [design and rerun](../../docs/interaction-verification.en.md#delay-value-form).

<a id="scope-case-literal-qualification"></a>

## Scoped-class, case-literal and structure-literal qualification

[`scopeclass.json`](scopeclass.json) checks all 240 rows, [`casedigit.json`](casedigit.json) all 312 and [`agglit.json`](agglit.json) all 192 by independent interpretation.
Each has seven normal controls and seven faulty SV programs, all detected by an output difference after a normal exit. The normal controls are rows that kirimasim passes.
The [build record](scopecaselit-build.json) identifies one complete 4,416-case run on `f029ddd0eee1`, built from the latest main (3,915 pass / 487 unsupported / 14 fail). 106 of the 120 additions pass.
The six new failures are the class internal error, and the eight unsupported cases are structure localparams. Preceding 4,296 inputs and statuses are unchanged. Totals: 110 models / 189 chapter pairs / 83 full-selection-pass models.
[Pinned comparisons](scopecaselit-fixed-replays.json) record Icarus 29 pass / 91 known, and Verilator 63 pass / 57 known at both seeds 1 and 73.
The [replay record](scopecaselit-known-replays.json) keeps all 91 Icarus results and representatives of the Verilator differences on two-state inputs.
The [all-row record](scopecaselit-all-rows.json) is one run of all 744 rows and enters neither the fixed suite nor requirement coverage.
kirimasim matches every case item row; 30 class rows stop on an internal error and 48 structure localparam rows are unsupported. Verilator matches all 240 class rows.
See the [design and rerun](../../docs/interaction-verification.en.md#scoped-class-declaration).

<a id="kirimasim-testsのfaq"></a>

# kirimasim-tests FAQ

[日本語](faq.md) / [README](../README.md)

This FAQ explains tests, expectations, Nightly, coverage, SVA/formal verification and checks after changes. See the [glossary](glossary.en.md) for terminology and the [README](../README.md) for an overview and commands.

Its scope is kirimasim-tests. Simulator design and installation, and general LSI verification methods, have their own documentation. Changing test counts and percentages are linked to their reports rather than repeated here.

<a id="目次"></a>

## Contents

- [Getting started](#1-getting-started)
- [Expectations and metadata](#2-expectations-and-metadata)
- [Reading Nightly results](#3-reading-nightly-results)
- [Requirements and coverage](#4-requirements-and-coverage)
- [SVA and formal verification](#5-sva-and-formal-verification)
- [Changes and evidence](#6-changes-and-evidence)
- [Feature interactions](#7-feature-interactions)
- [Commercial simulators](#8-commercial-simulators)
- [Model-based random comparisons](#model-based-random-comparisons)

<a id="1-導入と実行"></a>

## 1. Getting started

<a id="q1-このリポジトリは何を検査するものですか"></a>

### Q1. What does this repository test?

It tests whether SystemVerilog simulators follow IEEE 1800-2023. Small designs receive inputs, and their outputs, diagnostics and termination conditions are compared with expectations. Besides kirimasim, the suite provides Icarus Verilog, Verilator, Lyra and Ghost runners, and a SymbiYosys formal runner. It is not a product RTL verification environment or a distribution of the simulator itself. See the [overview](../README.md) and [execution instructions](../README.md#running-the-suite).

<a id="q2-どこから読み始めればよいですか"></a>

### Q2. Where should I start?

Use [Running the suite](../README.md#running-the-suite) to execute tests, the [catalog](tests/README.md) to find individual tests, and the [Nightly guide](nightly-results.en.md) to read results. The [requirements-to-tests method](requirements-to-tests-method.en.md) explains the path from standard requirements to tests and evidence.

<a id="q3-まず1本だけ実行できますか"></a>

### Q3. Can I run just one test?

Pass its path to a runner. For example, set `IVERILOG13_BIN` to the directory containing Icarus Verilog 13.0's `iverilog` and `vvp`, then run this from the repository root:

```sh
python3 tools/run_icarus.py --iverilog-bin "$IVERILOG13_BIN" \
  tests/ch10/test_nonblocking_assign.sv
```

The runners require Python 3.10 or later. They also accept multiple paths, `-j N` for concurrency and `--json FILE` for evidence. Simulator and C build prerequisites vary; check [each runner's requirements](../README.md#running-the-suite) before running the full suite.

Icarus, Verilator, kirimasim, Lyra and Ghost exclude `:type: formal` even when a test is explicitly named. Without paths, Icarus, kirimasim, Lyra and Ghost select all remaining tests, while Verilator selects tests with the `verilator@5.052` oracle. Its `--all` selects every non-formal test. Formal tests name a `:formal_case:` and use `tools/run_sby.py`; see [SymbiYosys](../README.md#symbiyosys).

<a id="2-期待結果とメタデータ"></a>

## 2. Expectations and metadata

<a id="q4-期待出力はシミュレータの結果をコピーして決めていますか"></a>

### Q4. Are expected outputs copied from a simulator?

Expectations are derived from the cited clauses first. A fixed simulator release is recorded in `:oracle:` when it confirms them. A disagreement requires investigating the test, interpretation and implementation; agreement between tools alone does not decide correctness. See [expectation policy](../README.md#where-the-expected-outputs-come-from).

Comparison removes empty lines and selected tool banners, but does not collapse spaces on nonempty lines. Whitespace differences can therefore fail. Check [normalization](../tools/normalize_output.py) and the banners each runner removes.

<a id="q5-oracle-specだけならそのテストは信用できないのでしょうか"></a>

### Q5. Is a test with only `:oracle: spec` unreliable?

Its expectation is standard-derived, but no fixed-release confirmation is recorded. Unsupported features or tool deviations can explain this. Review its cited clauses, opening explanation, observations and `:spec_check:`. The `spec` label itself does not guarantee a correct expectation. See [metadata](../README.md#metadata) and [fixed-release differences](simulator-differences.md).

<a id="q6-固定バージョンとnightlyの開発版はなぜ分けるのですか"></a>

### Q6. Why distinguish fixed releases from Nightly development versions?

Fixed releases reproduce recorded oracle results; development versions track new support and regressions. A different release does not inherit `iverilog@13.0`, and a Nightly match is not confirmation by that fixed release. Verilator 5.052 oracle checks also vary the initialization seed. See [expectations](../README.md#where-the-expected-outputs-come-from) and [workflows](../README.md#workflows).

<a id="q7-規格違反のコードなら何らかのエラーが出れば合格ですか"></a>

### Q7. Does any error make an illegal-design test pass?

The rejection must detect the intended violation. An earlier syntax error or unsupported-feature rejection does not establish that. Review whether a diagnostic belongs at the declaration, use or elaborated location, and encode valid locations and required diagnostic content. Matching a line alone can create false passes, so oracle registration requires diagnostic review. See [judging tests](../README.md#how-a-test-is-judged) and [diagnostic corrections](nightly-suite-corrections-20261027.en.md).

<a id="q8-fourstate-yesをverilatorだけで確認できますか"></a>

### Q8. Can Verilator alone confirm `:fourstate: yes`?

This suite uses the fixed Verilator oracle for tests that do not depend on X/Z. Two-state execution does not equivalently validate operators, branches or nets involving unknown and high-impedance values. Inspect `:fourstate:` and the actual observations. See [metadata](../README.md#metadata) and [Verilator conditions](../README.md#verilator).

<a id="3-nightlyと結果の見方"></a>

## 3. Reading Nightly results

<a id="q9-matchdifferknown-differenceunsupportedは何が違いますか"></a>

### Q9. What do Match, Differ, Known difference and Unsupported mean?

Match meets the expected result; Differ fails a judgment condition. Known difference separates mismatches without an Icarus/Verilator fixed-release oracle and is not success. kirimasim also uses it when only another simulator's expectation exists, without a common or kirimasim-specific expectation. Unsupported identifies recognized unsupported features or test kinds the runner cannot execute. An unrecognized unsupported-feature build failure may instead be Differ. Compare [definitions](../README.md#result-statuses) and individual logs, not just similarly named columns.

Match includes correctly rejected illegal designs. Terminal summaries for Icarus/Verilator use fixed-oracle tests as their denominator; `--json` can record `pass` for a mechanically matching test without an oracle, and Nightly counts it. Icarus prints `NOW MATCHES` for such matches; this does not automatically certify an oracle.

<a id="q10-differの件数はそのシミュレータのバグ数ですか"></a>

### Q10. Is the Differ count the simulator's bug count?

It counts failing tests. One defect may affect many tests, and a test may have a wrong expectation, illegal source or inappropriate diagnostic condition. Check the standard and isolate the cause before reporting a defect. The [Nightly correction record](nightly-suite-corrections-20261027.en.md) separates test-diagnostic fixes from simulator issues.

<a id="q11-nightlyが緑なのにdifferが残るのはなぜですか"></a>

### Q11. Why can Nightly be green with Differ results?

Nightly records support status and does not require every test to match. kirimasim's current ratchet fails when a previous `pass` becomes `fail`. New tests and existing failures do not themselves trigger that regression rule. A separate Check workflow maintains fixed oracles and registry consistency; see [workflows](../README.md#workflows).

This describes fixed-suite aggregation. Additional [random comparisons](random-cross-verification.en.md) require every case to be a valid pass; unsupported features and timeouts are not successes. A separate artifact retains replay evidence outside fixed-suite results.

The current ratchet also excludes `pass` to `unsupported` transitions. Review status changes and logs alongside the green workflow indicator.

<a id="q12-readmeのby-chapterの割合は何を表しますか"></a>

### Q12. What percentage does By chapter show?

For each chapter and simulator, it divides matching tests in that simulator's latest saved result by tests recorded in that result. Dates, suite revisions and simulator versions may differ between environments. Known differences and unsupported tests remain in the denominator, including C-backed tests skipped as unsupported. The chart identifies the date and versions, and the [published report](https://github.com/kurochan001/kirimasim-tests/tree/results#readme) links the suite commit. This is not requirement coverage. See [By chapter](../README.md#by-chapter).

<a id="q13-mainへpushしたのにグラフや件数が変わりません"></a>

### Q13. Why did graphs or counts not change after a main push?

A main update and Nightly publication are separate. A workflow must run that change and publish its results. The scheduled start is 04:23 JST daily, but queueing, delays and builds affect publication. Report timestamps are UTC; add nine hours for JST. Check the suite commit, counts, simulator jobs and publish job. See [update timing](nightly-results.en.md).

<a id="q14-mainとresultsまたは各シミュレータで集計が違うのはなぜですか"></a>

### Q14. Why do main, results or simulator totals differ?

main contains current tests, tools and saved evidence; results represents published Nightly runs. Commits, versions, counts and recorded scope may differ. `latest/<simulator>.json` is each environment's last result, so failed jobs can leave different runs represented. Filling a missing environment with an earlier success does not make that run successful. See [main versus Nightly measurement](../coverage/README.en.md#mainの集計とnightlyの集計).

<a id="4-要求とカバレッジ"></a>

## 4. Requirements and coverage

<a id="q15-nightlyの一致率と要求カバレッジは同じですか"></a>

### Q15. Is the Nightly match rate requirement coverage?

They use different denominators. Nightly counts test files. Requirement coverage counts registered requirements, conditions and observations with reviewed mappings or admissible pass evidence. One test may cover multiple requirements, and several tests may jointly cover one requirement. See the [summary](behavior-coverage-summary.en.md) and [measurement policy](../coverage/README.en.md#計測の意味).

<a id="q16-要求カバレッジテスト設計と実行確認率は何が違いますか"></a>

### Q16. How do design and execution coverage differ?

Design coverage counts requirements with reviewed mappings to test observations. Execution coverage counts requirements with admissible pass evidence matching current inputs and runners. For illustration, 60 mapped requirements and 40 with passes out of 100 produce 60% and 40%. A union of environments is not one simulator's conformance rate. The [summary](behavior-coverage-summary.en.md) gives actual values and denominators.

Illegal-design tests can falsely pass through unsupported-syntax rejection. Their Icarus/Verilator execution evidence therefore requires reviewed fixed-release oracles. Nightly Match counts do not directly become confirmed requirements.

<a id="q17-全節にテストが2本あれば規格の全動作を網羅していますか"></a>

### Q17. Do two tests per clause cover every behavior?

They satisfy a direct-citation count. A clause can contain many conditions, branches and exceptions; file counts do not identify which are observed. Use [citation depth](coverage-depth.md) for distribution and [requirement matching](test-requirement-matching.en.md) for semantic links. Unregistered tests may exercise more behavior, but are not counted before review.

<a id="q18-暫定値はいつ確定値になりますか100なら検証完了ですか"></a>

### Q18. When is coverage confirmed, and does 100% finish verification?

Finishing source review does not approve a denominator. Interpretation holds, duplicate meanings and requirement units must be reconciled and approved. Provisional 100% concerns registered units, not all programs and input combinations. Inspect denominator status, unmapped/held requirements, stale evidence and detection scope. See [measurement rules](../coverage/README.en.md#計測の意味).

The current 12,298-requirement denominator was approved by AI review on 2026-10-28. Zero interpretation holds does not mean independent human approval or complete semantic review of every test. The [denominator review](denominator-review-20261028.en.md) records the basis and limitations.

<a id="q19-複数シミュレータの成功を集めてand集合を合格にできますか"></a>

### Q19. Can partial successes from different simulators satisfy an AND group?

Every member of a collective group must pass in the same run and environment. Partial successes from separate tools or runs cannot be combined to satisfy it. If alternative groups exist, one complete alternative is sufficient. See [`check_groups`](../coverage/README.en.md#台帳と証跡).

<a id="5-svaとフォーマル検証"></a>

## 5. SVA and formal verification

<a id="q20-sva参照評価器はシミュレータで元のsvaを実行するものですか"></a>

### Q20. Does the SVA reference evaluator execute original SVA in a simulator?

It implements standard-derived sequence, property and sampled-value semantics in Python and computes results from input traces, within its audited scope such as single-clock models. Formal checks translate its computation into a verification circuit and compare independently written RTL. They do not ask Yosys to directly parse unsupported original SVA. See the [illustrated guide](sva-reference-formal-verification.en.md).

<a id="q21-bmcとpdrはどちらも同じpassですか"></a>

### Q21. Do BMC and PDR PASS mean the same thing?

BMC searches through a specified finite depth. PDR proves the modeled safety property without that finite-depth limit. These sequence PDR checks fix expressions, numeric parameters and input assumptions; they do not generalize to arbitrary expressions or integer parameters. Solver depth and semantic sample length are also distinct for models that tabulate finite inputs. See [proof scope](sva-reference-formal-verification.en.md).

<a id="q22-40モデルと111ケースを足して151本のテストを証明したのですか"></a>

### Q22. Do 40 models plus 111 cases mean 151 proved tests?

The 40 models were the initial set, not the whole current catalog. Test files and models differ, and the base and boundary sets overlap. Their sum is not a count of distinct expressions or real tests. See [interpreting results](sva-reference-formal-verification.en.md#結果の見方) for current catalog, model sets and real-output comparisons.

Real-test bindings concern sequence fragments evaluated from 0/1 conditions. They do not prove whole assertions, scheduling or printing. Reference agreement and model checks do not automatically add simulator oracle tokens or execution coverage. See [boundary bindings](sva-formal-expansion-20261026.en.md).

<a id="q23-フォーマル検証の結果にfailがあるのは問題ではありませんか"></a>

### Q23. Is a formal FAIL necessarily a problem?

Deliberately incorrect negative controls are expected to FAIL with counterexamples. Distinguish them from correct-model failures, and check expected outcomes, exit codes and counterexample/reachability evidence. UNKNOWN, TIMEOUT and ERROR do not count as success. `--check-results` validates saved evidence against sources; it does not rerun solvers. See [rerunning checks](sva-reference-formal-verification.en.md#再実行).

<a id="6-テストの修正と記録"></a>

## 6. Changes and evidence

<a id="q24-テストや期待値を少し直しただけでも再実行が必要ですか"></a>

### Q24. Does even a small test or expectation correction require a rerun?

Changing stimuli, expectations, diagnostic conditions or related files changes input fingerprints. Recheck the standard, mappings and observation rationale, then save fixed-release reruns as new evidence. Do not rewrite old fingerprints to present earlier execution as current success. See [routine updates](../coverage/README.en.md#日常の更新) and [correction examples](nightly-suite-corrections-20261027.en.md).

<a id="q25-testsgenの期待値だけを直してもよいですか"></a>

### Q25. May I change only an expectation under `tests/gen/`?

Change the generator and standard-derived reference model, then regenerate. Direct edits disappear on regeneration and fail consistency checks. See [generated tests](../README.md#generated-tests), then check with:

```sh
python3 generators/generate.py --check
```

<a id="q26-aiによる規格確認と人によるレビューはどう区別していますか"></a>

### Q26. How are AI and human reviews distinguished?

`:spec_check: ai` and `human` identify the reviewer. AI checking, agreement with another model and successful tools do not mean human review. Requirement mappings and holds also record reviewer, date and input fingerprints so the reviewed scope remains traceable. See [metadata](../README.md#metadata) and [matching procedure](requirements-to-tests-method.en.md).

<a id="q27-不一致を見つけたら何を確認しどこへ報告しますか"></a>

### Q27. What should I check and where should I report a mismatch?

Record the suite commit, simulator version, test and related inputs, arguments, actual output, diagnostics and exit code; reproduce identical conditions. Check expectations and source against the cited clauses, review diagnostic judgment and reduce the example. Test defects belong in [suite issues](https://github.com/kurochan001/kirimasim-tests/issues), separately from simulator defects.

This project records fixed Icarus/Verilator differences in the [difference list](simulator-differences.md) and test comments, without reporting them upstream. Other implementations' issues also require checking existing issues and ownership; review does not automatically authorize external posts. Use clause numbers and original explanations, without reproducing standard text, figures or example code. See [working policy](codex-handoff-20261031.en.md#2-ユーザーの方針と作業上の注意) and [Contributing](../README.md#contributing).

Exclude commercial simulator output and diagnostics; see [Q45](#q45-may-i-post-commercial-simulator-output-or-diagnostics-in-an-issue).

<a id="7-機能間クロス検証"></a>

## 7. Feature interactions

<a id="q28-どうして全機能を単純に掛け合わせないのですか"></a>

### Q28. Why not simply cross every feature?

Split the problem into small models sharing values, types, state or time. Use constrained pairwise coverage, then retain higher-order groups tied to likely failure mechanisms and mandatory boundaries. This targets handoff defects missed by isolated feature tests, without guaranteeing detection of every higher-order fault. See [rationale and extension procedure](interaction-verification-method.en.md).

<a id="q29-計画上は網羅していても未対応や不一致が残るのですか"></a>

### Q29. Can a complete plan still have unsupported or failing execution?

A plan shows that selected tests contain target combinations and anchors. Execution fulfillment uses passes with matching input, expectation and runner fingerprints from a specified run. Known, unsupported, fail, missing and stale results are not success. Unsupported tools do not remove legal targets from the denominator. Compare the [saved-run overview](interaction-verification.en.md#保存実行の概要) and [per-model report](interaction-coverage.en.md).

<a id="q30-checkが成功したら全クロスが合格したことになりますか"></a>

### Q30. Does a successful Check mean every cross passed?

It confirms fixed-oracle maintenance and consistency of generated files and registries. `interaction_coverage.py --check` also does not require every cross to pass. Select scope and evidence with `--model` and `--results`, then use `--require-pass` to require fulfillment. This evaluates saved JSON without starting a simulator. See [command roles](../coverage/README.en.md#機能間クロスの計画と証跡).

<a id="q31-保存クロス実行補助証跡nightlyをどう区別しますか"></a>

### Q31. How do saved cross runs, qualification evidence and Nightly differ?

`interaction-results/` contains fingerprinted regression results. `interaction-qualification/` contains supporting minimal examples, mutation checks and reference selection records; these do not increase normal pass or test counts. Nightly is a separate run with its own suite, tool versions and selection. A saved "latest build" means the revision checked at that execution's start, not future upstream revisions. See [qualification records](../coverage/interaction-qualification/README.en.md) and [Nightly](nightly-results.en.md).

<a id="q32-章間表の数字を合計すればクロステストの総数になりますか"></a>

### Q32. Can I sum matrix cells to get the cross-test total?

The [matrix](chapter-cross-matrix.en.md) counts models. It is symmetric, and a model may map to several chapter pairs, so summing cells gives neither model nor test totals. Diagonal cells count models by primary chapter and sum to the model total. Individual tests are in each model's `selection` in the [plan JSON](../coverage/interaction-summary.json); detailed CSVs identify execution status.

<a id="q33-0セルやmecnrは未検証や合格を表しますか"></a>

### Q33. Do zero cells and M/E/C/N/R indicate missing tests or passes?

Zero means no finite-model mapping, not necessarily no test. `M` means modeled, `E` means an existing stimulus/observation has been reviewed, `C` is an addition hypothesis, `N` is outside this plan and `R` awaits review. Digits in `E1` etc. indicate modeling priority. These codes do not indicate execution success. E entries have witnesses, C entries have factor/observation hypotheses, and R is not excluded as low risk. See [triage](chapter-cross-triage.en.md).

<a id="q34-completeと全選択ケースpassのモデル数は同じ判定ですか"></a>

### Q34. Are complete and all-selected-tests-pass the same judgment?

`interaction_coverage.py` marks `complete` when admissible passes in one run cover every target and anchor. A non-anchor test may fail while other passes cover its targets; inspect status counts too.

The chapter matrix's all-selected-tests-pass condition requires every short-selection test to pass in the same run. Success only for a chapter pair's `when` subset does not establish whole-model success. See [aggregation](../tools/interaction_coverage.py) and [matrix policy](chapter-cross-matrix.en.md#実行結果の扱い).

<a id="q35-次のクロスモデルはどのような順序で追加しますか"></a>

### Q35. How should I add the next model?

Review existing tests and zero-cell evidence, then isolate features acting on the same value, state, time or reference. Derive factors, levels, legal conditions and observations from the standard. Select pairs, necessary higher-order groups and anchors; do not exclude legal assignments because a tool is unsupported. Compute expectations independently and compare a reference using a different representation or algorithm. Calling the generator's calculation again can repeat its errors.

Generate tests, assess mutations, check fixed releases and regress a development build whose upstream revision was checked immediately before execution. Save new evidence, then update chapter mappings and reports. Requirement mappings need separate semantic review. The [method](interaction-verification-method.en.md) gives the sequence and checklist.

<a id="q36-対照インスタンスと途中の値もなぜ確認するのですか"></a>

### Q36. Why observe guard instances and intermediate values?

Final values can hide canceling defects or incorrectly shared state. Drive targets and default guards with different stimuli/tags, and compare before/after conversion, operations and resizing. Drive the guard later to verify independent updating, rather than only retention. Known preparation before X/Z and recovery afterward distinguish ignored inputs and stopped state updates. See [interface conversion](interaction-verification.en.md#interfaceヘッダのimportとpackage関数の型変換) and [sequential UDP state](interaction-verification.en.md#generateで生成した逐次udpの状態と入力変換).

<a id="q37-入力が01だけなのにfourstateがyesになるのはなぜですか"></a>

### Q37. Why can 0/1 inputs still require four-state observation?

`:fourstate:` describes observed X/Z dependence, not just inputs. Driver conflicts can produce X, and a sequential UDP can retain an initial X. Do not automatically include all known-input cases in Verilator comparison. Inspect initialization, transitions and strength displays. See [UDP arrays/strength](interaction-verification.en.md#udpの配列接続と駆動強度の解決) and [sequential UDPs](interaction-verification.en.md#generateで生成した逐次udpの状態と入力変換).

<a id="q38-故障注入でコンパイル失敗やクラッシュが出れば検出に数えますか"></a>

### Q38. Do mutation build failures or crashes count as detections?

They alone do not demonstrate the intended observable difference. Require matching normal controls and distinguish executable mutants detected through output differences after normal termination. In the interface-import model, bypassing formal conversion matched 55 known-input lines before differing at the first unknown-input line, line 56. This illustrates why input class and intermediate observations matter. Mutation counts do not increase generated tests or ordinary regression passes. See the [record](interaction-verification.en.md#interfaceヘッダのimportとpackage関数の型変換).

<a id="q39-verilatorでseed-1と73が一致すれば乱数条件をすべて確認済みですか"></a>

### Q39. Do matching Verilator seeds 1 and 73 cover every random condition?

They establish reproduction under two execution conditions, not all initial states or random streams. Do not generalize one successful seed to both, or two-state output to four-state confirmation. Save seeds separately and check that tests observe specified values without accidental reliance on uninitialized data or races. See [fixed-release checks](../README.md#where-the-expected-outputs-come-from).

Generating actual values and operation sequences in [bounded random comparisons](random-cross-verification.en.md) is a separate path.

<a id="q40-最新コミットでの実行と保存結果の再確認はどう違いますか"></a>

### Q40. How does a latest-commit run differ from checking saved results?

Before executing development versions such as kirimasim or Lyra, fetch and verify upstream and match the build to that commit; record the version. Fixed Icarus 13.0 and Verilator 5.052 remain fixed oracle releases. Reading saved JSON neither reruns a simulator nor confirms future revisions. Preserve old evidence and write each execution to a new destination.

GitHub Actions Re-run also uses the original suite commit. For current main, start a new workflow targeting main and verify its suite commit and simulator versions. See [manual execution](nightly-results.en.md#最新のmainで手動実行する).

<a id="q41-シミュレータを動かさず1モデルの保存結果だけ確認できますか"></a>

### Q41. Can I check one model's saved results without running a simulator?

From the repository root, specify the model and JSON. This example evaluates the saved interface-import run; unchanged inputs/runners allow checking targets and anchors:

```sh
python3 tools/interaction_coverage.py --model interface_header_import \
  --results coverage/interaction-results/cross53-kirimasim-4fb5f6b1.json --require-pass
```

`--require-pass` requires `complete` for every selected run/model, without merging partial successes. Use `--list-tests --model interface_header_import` for paths only. Check that a list is nonempty before passing it to a runner: no positional paths normally selects the full suite, so an empty expansion changes the intended scope.

<a id="q42-specだけのテストがkirimasimでpassしたらoracleも変更しますか"></a>

### Q42. Does a spec-only kirimasim PASS change the oracle?

Save its agreement for that run; do not automatically add fixed-release oracle tokens. If fixed tools remain unsupported or differ, retain the standard-derived common expectation and record the difference. Some config cases match kirimasim despite fixed releases rejecting their syntax. `spec`, fixed-release oracles and saved `pass` serve different purposes. See [expectation policy](../README.md#where-the-expected-outputs-come-from) and [config results](interaction-verification.en.md#configのパラメータ設定とgenerateの形状).

<a id="q43-文書だけを直す場合も全シミュレータの再実行が必要ですか"></a>

### Q43. Do documentation-only edits require full simulator reruns?

If tests, expectations, inputs and runners are unchanged, compare prose with evidence and check report consistency and links. Do not change versions, dates, pass counts or old JSON without new execution. If inputs/runners also change, rerun the affected scope separately. Distinguish local checks, GitHub Check and published Nightly by commit and scope.

<a id="8-商用シミュレータでの確認状況"></a>

## 8. Commercial simulators

<a id="q44-商用シミュレータでも確認していますか"></a>

### Q44. Has the suite been checked with commercial simulators?

This project holds no commercial SystemVerilog simulator licenses. It has not checked commercial products and does not plan to run or compare them. The policy avoids contractual issues concerning publication, product-behavior analysis and competing-product development, and keeps expectations independently derived from the standard. Keeping results private is not assumed sufficient to meet usage conditions. Third-party commercial outputs or diagnostics are not reused to derive expectations or implementation decisions.

As a public example, §§9.3.2, 9.3.5 and 9.3.7 of the [Synopsys Cloud Service Agreement 2024](https://www.synopsys.com/cloud/service-agreement.html) prohibit activities involving reverse engineering, competing-product development/improvement, and benchmark use/disclosure (checked 2026-11-01). The text was publicly readable that day without login or product-license authentication. Reading a public agreement and holding a product license are separate. Citing it does not imply that this project entered that agreement or that it applies to this project.

Conditions depend on product, contract and jurisdiction. This is not a claim that ordinary testing is always prohibited or constitutes reverse engineering. The project's operational policy is separate from interpreting individual contracts.

Expectations come from IEEE 1800-2023 clauses and independent reference models. `:oracle:` records the scope confirmed with fixed Icarus/Verilator releases. Saved kirimasim, Lyra and Ghost results likewise describe recorded versions and conditions. Commercial executability and agreement remain unconfirmed. See [expectations](../README.md#where-the-expected-outputs-come-from) and [saved-run scope](interaction-verification.en.md#保存実行の概要).

<a id="q45-issueに商用シミュレータの出力診断を載せてもよいですか"></a>

### Q45. May I post commercial simulator output or diagnostics in an Issue?

This project does not accept them. The policy covers issue bodies/comments, logs, screenshots, waveforms, and links to external pastes or execution environments. Do not submit anonymized excerpts/summaries or republished third-party results either. The project does not ask reporters to run commercial simulators.

Describe expected behavior using IEEE 1800-2023 clause numbers, your own explanation and an independently written minimal reproducer. If supplying execution results, use Icarus Verilog, Verilator, kirimasim, Lyra, SymbiYosys, or Ghost results prepared for publication, and record tool version and suite commit. Exclude copied standard text, private Ghost information and personal data.

The [issue form](../.github/ISSUE_TEMPLATE/report.yml) provides instructions and required confirmations. [Template configuration](../.github/ISSUE_TEMPLATE/config.yml) disables blank issues for ordinary contributors. These do not automatically inspect content or fully prevent privileged blank issues, API/CLI posts, later comments or attachments. See [GitHub's template documentation](https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/configuring-issue-templates-for-your-repository). If prohibited material appears, do not reproduce, summarize or incorporate it into expectations; request action from its author or a maintainer.

<a id="model-based-random-comparisons"></a>

<a id="9-モデルに基づくランダム比較"></a>

## 9. Model-based random comparisons

<a id="q46-モデルがあればランダム検証で比較できますか"></a>

### Q46. Can existing models support random verification comparisons?

Explore different input values, initial states and operation histories within supported scopes to find counterexamples missed by fixed representative cases.
Retain fixed boundaries and combination regressions, reproduce and classify discoveries, and carry confirmed failures into fixed regressions.
Yes: drive a design and reference with identical stimuli. Current profiles cover arithmetic expressions, division/remainder and indexed-write sequences.
References must accept the generated values and operation lists within their legal scope; not every finite model accepts arbitrary inputs.
This differs from matching random streams. Multiple-solution `randomize()` checks should validate constraints rather than require identical generated values.
See [purpose and roles](random-cross-verification.en.md#purpose-and-roles), [the verification process](random-cross-verification.en.md#verification-process) and [scope and limits](random-cross-verification.en.md#scope).

<a id="q47-ランダム比較が失敗したらどこから再現しますか"></a>

### Q47. How do I reproduce a random-comparison failure?

Open Nightly's `random-cross-kirimasim` artifact. Inspect verdicts, versions and fingerprints in `run.json`, and the case's SV, expectation and output.
`manifest.json` records actual inputs and operations; `--replay` plus `--case` reruns them without redrawing.
Again fetch/build immediately before execution, identify that revision and record differences from the original build. A seed alone does not guarantee identical stimuli.
A mismatch can also indicate a reference or observation error, so review the standard before attributing it. Unsupported/unexecuted cases are not passes; do not hide differences by changing expectations.
See [saved data and replay](random-cross-verification.en.md#replay).

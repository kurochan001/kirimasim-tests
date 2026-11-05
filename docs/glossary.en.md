<a id="kirimasim-testsの用語集"></a>

# kirimasim-tests glossary

[日本語](glossary.md) / [README](../README.md)

Terms used in the README, test headers, results and coverage reports are grouped by purpose. See the [FAQ](faq.en.md) for operational questions.

Here, design requirement coverage and execution coverage are defined by this repository's requirement registry and measurement rules. They differ from RTL code coverage, SystemVerilog functional coverage and the Nightly test match rate.

<a id="目次"></a>

## Contents

- [Test basics](#1-test-basics)
- [Metadata and expectation provenance](#2-metadata-and-expectation-provenance)
- [Results and Nightly](#3-results-and-nightly)
- [Requirements, mappings and coverage](#4-requirements-mappings-and-coverage)
- [SVA and reference evaluation](#5-sva-and-reference-evaluation)
- [Formal verification](#6-formal-verification)
- [Execution and evidence](#7-execution-and-evidence)
- [Feature-interaction verification](#8-feature-interaction-verification)
- [Language features used in cross tests](#9-language-features-used-in-cross-tests)

<a id="1-テストの基本"></a>

## 1. Test basics

| Term | Meaning in this suite |
| --- | --- |
| SystemVerilog / IEEE 1800-2023 | The hardware description and verification language under test / the edition defining expected behavior. |
| LRM / clause | Language Reference Manual / a section defining behavior or restrictions, identified in `:lrm:`. |
| Conformance test | A check that simulator behavior follows the language standard, using a small design and expected result. |
| Stimulus / observation point | Inputs or operations applied to a target / the signal, value, message or time at which a result is checked. Applying stimulus alone is insufficient; the verification item includes comparison. |
| Verification item / scenario | A specification-derived condition and expected result / the inputs, operations and transitions that exercise it. One file can check several items. |
| Expected result / expected output | Values, rejection or termination conditions accepted as success / the standard-output text compared. `.expected` stores expected output. |
| Legal-design / illegal-design test | A test of valid source behavior / a deliberately invalid design checking diagnosis and rejection of the intended violation. The latter exercises compiler error handling. |
| Runner | A `tools/run_*.py` script that builds, executes and judges a test from metadata. Formal verification also has a runner. |
| Normalization | Removing selected blank lines and tool-specific termination banners before comparison. Spaces, digits and values on nonempty lines remain significant. Each runner defines removed diagnostics/banners. |
| stdout / stderr / exit code | Ordinary process output / a diagnostic output channel / process termination status. Simulators may print diagnostics to stdout, so inspect each runner's comparison and diagnostic checks. |

See [test format](../README.md#test-format), [judgment](../README.md#how-a-test-is-judged) and the [catalog](tests/README.md).

<a id="2-メタデータと期待値の根拠"></a>

## 2. Metadata and expectation provenance

| Term or field | Meaning and checks |
| --- | --- |
| Metadata | Header comment fields such as `:name:` recording purpose, clauses, execution and judgment. |
| sv-tests compatibility | Use of a header format shared with other language test suites, with additional project-specific fields. |
| `:lrm:` | Cited clause numbers. Citation and coverage of every requirement in a clause are separate claims. |
| Oracle / `:oracle:` | The basis for an expected result / the field recording standard review and fixed simulator releases that confirmed it. |
| `spec` / standard only | A clause-derived expectation / an oracle containing only `spec`, without recorded fixed-release confirmation. |
| `iverilog@13.0` / `verilator@5.052` | Confirmation by that fixed release. It does not automatically apply to Nightly development builds or another release. |
| `:spec_check:` | Who compared the expectation with the standard: `ai` or `human`. |
| `:fourstate:` | Whether observations depend on X/Z. Two-state execution does not equivalently confirm a `yes` case. |
| `:expected_stdout:` / `:should_fail_because:` | Expected stdout / the violation requiring rejection. Illegal designs record diagnostic conditions instead of expected stdout. |
| `:expected_stderr_regex:` / regular expression | A pattern checking valid diagnostic locations and, where required, the intended violation. Distinguish unsupported syntax errors. |
| `:files:` / `:incdirs:` / `:defines:` | Additional input files / include search paths / compile-time macros, all relevant to reproduction. |
| `:top_module:` / `:args:` | Selected top module or config / runtime arguments, translated into tool-specific forms by runners. |

See [metadata](../README.md#metadata) and [expectation policy](../README.md#where-the-expected-outputs-come-from).

<a id="3-結果とnightly"></a>

## 3. Results and Nightly

| Term | Interpretation |
| --- | --- |
| Match / `pass` | Output and specified termination/diagnostic checks match, including correctly rejected illegal designs. |
| Differ / `fail` | Judgment fails: output differences, build/runtime failure, accepted illegal source, diagnostic mismatch, etc. |
| Known difference / `known` | A mismatch without an Icarus/Verilator fixed-release oracle; also kirimasim tests with only another simulator's expectation. It is neither success nor the runner's ordinary regression failure. |
| Unsupported / `unsupported` | A recognized unsupported-feature diagnostic or a kind of test the runner cannot execute. It is not success. |
| Not run / `not_run` | No record for a test in the selected snapshot. Cross aggregation adds this category; it is separate from the four runner statuses. |
| Stale / inadmissible evidence | Cross evidence rejected for mismatched inputs/runners or missing version, timestamp or change-during-run provenance. A stored `pass` does not make it current success. |
| `NOW MATCHES` | Icarus reports a mechanically matching test without a registered oracle. It does not automatically add an oracle. |
| Nightly match rate | Matching tests divided by tests with results in the same run. Known and unsupported tests remain in the denominator, including tests skipped as unsupported. Fixed-release terminal summaries use a different scope. |
| Nightly | A scheduled GitHub Actions workflow using development simulators and publishing result history/charts. |
| Check | A workflow checking fixed oracles, generated files, metadata, registries and tool unit tests. |
| By chapter | Per-chapter matching/recorded test counts and rates for each simulator, not per-requirement coverage. |
| Regression / ratchet | Loss of a previously satisfied condition / the current Nightly rule failing kirimasim on a previous `pass` becoming `fail`. |
| main / results / suite commit | Branch containing tests/tools / branch publishing Nightly results / commit of the suite used for that execution. |
| UTC / JST | Coordinated Universal Time / Japan Standard Time, nine hours ahead of UTC. |

See [Nightly](nightly-results.en.md), the [result format](../tools/suite_results.py) and [workflows](../README.md#workflows).

<a id="4-要求対応付けカバレッジ"></a>

## 4. Requirements, mappings and coverage

| Term | Meaning and measured scope |
| --- | --- |
| Requirement / requirement ID | A registered condition, behavior or observation required by the standard / its identifier. A clause can contain several. |
| Requirement registry / `behaviors.json` | Requirements, acceptance criteria, sources, tests and observations used as evidence. |
| Source review | Classifying source blocks as requirements, explanation, examples, references, etc., and recording their treatment. It is separate from simulator execution. |
| Requirement-to-test mapping / traceability | Linking each requirement to reviewed tests, stimuli and observation points in the registry. |
| Citation coverage / citation depth | Which clauses tests cite / how many tests directly cite each clause. Coverage of conditions, branches and exceptions requires separate review. |
| Design requirement coverage | Requirements with reviewed test mappings divided by all registered requirements. It measures specification-to-verification-item mapping, not RTL structure. |
| Execution coverage | Requirements with pass evidence matching current inputs/runners divided by all registered requirements. It is not a test-file pass rate, and a multi-environment union is not one simulator's conformance rate. |
| Provisional / confirmed / denominator | Measurement over registered rows / measurement after interpretation, duplicate and requirement-unit reconciliation and denominator approval / the requirement set used in the ratio. See current reports for status. |
| Interpretation hold | An unresolved standard interpretation retained in provisional denominators. Do not approve test mappings before resolving it. |
| Collective witness / AND group / `check_groups` | Tests jointly covering one requirement, all of which must pass in the same environment/run. Alternative groups use OR. |
| Baseline | A record detecting removed/changed requirements, mappings and collective evidence. Review reasons before updating it. |

See the [summary](behavior-coverage-summary.en.md), [measurement rules](../coverage/README.en.md), [method](requirements-to-tests-method.en.md) and [mapping inventory](test-requirement-matching.en.md).

<a id="5-svaと参照評価器"></a>

## 5. SVA and reference evaluation

| Term | Meaning in this suite |
| --- | --- |
| SVA | SystemVerilog Assertions, expressing conditions and temporal relationships. Tests check evaluation, success/failure and actions defined by the standard. |
| Immediate / concurrent assertion | A procedural condition check / a temporal check evaluated against sampling events. |
| Sequence / property | Conditions and match intervals over sampling events / a required condition expressed using sequences and temporal operators. |
| Sample / tick | A value captured at a specific event / the evaluator's unit for counting sampling instants. |
| Antecedent / consequent | The condition and the implication's required side. In `a \|-> b`, `a` is the antecedent and `b` the consequent. |
| Vacuous pass / vacuous success | Implication passes because its antecedent does not match, without evaluating the consequent. It does not confirm consequent behavior. |
| Nonvacuous pass | For implication, a pass resulting from both matching antecedent and satisfied consequent. |
| Empty match | A zero-length sequence match, distinct from vacuous success through a nonmatching antecedent. |
| Preponed / NBA / Reactive | Sampling region for ordinary clocked concurrent assertions / nonblocking update region / concurrent assertion action region. Keep observation times distinct. |
| Sampled-value function | `$sampled`, `$past`, `$rose`, `$fell`, `$stable`, `$changed`, etc.; distinguish sampled/history values from current live values. |
| Reference evaluator / independent reference model | A standard-derived Python computation / a separately written comparison model. Agreement does not automatically add a simulator oracle. |
| Two-state / four-state / X/Z | Values using 0/1 / 0/1/X/Z / unknown and high impedance. Check modeled types, operators and inputs. |
| VCD / trace | Value Change Dump waveform format / a time series of values/states. Ordinary VCD does not distinguish all event regions at the same timestamp. |

See the [SVA/formal guide](sva-reference-formal-verification.en.md) and [evaluator reference](../tools/sva_reference/README.md).

<a id="6-フォーマル検証"></a>

## 6. Formal verification

| Term | Meaning and scope |
| --- | --- |
| Formal verification | Checking properties of mathematical models. Here, evaluator-generated circuits are compared with independently written RTL models. |
| Yosys / SymbiYosys (SBY) | A tool processing verification circuits / orchestration of solvers for BMC, proofs and reachability. |
| BMC | Bounded Model Checking, searching for counterexamples through a specified finite depth. It does not prove longer inputs. |
| PDR | Property Directed Reachability, a safety-proof method. These sequence models establish unbounded-input-length agreement for fixed expressions and numeric parameters. |
| Cover / reachability | Seeking an input witnessing a target state or match. Finding a witness differs from proving a property for every input. |
| Counterexample | Inputs/states causing model disagreement or a property violation, used to investigate implementations, references and encodings. |
| Negative control / mutant | An intentionally incorrect comparison model used to verify detection. Expected FAIL and counterexample generation establish sensitivity of the checking setup. |
| Proof scope / sequence-fragment binding | Fixed expressions, widths, initial states and input assumptions / links from real-test fragments to models. Fragment agreement does not establish whole-assertion execution. |
| Evidence check / `--check-results` | Validating saved results against current source, models and required tasks. It does not rerun solvers. |

See the [guide](sva-reference-formal-verification.en.md), [boundary sweep](sva-formal-expansion-20261026.en.md) and [technical review](../tools/sva_reference/FORMAL_REVIEW.md).

<a id="7-実行環境と証跡"></a>

## 7. Execution and evidence

| Term | Meaning and recorded conditions |
| --- | --- |
| Fixed release / development version / commit | An oracle's selected release / evolving development code / a source snapshot identifier. The same tool name does not ensure the same behavior. |
| Seed | An input selecting a random stream. The same number does not guarantee the same behavior after version, settings or test changes. |
| Model-based random comparison | Generate legal values/operation lists and compare a design with reference expectations for the same stimuli. Measure separately from fixed combination coverage. |
| Stimulus manifest | JSON retaining actual parameters, values and operations as well as the seed; replay reads these stimuli without redrawing after generator changes. |
| Immutable replay / reference drift | Replay using saved SV and expectations / recorded differences from materializing with current reference code. `--reference-policy current` is explicit; retain the original evidence. |
| Exploration admission | Optional `--explore` management of identical completed jobs using input and execution identities. Only valid complete comparisons qualify; a skipped submission is not a new pass. Fixed regressions, formal Nightly and explicit replay execute. |
| Independent saved-SV qualifier | A bounded interpreter of actual saved source, separate from generator parameters and reference helpers. Array, package-observer, class-method import, generated-subroutine, class-selection generated-loop and interface-query qualifiers reject syntax outside their scope; agreement is not full-language conformance or an independent check of every profile. |
| Execution time budget | A case/run limit. Timeouts and cases not started are not passes; retain stimuli and explicit statuses for replay. |
| DPI-C | Direct Programming Interface between SystemVerilog and C. Tests require their C files and corresponding runner/tool support. |
| VPI | Verilog Procedural Interface for C observation/manipulation of simulation objects/events. `:vpi_c:` identifies test C code. |
| Evidence / snapshot | A record of inputs, versions, settings, execution and judgment / all results from that run. |
| SHA-256 / input fingerprint / runner fingerprint | Content identities / identities of test, expectations and related inputs / identities of runner and normalization code. Matching hashes do not prove semantic correctness. |
| Stale evidence | Results no longer matching current inputs/runners. Earlier success cannot simply become current execution confirmation. |
| Generated test / generator | A test written under `tests/gen/` / Python deriving inputs and expectations from a standard-based reference. Update generated files through generators. |
| Lint / unit tests / CI | Mechanical header/format checks / checks of individual tool functions / continuous execution of configured checks. Interpret success together with checked scope. |

See [execution](../README.md#running-the-suite), [generated tests](../README.md#generated-tests), [random comparison and replay](random-cross-verification.en.md) and [evidence rules](../coverage/README.en.md#台帳と証跡).

Terminology examples: [PALTEK on verification environments and stimulus](https://www.paltek.co.jp/techblog/techinfo/220125-01), [properties and vacuous success](https://www.paltek.co.jp/techblog/techinfo/210816-02), and [Synopsys on formal property verification](https://www.synopsys.com/ja-jp/verification/static-and-formal-verification/vc-formal.html).

<a id="reference-model-and-scoreboard"></a>

### Reference models and checking roles

| Term | Meaning and role in this suite |
| --- | --- |
| DUT (Design Under Test) / verification target | Usually product RTL in RTL verification; here the target is the simulator executing SV language behavior |
| Reference model / predictor | Computes expected behavior from inputs, initial state and operation history; Python performs this role in random comparisons |
| Scoreboard / checker | Compares observations with expected behavior; here existing runner normalization/comparison supplies that role, without implementing a UVM component |

See [the worked example and RTL-verification correspondence](faq.en.md#q46-can-existing-models-support-random-verification-comparisons).

<a id="8-機能間クロス検証"></a>

## 8. Feature-interaction verification

| Term | Meaning in this suite |
| --- | --- |
| Feature interaction | Checking handoffs of values, types, state or time between individually working features. Merely placing two constructs in a file does not establish an interaction check. |
| Factor / level | A condition affecting results / a representative value, such as width, sign, state type, storage or input. |
| Legal row | A complete factor assignment satisfying specification constraints and representative-value choices. Unsupported tools do not exclude legal rows. |
| Constrained pairwise coverage | Covering every pair of levels appearing in a complete legal assignment. This does not execute the full factor product. |
| t-way / higher-strength group | Coverage of selected groups of t factors, such as focused triples in addition to pairs. It differs from whole-language or requirement coverage. |
| Anchor | A mandatory boundary or known-defect witness retained even if its projections are covered elsewhere. |
| Planned coverage / execution fulfillment (`complete`) | Target combinations and anchors present in selected rows / confirmed by admissible passes in a specified run. `complete` does not require every registered test to pass. |
| All selected cases pass | Every test in the short selection passes in the same snapshot. Chapter-matrix passed-model counts use this condition, distinct from target/anchor fulfillment. |
| Chapter pair / chapter matrix | Two chapters whose interaction is mapped / a symmetric model-count table by chapter pair. Count unordered pairs once; diagonals count primary-chapter models. |
| M / E1–E3 / C1–C3 | Finite model registered / existing interaction witness reviewed / proposed addition. Digits indicate plan priority, not pass counts. |
| N / R / D | Outside this plan / deferred or awaiting review / diagonal outside triage. R is not low risk, and N does not mean the standard needs no verification. |
| Pair condition (`when`) | Factor levels for which a model checks a particular chapter interaction. Matching case counts may differ from the model's full selection. |
| Guard instance | An independently tagged/driven instance exposing missing configuration or mixed state. Check later independent updating as well as initial retention. |
| Intermediate observation / recovery | Separately checking conversion, state or captured values before the final result / checking updates after removing X/Z or hold conditions. These expose canceling defects and stopped updates. |
| Bit-identity stimulus | Distinct histories for bit positions and guard inputs, exposing swapped/reused wires and missing upper bits that a single alternating pattern can hide. |
| Fault injection / qualification evidence | Deliberately incorrect operations used to check detection / supporting minimal examples, independent calculations, reference selection and build records. They do not increase ordinary pass counts. |
| Normal control / executable mutant | Correct unmodified behavior matching expectations / deliberately incorrect code that still builds and runs. Distinguish normal-exit output differences from syntax errors or crashes. |

See [models and saved runs](interaction-verification.en.md), [practical method](interaction-verification-method.en.md), [report](interaction-coverage.en.md), [matrix](chapter-cross-matrix.en.md), [triage](chapter-cross-triage.en.md) and [FAQ](faq.en.md#7-feature-interactions).

<a id="9-クロステストで使う言語機能"></a>

## 9. Language features used in cross tests

These terms help read model stimuli and observations. Check [model scope](interaction-verification.en.md) and each test's `:lrm:` for individual rules.

| Term | Meaning and observation considerations |
| --- | --- |
| Elaboration / generate | Determining executable design structure from parameters/hierarchy / constructing that structure by conditions/repetition. Distinguish procedural `for` state updates during simulation. |
| config / parameter override and reset | Instance configuration / changing to explicit values or restoring defaults. Observe resulting counts, widths and branches as well as unaffected siblings. |
| Scope / shadowing | A declaration's naming/search region / selection of another declaration through an inner same-name declaration. Identical spelling need not identify the same object. |
| import / export | Making package names available / re-exporting imported names from another package. Distinguish wildcard candidates from declarations actually imported. |
| Formal / actual / default argument | A subroutine declaration / caller expression or reference / expression used when omitted. Separate conversion, reference binding, and default evaluation time/scope. |
| Function / task / method | Language subroutines / operations invoked through objects such as classes or arrays. Here, function names a language construct rather than a generic feature, and method names an operation rather than a general procedure. Argument directions, returns and timing restrictions depend on the declaration form. |
| Primary / constant primary | A basic expression-grammar unit, such as a number, identifier or parenthesized expression / a form available in constant expressions. The Japanese term refers to grammar, rather than general priority or polynomial degree; consult the permitted Annex A forms. |
| Cast / casting type | An expression explicitly specifying a type, width or signedness / the type or other syntax specified by the cast. Distinguish size, signing and type casts, observing state conversion, extension and truncation order. |
| Packed / unpacked | Array dimensions in the type, before the variable name, forming one bit vector / dimensions after the variable name. Distinguish whole-value copying, selection and streaming order. |
| bit / logic | Two-state / four-state integral elements. X/Z convert to 0 in bit, so conversion and operator order can matter. Net versus variable is a separate distinction. |
| Truncation / zero extension / sign extension | Narrowing / filling high bits with 0 / replicating the sign bit. Expression width/sign rules, not destination width alone, determine application. |
| Blocking / nonblocking assignment (NBA) | Completing an assignment before procedural continuation / scheduling an evaluated value for a later update region. Distinguish post-reservation input/index changes and stored values before/after update. |
| Active / NBA / Reactive / Re-NBA | Event regions separating module procedures and their NBAs, program/assertion-action procedures and their NBAs. Source location alone does not uniformly classify all processing, including continuous assignments. |
| Continuous-assignment inertial delay / pulse rejection | Canceling a pending continuous update through a later input change. Check transition times and intermediate pulses, not only final values. |
| UDP / combinational and sequential UDP | User-defined primitives with table-defined behavior / forms using only inputs or also retained output state. Initialization, input edges and retention affect sequential observations. |
| Drive strength / resolved value / `%v` | Net driver strength / combined-driver value / display including strength. Observe separately from `%b` logic values; even 0/1 drivers can resolve to X. |

See [interface import/formal conversion](interaction-verification.en.md#interfaceヘッダのimportとpackage関数の型変換), [program regions](interaction-verification.en.md#programのイベント領域と非ブロッキング代入) and [sequential UDPs](interaction-verification.en.md#generateで生成した逐次udpの状態と入力変換).

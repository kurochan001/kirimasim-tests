<a id="ロジック設計の仕様書から検証項目とテストシナリオを作成する手順"></a>

# The procedure for creating verification items and test scenarios from the logic design specifications.

[English](spec-to-verification-method.en.md) / [日本語](spec-to-verification-method.md)

This paper generalizes [Extracting requirements from the PDF of IEEE 1800-2023 and verifying them with tests](requirements-to-tests-method.en.md) as a method of creating test scenarios from logic design specifications (product specification, IP specification, register map, protocol specification). The original procedure is based on the results of actual use of the original procedure in the standard test suite (full extraction of requirements, comparison, new tests, independent reviews, measurements). This has not yet been applied to semiconductor specifications.

In scope and out of scope:

- The objective is to verify logical functions. The RTL verification of pre‐silicon and the post‐silicon verification of the function are included.
- Excluded: Setup/hold analysis by STA, evaluation of AC/DC characteristics, quantitative evaluation of voltage and power, and production test using ATE. The ATPG pattern generated from the netlist and the fault model is also excluded.

<a id="1-原則"></a>

## 1. Principles

- The expected value is determined first from the specification. Do not copy RTL or simulator output into expected values. Expected values come from a reference model built from the specification or are derived directly from the specification.
- The requirements are written in an observable form. For each 1 requirement(s), define an observation point that can determine correctness: ports, registers, interrupts, transactions, or assertions on internal signals.
- Use as evidence only checks whose results change for incorrect implementations. The test that cannot specifically answer the question "what observation would change if the action was implemented incorrectly" is not considered as proof of the requirement.
- The authors and reviewers are separated. The test scenario and the requirements are reviewed by a reviewer who is not the author of the test scenario, and only those that pass are included in the test log. I will reject anything uncertain.
- The evidence is linked to the version and the execution condition. A recorded pass is valid only when versions of RTL, testbench, and reference model, configurations/parameters, test inputs, tool versions/options, and seeds match.
- Do not copy the specification text. In the notebook and tests, write the requirements in your own words, and quote the version and paragraphs of the specification. If the specification is confidential, first determine the environment and scope in which AI can be used.
- The correct aggregation is preferred over the protection of the numerical value. Withdraw mappings found to be incorrect and record the reasons.

<a id="2-元の手順との対応"></a>

## 2. Correspondance with the original procedure.

|Original procedure (IEEE 1800-2023)|Generalized procedure|
| --- | --- |
|PDF and source blocks of the standard|Version and paragraph of specification ID (including diagrams, timing diagrams, register tables)|
|Requirement ledger (`behaviors.json`)|Requirement ledger (JSON / YAML / requirements-management tool)|
|`kind`: Positive test / Standard-violation test / Boundary|Function, anomalous input, boundary, reset and initialization, configuration, timing, performance|
|Clause citations through the test's `:lrm:`|Requirement ID attached to tests, checkers, and coverage items|
|Expected output file compared to output|Pass/fail evaluation using reference-model-based scoreboards, checkers, and assertions|
|Record of test conditions and observations|The functional coverage obtained by the monitor. Record that conditions are reached and link those records to pass/fail evaluation|
|Icarus 13.0 and Verilator 5.052 comparison (`:oracle:`)|Cross-check reference models, multiple simulators, formal verification, and FPGA prototypes|
|Generated tests for header constants and reserved words|Generated tests from register maps, opcode tables, pin-multiplexing tables, and error-code tables|
|Pending interpretation|Issue records for specification ambiguities and contradictions. Can ask the author for clarification|
|Input hash and runner hash|Input of the test, commit of RTL, version of the tool, seed|
|The preliminary requirements coverage (test design) and execution confirmation rate.|Requirement coverage (mapping rate and pass rate). Weight by importance|

<a id="3-全体の流れ"></a>

## 3. The whole flow.

```text
Specification ─> A. Ingestion (edition, paragraph IDs, hashes)
                      │
                      v
                    B. Requirement extraction (smallest units with observation points) ──> C. Ambiguity issues ──> Specification author
                      │
                      ├─> D. Matching against existing verification assets ──┐
                      └─> E. Creating test scenarios ────────────────────────┴─> F. Independent review ─> G. Integration, regression, and measurement
```

<a id="4-準備"></a>

## 4. Preparation

<a id="41-入力物"></a>

### 4.1 Input

|Input|Handling|
| --- | --- |
|Product specifications and IP specifications|The version and revision history are fixed. Assign stable ID to paragraphs|
|Register map|Prefer machine-readable originals (IP-XACT, SystemRDL, spreadsheets). Less prone to misreading than PDF tables|
|Protocol specification (standard, internal)|Pin the version. Distinguish conformance requirements from optional features|
|Time diagram and state transition diagram|Assign each figure a ID and map it to its key points in text|
|Errata and design-decision records|The references are treated as the same as the specification.|
|RTL, testbenches, existing tests/assertions/coverage|The object of the comparison. Fix Commit|

<a id="42-ツール"></a>

### 4.2 Tool

- At least 2 independent verification sources: reference models (C, Python, SystemC), multiple simulators, formal tools, and similar sources.
- Requirement-ledger/proposal checker: serving the same role as [Reference kit](../tools/matching_kit/README.md) in the original procedure, mechanically check requirement ID, observation points, and evidence existence.
- The result of the regression is saved with the commit of RTL, the hash of the test input, the version of the tool, and the seed.

<a id="43-要求台帳の形式"></a>

### 4.3 Requirement-ledger format

The requirement for line 1 must have at least the following items (see Appendix A for examples).

|Item|Content|
| --- | --- |
| `id` |Stable ID. Even if the version of the specification changes, if the meaning is the same, it will not change.|
| `source` |Name, version, section, paragraph of the specification (diagram ID)|
| `kind` |Function/Abnormal input/Boundaries/Reset/Initialization/Configuration/Timing/Performance|
| `priority` |Importance and safety level (such as ASIL)|
| `behavior` / `acceptance` |Requirements and observable criteria for success|
| `observation_point` |Where to observe what.|
| `configuration` |Configuration, parameters, and product variants assumed|
| `issue` |Unsolved ambiguity (forbids approval of correspondence if there is one)|
| `checks` |Mapped verification assets and evidence (empty means unmapped)|

<a id="5-段階a仕様の取り込み"></a>

## 5. Stage A: Specification import

1. Fixes the version of the specification and records the hash of the file.
2. Assign stable ID to clauses, paragraphs, figures, and tables; record each paragraph's hash. This text cannot be stored in the notebook.
3. All paragraphs are categorized into one of the following categories: Requirements, Explanations, Examples, References, Headings. The paragraph of the requirement records which line of the requirement it corresponds to, and also points to the paragraph from the requirement line. In this two-way response, unclassified paragraphs and unregistered corresponding parts are detected mechanically. The errors in the parsing of the requirements contained in a single paragraph and the errors in the classification itself are reviewed separately.
4. When the specification is revised, the changes in the hash paragraphs and their impact on the referenced requirements, diagrams, and verification assets are re-verified. Include paragraphs where the meaning changes when the reference is changed.

Notes for each type of specification:

- Register map: Requirements fields (offset, width, reset value, access type, handling of reserved bits) 1 line by line. Extract from machine-readable originals and record disagreements with PDF as issues.
- Protocol specification: Specifies the types of transactions, handshake rules, order rules, error response, timeout. Distinguish between "can do" (optional function) and "must do".
- IP Specification: Description of the microarchitecture (description of the implementation) and the requirements for the behavior that can be observed from the outside are separated. Exclude the former from verification, or handle it separately through internal assertions.

<a id="6-段階b要求の抽出"></a>

## 6. Stage B: Requirement extraction

<a id="61-単位"></a>

### 6.1 unit

The 1 row is "1 conditions or 1 observations". Divide sentences that describe multiple conditions.

<a id="62-書き方の規則"></a>

### 6.2 Rules of Writing

This is a generalization of what was found when we looked at the logs in the original procedure.

- The observing form is written. Example: "Ignore writes to reserved bits" means "Compare the same initial state and write values of other fields, with the reserved bit set to 0 and 1, and verify that there is no difference in the observations of other fields or external behavior." Check reserved-bit read values separately and use them as expected values only when the specification defines them.
- Do not mix normal-operation and error-case requirements in 1 row(s). The "X is accepted, Y is an error response" is divided into 2 lines.
- Explicitly state the variation allowed by the specification. The scope of latency, the freedom of order of responses, the arbitration method, etc. You should only expect a single value if the specification specifies it.
- The premises of the configuration and implementation dependence are fixed by acceptance conditions. Example: "In the configuration of depth=N of FIFO", "If the upper limit of the burst length is set".
- Separate usage rules (software/system obligations) from device behavior. For example, “software must not write until initialization completes” is not a device requirement.
- The rows that overlap with the existing requirements are not added. If the same requirement appears in multiple sections, it is grouped in a 1 line and has multiple citations.
- Remember requirements for behavior immediately after reset and for initialization. The reset value, the output during the reset, and the first action after the reset is unset.

<a id="7-段階c曖昧さの管理"></a>

## 7. Stage C: Management of ambiguity

- If the description does not fit in the specification, or is undefined, the difference between the figure and the text is a problem, and `issue` is added to the corresponding requirement line. The validation asset is not mapped to the row until the problem is resolved.
- Use one of the following grounds for resolution.
  - Answer from the author of the specification
  - Record of design decisions
  - Decisive grounds within the specification (machine-readable register definition, syntax and table definition, etc.)
- Do not treat issues supported only by inference as resolved.
- After the problem is solved, the requirement is rewritten with the new interpretation and the reasons are recorded. Track whether this is incorporated into specification revisions or errata.
- The internal specifications can be verified by the author, and the problem can be resolved faster and more certainly than the original procedure (standard without official error table). Issue records can also indicate specification quality.

<a id="8-段階d既存の検証資産との照合"></a>

## 8. Step D: Comparison with existing verification assets.

<a id="81-照合の対象"></a>

### 8.1 The object of the comparison

Map existing tests, checkers (scoreboards), assertions, functional-coverage items, and formal properties to requirements.

<a id="82-基準"></a>

### 8.2 criteria

1. The `behavior` and `acceptance` of the requirement and the corresponding paragraphs and diagrams of the specification are read.
2. Read verification assets' stimuli, checker comparisons, assertion expressions, and coverage definitions.
3. The following cases are registered for the corresponding.
   - There are stimuli that generate all conditions of the demand and observations that confirm the reaching of those conditions.
   - Comparisons or assertions can detect results that violate the requirement. The functional coverage is used to confirm the reaching of the condition, and the checker is matched to the judgment of the correct result.
4. The following is not evidence.
   - Only test name and description
   - All I know is that the signals were moving.
   - Assertions that always succeed or yield only vacuous passes, such as implications whose antecedents never occur
   - Comparison with only true inputs
   - The test only looks at the number of objects, and does not look at the identity of the objects.
   - Comparison dependent on the fact that the specification does not determine the order
5. If 1 asset observes only some conditions, use a AND set when multiple assets can jointly cover all conditions. Otherwise, keep it pending and record the reason.
6. Record stimulus locations (test/sequence sites), condition-reachability observation locations (monitors/coverage-item names), and judgment locations (checker comparisons/assertion names) as strings or identifiers in the evidence.

The hit of the functional coverage is the record that observes the condition. Passing a requirement also requires its checker to be enabled and response comparison/assertion evaluation to complete. See also [Sections 4.8 and 4.11 of the Accellera UVM 1.2 User’s Guide](https://www.accellera.org/images/downloads/standards/uvm/uvm_users_guide_1.2.pdf) for this distinction.

<a id="83-実績からの目安"></a>

### 8.3: The criteria based on the actual results.

In the original procedure, approximately 6 to 15% of the uncompliant requirements were adopted by comparison with existing tests. The main reason is that there is no existing test to stimulate the condition of the requirement in the first place. First, we verify the compatibility with existing tests, and we plan to fill the gap with a new test scenario.

<a id="9-段階eテストシナリオの作成"></a>

## 9. Step E: Creation of test scenario.

<a id="91-方式の選び方"></a>

### 9.1 : How to choose a system

|Content of the requirement|Mode|
| --- | --- |
|The values listed in the table (reset value of the register, access type, opcode, error code, pin multiplexing)|Encompass with generator (9.4)|
|Actions that occur in a specific procedure (initialization procedure, specific sequence, error recovery)|Direct test|
|Multiple combinations of operations (data width, burst, parallel transactions)|Constrained random testing and functional coverage linked to requirement ID|
|Properties that should always be true (handshake rules, exclusion control, FIFO overflow prevention)|The functional model is described in SVA and verified by simulation or formal verification.|
|Response to abnormal input (incorrect address, protocol violation, writing of reserved value)|Direct test and checker to verify response|
|Timing (number of cycles, timeout)|Checkers and assertions with permitted ranges|

<a id="92-参照モデル"></a>

### 9.2 Reference Model

- Build it solely from the specification, without looking at RTL. Separate the author of the reference model from the author of RTL.
- The reference model itself is also subject to review. Maintain traceability to specification paragraphs.
- Requirements that do not require cycle accuracy are abstracted at the transaction level.
- When counting multiple reference implementations or simulators as proof of match, make sure they do not share components (front-end, library, model of the source). If shared, the agreement on that part is not independently supported. In the original procedure, the 2 simulators added to the comparison used the same front-end and made the same errors in terms of priority of operators, etc.

<a id="93-チェッカーと期待値"></a>

### 9.3 Checker and expectation

- Accepts the margins (latency, order) allowed by the specification.
- Specifies the handling of X (unknown value), reset, and configuration differences.
- The expected value is written first and verified by simulation. The differences are checked first against the specification and the expected values, and if the error is still on the RTL side, it is recorded as a bug. The expected value is not adjusted to match the output of RTL.

<a id="94-表形式の仕様は生成器で作る"></a>

### 9.4 Table-format specification is generated by generator.

This generalizes the original procedure's verification of header constants and reserved words.

- The reference model of the generator is made from the specification table (if there is a machine-readable original). Check consistency between tables within the generator: field widths sum to the register width, offsets do not overlap, and per-version additions sum to the complete set.
- For registers, cover the following.
  - Reset value
  - Writes and readback for each access type (RW, RO, WO, W1C, W1S, RC)
  - Handling of reserved bits
  - Response to access to undefined address
  - Byte-enable
- It also generates cases of anomalies (writing to a no-write field, addresses outside the range). Derive expected responses (error response, ignored operation, interrupt) from the specification.
- The criteria for determining the product (expected value, position of error response) are determined automatically by the generator. Don't fix it by hand.

<a id="95-構成とバリアント"></a>

### 9.5 Configuration and variants

- Attach configuration preconditions to requirements and run regressions for each configuration.
- Requirements that are not applied by the configuration are recorded as "out of scope for that configuration" instead of being excluded from the denominator.

<a id="96-再現性"></a>

### 9.6 Reproducibility

Record versions of RTL, testbench, and reference model; configurations/parameters; test inputs; tool versions/options; and seeds with every execution result.

<a id="10-段階f独立レビュー"></a>

## 10. Stage F: Independent review.

- Test evaluation: reviewers independently derive expected values (reference-model output and checker criteria) from the specification and compare them. Also check that stimuli meet specification preconditions (negative tests contain only the intended violation), behavior is deterministic, and configuration assumptions are correct. A test that cannot derive the expected value from the specification is a defect.
- The decision of the comparison: It is adopted only when the stimulus causes all the conditions of the requirement and the decision can be distinguished from the misrealisation. Reject uncertain cases.
- Fault injection (mutation): deliberately corrupt RTL operators, constants, or conditions at 1 site(s) at a time, and check that checkers or assertions detect the faults. The undetectable mutation is either the weakness of the test scenario or the inobservable difference (equivalent mutation).
- Large mechanical schemes: We will make a summary decision based on the results of comparison with independently extracted values (e.g., the machine-readable original of the register map and the table of PDF read by another method).
- Horizontal expansion: When a reviewer finds a certain type of defect, he checks all the adopted cases from the same point of view. In the original procedure, we checked the 3 tests which was defective due to an error in a declaration, and found the same error in the adopted 1 tests and the existing 7 tests.

In the original procedure's independent reviews, 30 of 624 new tests were defective (about 5%), and 166 of 2,215 comparison proposals were rejected (about 7%). The only error in the expected value itself was 4 tests. Most issues concern expected values containing unspecified values, stimuli failing specification preconditions, incorrect violation-detection locations, or metadata errors. The reviewer is not only required to recalculate the expected values, but also to verify these.

This is a generalized checklist of the actual holes found in the verification of the original procedure.

|Hole|Countermeasures|
| --- | --- |
|The error is hidden by comparison with a decrease in type and width (cut-off, omission of signedness).|Compares the entire width, detecting values outside the range|
|The stimulation is only on one side of the condition (only true, only when increasing, only one direction).|Add contrasting cases|
|Compares counts without checking which elements they identify|Compare with object identifier and value|
|Undefined names or values are treated as defaults, allowing faults to pass undetected|We also check that the defined function is defined.|
|Depends on matters unspecified by the standard/specification, such as ordering, implementation-dependent widths, or naming|Check against the allowed range, or do not observe it|
|In the test to detect violations, we do not look at whether the location or reason of the diagnosis corresponds to the violation (rejecting for other reasons also passes).|The diagnosis is compared with the location and reason, and the rejection for other reasons is not counted as evidence.|
|The test that you put the violation in, it's overlaid with another unintended violation.|The violation is 1, and the inputs excluding it are verified to meet the specification prerequisites.|
|The comments and marks attached to the test are in themselves a violation of the specification.|The specifications are used to determine where the notes can be placed.|
|The stimulus itself is invalid because of the implicit language and specifications (type of declaration, reset value, handling of reserved fields).|Explicit without default|
|The metadata ( dependence on 4 value, indeterminism, object composition ) is not consistent with the real state, and the choice of the execution environment and the judgment method is wrong.|The metadata is checked mechanically against the actual state.|
|Assertions that produce only vacuous passes|Verify that the antecedent occurs and that consequent evaluation and judgment complete|
|The test depends on undefined behavior and implementation dependency.|Defer the mapping|
|Does not examine structure, such as unions, guards, or overlapping registers|The structure itself is examined by adding a test.|

<a id="11-段階g統合回帰計測"></a>

## 11. Stage G: Integration, Regression, Measurement.

1. Remove defective tests and tests without a judgment.
2. The adopted response is integrated into the table. The merge is tied to the input of the test at that time and the commit of RTL.
3. Run regression and save the results for each version. The results of partial execution are not synthesized with the total result. The AND set is considered to pass only if all tests in the group pass in the same run. In regression, resources (memory, time) are limited per test. Sometimes a test that violates the rules causes the validation tool to crash and stop the entire regression. In the original procedure, the simulator failed to stop recursion in 1 tests containing standard violations, exhausting execution-environment memory (16GB) and halting that night's regression.
4. I will measure and report.

|Metric|Meaning|
| --- | --- |
|Requirement mapping rate|Proportion of requirements mapped to verification assets (test-design stage)|
|Pass rate of requirement|Proportion of requirements with passing evidence matching the version (test-execution stage)|
|Breakdown by importance|Mapping and pass rates by safety level and importance|
|Unsolved problems|Number of ambiguities and days until resolution|
|Fault-injection detection rate|Proportion of mutations detected (excluding equivalent mutations).|

- If all requirements are counted with the same weight, the values in many rows (e.g., fields in the register) that are mechanically generated from the table will move significantly. Always include either importance-weighted values or a breakdown by kind.
- The requirements coverage is a supplement to the code coverage and function coverage, not a substitute for them. Uses 3 in a row to determine the sign-off.
- The two‐way tracking table of requirements and verification required by functional safety and aviation standards can be outputted from the table as it is.

<a id="12-並列化とaiの使い方"></a>

## 12. Parallelization and the use of AI

In the original procedure, we divided the AI agents into authors and reviewers, and moved them in parallel by section.

- The requirements are divided into the scope of responsibility by the unit (about several hundred requirements) without dividing the sections in the order of the sections of the specification.
- The authors (the ones responsible for comparing and creating tests) and the reviewers are placed in groups for each section. Reviewers must read specifications and assets themselves, rather than accepting creators' explanations at face value.
- Keep comparison proposals, judgments, and created-test lists in append-only files. You can stop and resume.
- Estimated consumption (observed with the original procedure): 1 creation/review pairs used approximately (50–65) × 10,000 tokens; 1 reviewers used approximately (15–40) × 10,000 tokens. A verification-only run over 13 ranges used approximately 560 × 10,000 tokens (about 43 × 10,000 per 1 range(s)). The parallelization is consumed in a short time, so we start by reducing the number of sections.
- If you are handling a confidential specification, you should first check the environment in which you can use AI (in your company, the handling of data storage and learning).

<a id="13-導入の進め方"></a>

## 13. How to proceed with the introduction

1. Pilot: 1 Perform a series of procedures on a IP. For example, a small IP with a register block and a 1 bus interface. The process is carried out in the following order: extraction of requirements, comparison with existing assets, generation tests, independent reviews, and measurements.
2. Evaluation: Check the following points.
   - Missed requirements during extraction, and whether paragraph classification detected them
   - Adoption rate of references
   - Number of bugs and specification issues found by new tests
   - Fault-injection detection rate
   - Human and AI effort
3. Expand: Commonize the format, checklist, and generator of the logbook, and extend it to other IP.
4. Feedback to the specification: use issue records and the list of unobservable requirements to improve how the specification is written.

<a id="14-限界"></a>

## 14. Limits

- The electrical characteristics, the quantitative evaluation of the operating frequency and the power consumption, and the analog circuit are excluded. The latency and timeout of the cycle units specified in the function specification are included in the object.
- For designs with large state spaces, formal verification may not finish because of state explosion. Supplement with constrained random testing and coverage.
- If the reference model itself is wrong, the same error as RTL is missed. The reference model needs independent review and traceability to the specification.
- This review of AI is not human endorsement. The person responsible and the method are clearly stated in the logbook and the report.
- The 100% response rate of a requirement does not prove that it covers all the actions of the specification. The coverage of the combination is evaluated separately by functional coverage and formal verification.

<a id="付録a記録の例"></a>

## Appendix A: Examples of records

Requirement line (YAML):

```yaml
id: UART-REG-LCR-WLS-RESET
source: {spec: UART IP Spec, version: "2.3", section: "5.4.2", paragraph: "P0412"}
kind: reset
priority: medium
behavior: After reset, LCR.WLS (word length select) reads 2'b11 (8 data bits).
acceptance: Immediately after reset deassertion, a read of LCR returns WLS = 2'b11 and every other LCR field at its reset value.
observation_point: APB read data of LCR
configuration: all
checks: []
```

The reference scheme (JSON, same as `propose.py add` in the original procedure):

```json
{"requirement_id": "UART-REG-LCR-WLS-RESET",
 "test": "tb/tests/reg_reset_values_test.sv",
 "observation": "リセット解除直後にLCRを読み、WLS=2'b11と他フィールドのリセット値をスコアボードで比較する。",
 "rationale": "WLSのリセット値を2'b00にした誤実装では比較が失敗し、REG_RESET_MISMATCHが報告される。",
 "evidence": [{"file": "tb/tests/reg_reset_values_test.sv", "contains": "read_reg(LCR, data);"},
              {"file": "tb/env/reg_scoreboard.sv", "contains": "REG_RESET_MISMATCH"}]}
```

<a id="付録b元の手順で使ったツールとの対応"></a>

## Appendix B: Compatibility with the tools used in the original procedure

|Original Tool|Generalized role|
| --- | --- |
| `tools/requirement_source.py` |Read the specification paragraph with the hash ID|
| `coverage/requirement-audit.json` |The two‐way response between the classification of all paragraphs and the requirements.|
| `tools/matching_kit/propose.py` |Receive and immediately check comparison proposals (requirement ID citations, observation points, existing evidence, and existing holds).|
| `tools/matching_kit/merge.py` |Integrate only accepted mappings into the ledger|
| `tools/matching_kit/runsim.py` |Displays matches with execution in multiple verification points (simulator, reference model)|
| `generators/` |Generated tests from tabular specifications|
| `tools/behavior_coverage.py` |Ledger checks, measurements, baselines for detecting regressions, and history|

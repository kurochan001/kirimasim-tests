<a id="svaフォーマル検証の拡張境界値と実テストとの対応"></a>

# Extending SVA formal verification: boundary values and mappings to actual tests

[English](sva-formal-expansion-20261026.en.md) / [日本語](sva-formal-expansion-20261026.md)

> At 2026-10-29, reran 228 jobs against the current source and updated the saved JSON and VCD for 3 counterexamples.
> Confirmed 225 expected PASS outcomes and 3 expected FAIL outcomes; `--check-results` also succeeded.
> Model definitions, actual-test mappings, model/configuration hashes, and per-job assessments are unchanged from the previous run.

Added 111 cases to 2026-10-26 following [Basic 40 model](../tools/sva_reference/FORMAL_REVIEW.md), and documented the correspondence between operator boundary values and actual tests. The rerun of 2026-10-29 also passed all 111 BMC proofs and 111 PDR proofs.

This is a separate verification set containing expressions overlapping the basic set. The addition of 40 and 111 does not mean that we have verified different types of 151 expressions. Expected output, `:oracle:`, and simulator execution verification coverage are unchanged.

The relationship between matching 45 test outputs, the basic 40 models, and these 111 cases is documented in [Overall-guide comparison table](sva-reference-formal-verification.en.md#結果の見方).

<a id="何を広げたか"></a>

## What was expanded

The previous round verified representative examples, such as delay bounds 1–3tick. Varied range lower/upper bounds and also checked 0tick, equal bounds, and inclusion of range endpoints.

|Operator grouping|Changed values|Number of cases|
| --- | --- | ---: |
|Delay and concatenation| `a ##[low:high] b`。0 ≤ low ≤ high ≤ 3 | 10 |
|First Match|Add `first_match` to the delay.| 10 |
|Repetition|`a[*low:high]` 。 0 ≤ low ≤ high ≤ 3 。 Include empty matches| 10 |
|Containment|Inner delay 1–3; outer delay 1–3. Combinations where the inner match fits| 6 |
|Conditions for the whole period|Combination of `throughout` and delay range 1–3| 6 |
|Both sequences match|`and` 。 Left delay lower bound 0–2, upper bound from the lower bound to 3; right delay 1–3| 27 |
|Matching at the same length|`intersect` 。 Same delay range as above| 27 |
|Tied first matches|Example where two sequences end on the same tick. Endpoint candidates 1–3| 3 |
|goto and subsequent conditions|Occurrence count 1–3; subsequent delay 0–2| 9 |
| nonconsecutive |Occurrence count 1–3. Includes cases followed by false| 3 |
|Total|| **111** |

Input signals are unconstrained 0 / 1 sequences. For each case, compare a finite-state machine representing the Python evaluator's actual sequence calculation with independently written RTL calculations. The duplication of simultaneous termination can also be checked by comparing the number of matches at each point.

BMC depth is 8 steps for finite patterns and 16 steps for the 12 goto/nonconsecutive cases. For all 111 cases, ABC PDR also proved equivalence without an input-length bound. However, the numerical parameters in the table above are fixed in each case. This is not a universal proof over arbitrary integer parameters or all SVA expressions.

<a id="実テストのどこに関係するか"></a>

## Where this relates to actual tests

Examined 38 tests and 188 directives evaluated with M2 / M3. The 7 sampled-value-function tests in M4 are excluded from this round's sequence-subexpression mappings.

- The 28 and 91 instructions have 127 sequence subexpressions that correspond to the verified model.
- Actually mapped 24 of 111 cases. The remaining 87 case is an additional variation to verify to the nearest boundary value.
- 97 directives with no matching sequence subexpression are also recorded as `no_family_match`.

`bindings` in [The result is JSON.](../tools/sva_reference/fixtures/formal_expanded_results.json) records the test input SHA-256, directive name, original assertion expression, position in the expression tree, subexpression SHA-256, and mapping of corresponding cases to inputs. The double counting of the same subexpression by the expansion of named sequences is avoided.

For example, a subexpression `(x & y) ##1 z` can map to model `a ##1 b`. Assign `x & y`'s judgment result to the model's `a`, and `z`'s result to `b`. 0/1 inputs are all checked by the model, which includes the judgment results that occur in the actual test.

This response is a verification of the part "which seeks the sequence agreement from the determination result of 0 / 1". This does not prove the type, 4-state operations, or sampling time of `x & y` itself, the enclosing property, `disable iff`, action execution, or final displayed output. Mappings depend on the existing Python parser; they do not establish parser correctness using another frontend.

<a id="検査経路自体の確認"></a>

## The inspection path itself is confirmed.

Obtained reachability examples with 3 covers for empty repetitions, containment with coincident inner/outer endpoints, and two sequences ending together at the shortest delay.

Injecting intentional errors into the same 3 cases produced counterexamples in BMC for every case. The faults drop an empty match, drop a containment match, or collapse two simultaneous endpoints into one. [Counterexample VCD and hash index](../tools/sva_reference/fixtures/formal_expanded_counterexamples/index.json) is saved.

`reference_count` in negative-case waveforms may retain values from the correct clause model. Intentionally changed comparison expressions are recorded in index `compared_reference`. For simultaneous-ending examples, both the evaluator and correct model give 2; collapsing the comparison target to 1 produces a counterexample.

Across 228 jobs in total, 225 produced the expected PASS and 3 produced the expected FAIL. FAIL is the result of detecting an expected error. No logic counts UNKNOWN, TIMEOUT, or ERROR as successes.

<a id="再実行"></a>

## Rerun

Run from the repository root. `SBY_BIN` is `sby` in the OSS CAD Suite; specify a new or empty output directory. The commands for the basic 40 model from the previous session can also be used.

```sh
# 111件ずつのBMCとPDR、およびcover・負例検査を実行。
python3 tools/sva_formal_sweep.py --sby "$SBY_BIN" --output-dir "$SWEEP_RUN_DIR"

# 外部ツールを動かさず、モデルと実テストとの対応だけを出力。
python3 tools/sva_formal_sweep.py --emit-only --output-dir "$SWEEP_EXPORT_DIR"

# ソース、テスト、モデル、設定、必要ジョブが保存記録と合うか確認。
# ソルバーの再実行はしない。
python3 tools/sva_formal_sweep.py \
  --check-results "$SWEEP_RUN_DIR/results.json"

# リポジトリに保存した今回の証跡を確認。
python3 tools/sva_formal_sweep.py \
  --check-results tools/sva_reference/fixtures/formal_expanded_results.json
```

Execution environment: Yosys 0.68 + 71, SBY 0.68, Yices 2.7.0, and ABC 1.01. Set the tool's PATH only in child processes. Python model-generation/checking code uses only the standard library.

`tools/sva_formal_cases.py` provides independent RTL expressions; `tools/sva_formal_sweep.py` handles model generation, mapping to actual tests, execution, and evidence checks. Expected-output files are not read. The implementation of the existing evaluator and the basic 40 model has not been changed.

If the source test changes during execution, the results are invalidated, and post-save changes, model/configuration hash discrepancies, and missing required jobs are also detected. Do not hide parse errors at generation as out of range. 12 offline regression checks verify these boundaries without running external formal tools.

<a id="次に残ること"></a>

## Remaining work

Proofs covering whole-assertion success/failure and decision timing, display adapters, scheduling, multiple clocks, 4-state sequences, arbitrary types/arithmetic, and related behavior remain separate work. These results add evidence for sequence calculations appearing in actual tests and nearby boundary values. No dedicated CI job or new certification metadata was added.

At the 2026-10-26 expansion, all 205 unit tests passed, concrete output comparisons for 45 existing tests passed, evidence checks for the basic 40 models and 111 added cases passed, and consistency checks passed for README aggregation, generated tests, catalogs, per-clause test counts, metadata, and the ledger.

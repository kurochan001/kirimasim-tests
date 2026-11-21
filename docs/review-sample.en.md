# Human review of a sample of tests

[English](review-sample.en.md) / [日本語](review-sample.md)

Every expectation in the suite has been checked against the standard by an AI model (`:spec_check: ai`); no person has checked a test yet. Reading every test is not practical, so `tools/review_sample.py` draws tests at random per stratum, records what a person found after deriving the expected output again from the standard, and bounds the error rate of each stratum.

The tool changes neither the tests nor their `:spec_check:` field. The verdicts go to a separate ledger, `coverage/human-review.json`.

## Strata

The tests that are not formal and have no fixed-release oracle (`iverilog@13.0`, `verilator@5.052` or `verilator@5.054` in `:oracle:`) are divided by the latest Nightly results (`latest/<simulator>.json` of the `results` branch).

| Stratum | Tests |
| --- | --- |
| `pass_nowhere` | pass on no simulator |
| `ghost_only` | pass on Ghost and on no other simulator |
| `kirimasim_ghost` | pass on kirimasim and Ghost and on no other simulator |
| `reference_pass` | pass on the latest Icarus Verilog, Verilator or Lyra |

- A result is used only when its run recorded the same input digest as the test has now. If the test changed after the run, that run's result does not place it.
- A result without an input digest per test, such as `latest/<simulator>.json` of the results branch, is used only when git shows no change to the test's input files after the `suite_commit` of the run. When git cannot tell (a shallow clone, for example), a warning is printed and the result is used as it is.
- A test that fits no stratum, such as one that passes on kirimasim alone, is counted but not drawn.
- `--chapter` (repeatable) restricts the strata to chapters. The sample records the chapters it was drawn from.

## Draw a sample

```sh
mkdir -p results/latest
for s in icarus verilator kirimasim lyra ghost; do
  git show origin/results:latest/$s.json > results/latest/$s.json
done
python3 tools/review_sample.py sample --results results/latest --output review-sheet \
  --seed 20261120 --count pass_nowhere=8 --count ghost_only=32 --count kirimasim_ghost=20
```

- Each stratum is drawn from its tests in name order with a random generator seeded from the seed and the stratum name. The same seed and inputs give the same sample, and changing the count of one stratum does not change the sample of another.
- The output is `review-sample.json`, to fill in, and `review-sample.md`, to read (`--language en` for English). Each test has its path, cited clauses, description, expected output (for an illegal design, the reason and the place of the error), the results of each simulator, its input digest and the empty fields.

## Fill in the verdicts

Write four fields for each test in `review-sample.json`:

| Field | Content |
| --- | --- |
| `verdict` | `correct`, `expectation_wrong`, `test_defect` or `contested` (the standard can be read both ways) |
| `basis_clauses` | The clause numbers the decision rests on, such as `13.4.4, 4.7` |
| `reviewer` | The name of the person who reviewed the test |
| `date` | `YYYY-MM-DD` |

`notes` is free text. A test without a verdict is not recorded.

```sh
python3 tools/review_sample.py record review-sheet/review-sample.json
```

- A verdict for a test that changed after the sample was drawn is refused; draw again.
- An unknown verdict, an empty reviewer, date or basis, and a reviewer marked as an AI, such as `(AI)`, are refused. The ledger records reviews by a person only; AI reviews stay in the dated documents as before.
- If any entry is refused, nothing is written. A person who records the same test with the same input again replaces the earlier entry.

## Upper bound on the error rate

```sh
python3 tools/review_sample.py report [--chapter 37] [--json report.json]
```

For each stratum the report gives the number n of tests with a current verdict, the number k of tests found wrong (`expectation_wrong` and `test_defect`), the number of `contested` tests, the number of stale verdicts and a one-sided 95% upper bound on the error rate.

- A test counts once, however many people reviewed it. It is wrong when anyone found it wrong, `contested` when nobody found it wrong and someone found it contested, and correct otherwise.
- Samples are counted per sampling frame. Without `--chapter` only samples drawn from all chapters count; with `--chapter 37` only samples drawn from chapter 37. Samples drawn from different frames are not random draws from one population, so they are not pooled.

- When k = 0 the bound is 3/n (the rule of three): 5% for 60 tests and 1% for 300.
- When k > 0 it is the one-sided 95% Clopper–Pearson bound: the error rate at which the binomial probability P(X ≤ k) is 5%. For very small n (three or fewer), where this can fall below 3/n, 3/n is used, so that finding an error never lowers the bound.
- A `contested` test is not counted as an error and is left out of n, since it is neither right nor wrong; it is counted apart. How tests that read two ways are treated is for the owner to decide.
- A verdict whose test changed after it was recorded is stale and is left out of n. A test whose expectation was fixed is drawn and read again.

`python3 tools/review_sample.py check` validates the ledger; the readme job of Check runs it. A verdict on a test that was renamed or removed is counted as stale, not as an error.

## Difference from the review candidates

[The review candidates](review-candidates.en.md) list every test whose expectation rests only on the reading of the standard. This tool puts an upper bound on the error rate of a whole stratum from a random part of it that a person reads.

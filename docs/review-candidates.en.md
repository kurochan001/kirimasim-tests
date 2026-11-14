<a id="review-candidates"></a>

# Review candidates for expected results

[English](review-candidates.en.md) / [日本語](review-candidates.md)

[How to view Nightly results](nightly-results.en.md) / [Differences between simulators and the standard](simulator-differences.md) / [Clause citation depth](coverage-depth.md)

From the latest results of each simulator, a tool lists the tests and clauses whose expected results rest only on the reading of the standard.
A candidate is not a finding. A review against the standard decides whether the expectation is right or wrong.

## Where the list is and when it changes

[`tools/review_candidates.py`](../tools/review_candidates.py) writes the list from `latest/` of the results branch in every `publish` job of the Nightly.

- [English list](https://github.com/kurochan001/kirimasim-tests/blob/results/review-candidates.md) / [Japanese list](https://github.com/kurochan001/kirimasim-tests/blob/results/review-candidates.ja.md) / [JSON](https://github.com/kurochan001/kirimasim-tests/blob/results/review-candidates.json)
- It reads only the results of Icarus Verilog, Verilator, kirimasim, Lyra and Ghost.
- The list starts with the version, the time and the suite commit of each simulator's results, and marks results of an older commit than the others: on a day when the Lyra job fails, Lyra's results stay those of an earlier run.
- `python3 tools/review_candidates.py --results <latest directory> --output <directory>` writes it locally.

## Kinds of candidates

Tests with `:type: formal` are left out. "Spec only" means a test whose `:oracle:` names neither `iverilog@13.0` nor `verilator@5.052`.

| Kind | Condition | Why it is reviewed |
| --- | --- | --- |
| Spec only, failing on Ghost, kirimasim and Lyra | passes on no simulator and fails, not merely unsupported, on those three | three separate implementations agree on another result, so the expectation is the most likely to be wrong |
| Spec only, passing on kirimasim alone | passes on no other simulator | the test and kirimasim may share a misreading |
| Other spec-only tests passing nowhere | neither of the above | most fail on missing features, but nothing but the reading backs the expectation |
| Release oracle, failing on both Ghost and Lyra | `:oracle:` names Icarus 13.0 or Verilator 5.052 | the expectation may follow the behavior of Icarus or Verilator ([the `test_readmemh_address_range` case](simulator-differences.md)) |
| Clauses whose citing tests are all spec only | a clause of chapters 3 to 40 in scope and without subclauses (`tools/clauses.txt`) whose citing tests in `:lrm:` are all spec only | the whole clause rests on the reading of the standard |

kirimasim and Lyra share slang as their front end, so their agreement on parsing and elaboration is not independent evidence.

## Order of review

A person checks the candidates against the standard in the order of the sections of the list:

1. Spec only, failing on Ghost, kirimasim and Lyra
2. Spec only, passing on kirimasim alone
3. Other spec-only tests passing nowhere
4. Release oracle, failing on both Ghost and Lyra
5. Clauses whose citing tests are all spec only (fewest citing tests first)

Within a section, the order is that of the test paths.

## Recording a review

- A review is recorded as `docs/spec-only-review-<date>.md` and its English version, in the form of the [review of tests disagreeing with Lyra](lyra-disagreement-review-20261025.en.md).
- When an expectation is right, the test's comment gains the clauses that support it.
- When it is wrong, the expectation is fixed, and the test's comment and the [history](history.md) give the reason and the clauses cited. Generated tests are fixed in their generators.
- `:spec_check: ai` stays as it is until a person checks the test.

Recorded reviews:

- [2026-11-09](spec-only-review-20261109.en.md)
- [2026-11-12: tests that no simulator passes](pass-nowhere-review-20261112.en.md)

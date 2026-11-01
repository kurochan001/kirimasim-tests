<a id="ieee-1800-2023-全要求の洗い出し結果"></a>

# IEEE 1800-2023 Complete requirement-extraction results

[English](requirement-extraction.en.md) / [日本語](requirement-extraction.md)

2026-10-22, the document verification and registration of the requirements of the standard material provided has been completed. Inconsistent statements within the material were also extracted, and reconsideration of 2026-10-24 and 2026-10-28 resolved the interpretation holds. Merged 21 duplicate rows at 2026-10-28 and approved the denominator. Mapping all tests remains in progress.

<a id="確認範囲と結果"></a>

## Scope and results

- The chapter 1–41 of this paper and the appendix A–Q: 1,740/1,740 section ( 100% ) are included.
- Normative part: 1,703/1,703 clauses (100%). The 37 informative clauses have also been reviewed.
- Source block: 15,846/15,846 ( 100% ). The requirements, headings, explanations, examples, and references to other sections are classified.
- Registration: 12,298 row (accepted denominator). The extraction was done with the 12,319 row, which added the 12,214 row to the initial 105 row, and merged the duplicate 21 row in the denominator review.
- Pending interpretations: 0. Of the initial 46 issues, 42 clauses, and 49 rows, resolved 27 issues at 2026-10-24 and the remaining 19 issues, 20 clauses, and 21 rows at 2026-10-28. [Interpretation and Re-examination Record](requirement-extraction-notes.en.md) 。
- Normative clauses without pending interpretations: 1,703/1,703 clauses (100%).
- Denominator acceptance: `approved` ( 2026-10-28, AI ) Review. This is not an independent review or approval by a person). [Approval grounds and limits](denominator-review-20261028.en.md) 。

Scope also includes parent headings' own introductory text, footnotes, grammar alternatives/omission conditions, table values, VPI diagram relations/multiplicities, API types/return values, formula boundaries, and C headers/algorithms. PDF images were also compared with the areas that could be misunderstood by text alone, such as formulas and diagrams, and the verification method was recorded in the audit log. Chapter 41 confirms the explanation of the discontinuation and does not have any current actions. Informative Annexes D, E, O, P, and Q are not included in the normative-requirement denominator. Annex C has different normative/informative designations in the summary and main text; use the main text's normative designation.

<a id="2026-10-24の台帳見直し"></a>

## Ledger review for 2026-10-24

The line which was registered in the test as not observable was corrected to observable without changing the meaning. The requirement ID and the source block are unchanged, so the registration line (12,319) is unchanged. The denominator identifier (SHA-256) has been updated because the requirement statement and the class have changed. The reference values are rewritten with reasons.

- 503 reserved-word rows: 248 rows from Annex B, 248 edition-specific reservation rows from 22.14.x, and 7 edition-set rows (6 VERSION-SET rows and NOCONFIG-BASE).
  - A spelling's reserved status can be observed only by rejection when it is used as an unescaped identifier. Therefore, changed the kind from a positive case to a test of a standard violation (5.6).
  - The keyword set when not writing `begin_keywords` is implementation dependent (22.14), so I write it as a refusal within the scope of the version specified.
  - The latter part of the Annex B row (edition selection and escaped-identifier rules) overlaps existing 5.6.1 and 22.14 rows, so it remains assigned to those rows.
  - The 22.14.9 row stating “1800-2017 and 1800-2023 add no new reserved words” is unchanged because it contains a condition that is difficult to observe.
- 46 pending interpretation issues:
  - The 27 argument was resolved as having a decisive basis within the standard. Supporting evidence consists of normative headers (Annexes I/K/M), API and syntax/table definitions, and formulas uniquely restorable consistently with text or other expressions defining the same concept.
  - Rewrote resolved issues' requirement text using the adopted interpretations and completed 22 clauses.
  - The judgement is made by the agent for analysis and another agent for verification attempts to refute it. This is not an official correction or interpretation of IEEE.
  - At this point, kept 19 issues pending because normative statements materially conflict. The judgement of each argument at the time is left in [Interpretation and Re-examination Record](requirement-extraction-notes.en.md).

<a id="2026-10-28の分母レビュー"></a>

## The denominator review of 2026-10-28

The interpretation of the remaining 19 argument and 21 line is resolved based on the basis of this article or the explicit policy choice. Consolidated the duplicate 21 row, restored the source of the block unit to the 89 row of the initial row, and accepted the 12,298 requirement as a denominator. Retain 3 rows with clause-level sources only. For the interpretation adopted, the duplicate candidates retained, and the limits of the citations, see [Denominator review](denominator-review-20261028.en.md).

The 100% above is the percentage of the document that has been checked and classified in each section and block. This is not a representation of the test coverage of all specification operations 100%.

The registration line contains the occurrences of the same requirement in separate sections, the verification items by condition, and the specific observation cases of the initial phase. The 12,319 row at the time of extraction was a provisional number of registrations. The validated denominator is the 12,298 row after the duplication is sorted. The 12,214 rows in the additional extraction are all bidirectional to the source block. Of the initial 105 rows, 92 had only clause-level supporting sources; these were reviewed in the denominator review above.

`coverage/behaviors.json`'s `denominator_review.state` is `approved`. Merely reading every clause does not automatically approve the behavioral-coverage denominator for the entire standard. If a new interpretation issue arises, suspend mapping approval for that row and return the affected clause to `in_progress`. Display material review, denominator approval, test mappings, and verified execution separately.

When requirement extraction finished, before further existing-test comparisons, 94 rows had test mappings and 85 rows had recorded passes for the current inputs. The unconfirmed match does not mean that the case does not exist in the existing test. This task does not add a test. See [Provisional and definitive values and aggregation by operation and environment](behavior-coverage-summary.en.md).

<a id="保存先と更新"></a>

## Save and Update

- [Requirement ledger](../coverage/behaviors.json): stable ID, behavior, pass criteria, normative classification, sources, and test mappings.
- [Source check](../coverage/requirement-audit.json): classification of all clauses/blocks, mappings to requirements, and figure/table review methods.
- [Index of references](../coverage/requirement-source-index.json): The hash and physical page and row position of the original, each section, each block.
- [Clause ledger](../coverage/standard-sections.json): normative/informative status, clause status, and review rationale.
- [Interpretation and Re-examination Record](requirement-extraction-notes.en.md): Sources and influences of 46 argument, and guidance to the judgment of 2026-10-24 and 2026-10-28.
- [Management procedures](../coverage/README.en.md): Test matching, evidence updating, and denominator management method.

The original is `IEEE_Std_1800-2023_SystemVerilog.pdf` in a data directory outside the repository (default is `IEEE_1800-2023_SystemVerilog` next to the repository, changed by the environment variable `IEEE1800_SOURCE`). The PDF 1,354 pages are used as a reference for the location, and the cache of the specification text itself is not copied to the repository.

Verify command:

```sh
python3 tools/behavior_coverage.py --check --require-source-reviewed \
  --verify-source ../IEEE_1800-2023_SystemVerilog
python3 tools/import_standard_sections.py ../IEEE_1800-2023_SystemVerilog --check
python3 -m unittest discover -s tools -p 'test_behavior_coverage.py'
python3 -m unittest discover -s tools -p 'test_requirement_audit.py'
```

CI also requires all materials to be reviewed and uses baselines to detect removal of reviewed clauses. `--require-complete` requires all of interpretation, denominator approval, test mappings, and successful execution. The denominator and interpretation are approved, but the requirements for non-match and no record of pass results remain, so it will fail as intended at this time. The audit is a confirmation by AI, and the success of the mechanical inspection does not prove the correctness of the standard interpretation or the approval of an independent person.

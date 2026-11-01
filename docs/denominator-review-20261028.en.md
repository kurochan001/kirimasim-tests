<a id="分母レビュー-2026-10-28"></a>

# Denominator review 2026-10-28

[English](denominator-review-20261028.en.md) / [日本語](denominator-review-20261028.md)

> Counts, percentages, and pending statuses in this document record their respective work dates.
> The current value is [Aggregated Summary](behavior-coverage-summary.en.md); the approval history for the denominator and interpretations is in
> See [Results of requirement extraction](requirement-extraction.en.md).

Record of approving the IEEE 1800-2023 requirement ledger as a semantically unique denominator. This review was performed by AI; it is not independent human review/approval.

<a id="入力の同一性"></a>

## Input identity

- PDF: `IEEE_Std_1800-2023_SystemVerilog.pdf`
  - SHA-256 `43d042a2…d1a14` (matching `pdf_sha256` in `requirement-audit.json`)
- Extract text: `lrm_pdftotext_layout.txt`
  - SHA-256 `ee84b2d1…56dc` (matches `text_sha256`)
- Clause: 1,740 (normative 1,703, no_behavior 37)
- Registered rows: 12,319 → 12,298

<a id="1-解釈の解決21行19論点"></a>

## 1. Interpretation resolutions (21 rows, 19 issues)

|Classification|Number of rows|Content|
|---|---:|---|
|Resolved by the text| 11 |Uniquely determined from the clause's normative text|
|Policy selection| 9 |Resolve conflicts between normative statements by prioritizing specific rules and shall requirements|
|Left in place| 1 → 0 |Resolved 31.4.4 by restricting it to simultaneous edges being prohibited precondition violations under the standard|

Main options:

- 9.3.4: “all variables static” is the default-storage rule. Retain automatic in 6.21 as an exception.
- 9.4.2: only a bare chandle reference is an exception to 6.14.
- 16.13.2: Strength is the omission rule of 16.12.2 (assert/assume is weak).
- 19.5.7: literal 4-value bins are `===` of 19.5.4. Warning and removal only for x/z derived from the equation.
- 19.11.1: the enum denominator is the number of enumeration values, without capping it at `auto_bin_max`.
- 20.4.3: `units_number` is -15 .. 2 and `precision_number` are decimal-place counts.
- 28.12.2: unconditionally apply range merging when both sides are ambiguous.
- 33.4.3: accept `use #()` as a reset of all parameters.
- N.2: fixed width of 32 bits, modulo 2^32.
- 31.4.4: restrict to pulses at different times; simultaneous edges are precondition violations.

Citations were mechanically validated as substrings of extracted text. Rendered PDF with 400dpi and visually checked figures such as 37.80.

<a id="2-重複の統合25候補"></a>

## 2. Duplicate integration (25 candidate)

|Decision|Candidate|Number of rows|
|---|---:|---:|
|Integration| 21 |21 row deleted, 20 row updated|
|Retained| 4 |5 rows (different kinds or sources)|
|Preserving exact matches|3 group|6 rows (different observation targets)|

- Merged only rows with the same clause, kind, and obligation when old-row information could be transferred into the survivor's `source_spans` and `checks`.
- There is no missing citation because the initial line does not have `source_spans`.
- Examples retained: `7.8.6` (boundary differs from normal), `19.7 CROSS-RETAIN` (combination of normal and error), and `34.5.12.2` / `34.5.25.2` (different obligations for encryption and decryption).
- Retained the 2 exact-match rows for `37.85`, with an outstanding task to state the observation differences between `vpiRegArray` and `vpiMemory` explicitly in behavior.

<a id="3-出典の復元92行"></a>

## 3. Restore source (92 line)

|Decision|Number of rows|
|---|---:|
|Restore block-level `source_spans`| 89 |
|Only section units (blocks do not define obligations)| 3 |

3 unresolved rows:

- `SV2023-6.24.3-ARRAY-TO-BITS` (the text does not give packing order for fixed-size unpacked arrays)
- `SV2023-20.3.2-STIME-ROUNDING` (no explicit text specifying rounding toward $stime)
- `SV2023-20.14.2-UNIFORM-SINGLETON` (no block defining the singleton at equal boundaries)

The 3 line was not deleted, but left as a line with only the source of the clause unit. Excluded from the claim that denominator entries are unique at block level.

<a id="4-承認"></a>

## 4. Approval

`denominator_review` of `coverage/behaviors.json`:

- `state`: `approved`
- `reviewer`: `DeepSeek V4.1 Flash (AI); not an independent human review`
- `reviewed_on`: `2026-10-28`
- Audit of sections: 1,703 / 1,703
- Registered rows: 12,298
- Confirmed value: design 89.28% (10,980 / 12,298)
- Run: 59.44% (7,310 / 12,298, including Ghost) / excluding Ghost: 50.83% (6,251)

<a id="5-再現手順"></a>

## 5. Reproduction procedure

```sh
python3 tools/behavior_coverage.py --update --require-source-reviewed \
  --write-baseline --reason 'denominator review'
python3 tools/requirement_matching.py --update
python3 tools/suite_stats.py --update
python3 tools/suite_catalog.py --update
python3 tools/coverage_depth.py --update
python3 tools/behavior_coverage.py --check --require-source-reviewed
python3 tools/requirement_matching.py --check
python3 tools/suite_stats.py --check
python3 tools/suite_catalog.py --check
python3 tools/coverage_depth.py --check --minimum-tests 2
python3 generators/generate.py --check
```

<a id="6-限界"></a>

## 6. Limits

- Approval is based on AI review, not independent human approval.
- 3 rows lack block-level sources.
- 31.4.4 contains a policy choice that makes the concurrent edge a precondition violation.
- Retained 4 candidates (5 rows) without integration. Of these, `37.85` still requires an added witness.
- Ghost evidence was added by concurrent work and is outside this review.

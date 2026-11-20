# Triage of the requirements without tests (2026-11-20)

[English](unmapped-requirements-20261120.en.md) / [日本語](unmapped-requirements-20261120.md)

The 847 rows of the requirement ledger (`coverage/behaviors.json`) that had no test at main `d631c049` were sorted by whether one run can observe them. The sorting was done by an AI model, not checked by a person. Nothing is decided about the denominator; that is for the owner. The category, reason and suggested observation of each row are in [the data](measurements/2026-11-20/unmapped-requirements.json).

<a id="categories"></a>

## Categories

- One run: one run of one design shows the whole behavior and acceptance of the row, by the compared standard output or by an error at the line of a violation (with VPI or DPI C code where needed), and nothing the standard leaves open decides the output.
- Needs setup: it needs two runs, a tool option, a library map file, separate compilation, encryption tooling, a control point no API exposes, or a feature that no simulator can be expected to offer in one run.
- Out-of-scope candidate: the standard leaves the result open (undefined, implementation-defined or optional), the row only defines, permits or recommends, it is a rule for tools other than simulators, or it is a statement about the whole standard.

Clause 34 follows [the protected envelope boundary](protected-envelope-boundary.en.md): its definition rows are out-of-scope candidates and the rows that need encryption tooling need setup.

<a id="counts"></a>

## Rows per clause

| Clause or annex | One run | Needs setup | Out-of-scope candidate | Total |
| --- | ---: | ---: | ---: | ---: |
| 2 | 0 | 0 | 2 | 2 |
| 3 | 4 | 5 | 5 | 14 |
| 4 | 0 | 5 | 12 | 17 |
| 5 | 1 | 0 | 8 | 9 |
| 6 | 2 | 0 | 7 | 9 |
| 7 | 7 | 0 | 3 | 10 |
| 8 | 4 | 0 | 12 | 16 |
| 9 | 2 | 0 | 7 | 9 |
| 10 | 2 | 0 | 7 | 9 |
| 11 | 4 | 1 | 6 | 11 |
| 12 | 9 | 0 | 5 | 14 |
| 13 | 5 | 0 | 3 | 8 |
| 14 | 1 | 0 | 0 | 1 |
| 15 | 2 | 0 | 2 | 4 |
| 16 | 3 | 0 | 5 | 8 |
| 17 | 4 | 0 | 8 | 12 |
| 18 | 1 | 0 | 7 | 8 |
| 19 | 3 | 2 | 3 | 8 |
| 20 | 9 | 0 | 11 | 20 |
| 21 | 9 | 0 | 12 | 21 |
| 22 | 1 | 0 | 7 | 8 |
| 23 | 3 | 1 | 2 | 6 |
| 24 | 1 | 0 | 3 | 4 |
| 25 | 4 | 0 | 1 | 5 |
| 26 | 3 | 0 | 0 | 3 |
| 27 | 4 | 0 | 0 | 4 |
| 28 | 8 | 0 | 2 | 10 |
| 29 | 3 | 0 | 0 | 3 |
| 30 | 0 | 6 | 1 | 7 |
| 31 | 2 | 22 | 1 | 25 |
| 32 | 0 | 12 | 0 | 12 |
| 33 | 0 | 20 | 2 | 22 |
| 34 | 0 | 109 | 100 | 209 |
| 35 | 6 | 3 | 13 | 22 |
| 36 | 2 | 10 | 3 | 15 |
| 37 | 56 | 17 | 18 | 91 |
| 38 | 25 | 28 | 12 | 65 |
| 39 | 13 | 0 | 0 | 13 |
| 40 | 2 | 0 | 4 | 6 |
| A | 10 | 3 | 2 | 15 |
| C | 7 | 0 | 4 | 11 |
| G | 7 | 0 | 0 | 7 |
| H | 3 | 17 | 10 | 30 |
| I | 8 | 4 | 1 | 13 |
| J | 0 | 12 | 4 | 16 |
| K | 2 | 0 | 1 | 3 |
| L | 0 | 2 | 1 | 3 |
| M | 3 | 0 | 2 | 5 |
| N | 0 | 0 | 4 | 4 |
| Total | 245 | 279 | 323 | 847 |

<a id="priority"></a>

## One-run rows of the clauses with priority

The order of the request (clauses 33, 38, 31, 35, 20 and 21). Tests are added for these.

- Clause 33: none.
- Clause 38 (25 rows): `SV2023-38.16-EXTRACT-ARRAY-FORMAT-ERROR`, `SV2023-38.16-EXTRACT-ARRAY-GET-ELIGIBILITY`, `SV2023-38.17-EXTRACT-VLOG-ARGUMENTS`, `SV2023-38.30-EXTRACT-PRINTF-OUTPUT`, `SV2023-38.34-EXTRACT-PROCEDURAL-FORCE-RELEASE`, `SV2023-38.34-EXTRACT-PUT-FORMAT-ERROR`, `SV2023-38.34-EXTRACT-PUT-VALUE-TARGETS`, `SV2023-38.34-EXTRACT-UDP-NO-DELAY`, `SV2023-38.35-EXTRACT-PUT-ARRAY-NO-DELAY`, `SV2023-38.35-EXTRACT-PUT-ARRAY-TARGET`, `SV2023-38.35-EXTRACT-PUT-ARRAY-UNSUPPORTED-FORMAT`, `SV2023-38.36.1-EXTRACT-BITSELECT-CALLBACK-ERROR`, `SV2023-38.36.1-EXTRACT-CALLBACK-FORMAT-VPISCALARVAL`, `SV2023-38.36.1-EXTRACT-EVENT-CALLBACK-OBJECT`, `SV2023-38.36.1-EXTRACT-EVENT-CBCREATEOBJ`, `SV2023-38.36.1-EXTRACT-EVENT-CBENDOFFRAME`, `SV2023-38.36.1-EXTRACT-EVENT-CBENDOFTHREAD`, `SV2023-38.36.1-EXTRACT-EVENT-CBSTARTOFFRAME`, `SV2023-38.36.1-EXTRACT-EVENT-CBSTARTOFTHREAD`, `SV2023-38.36.1-EXTRACT-EVENT-CBVALUECHANGE`, `SV2023-38.36.2-EXTRACT-READWRITE-READONLY-ERROR`, `SV2023-38.36.2-EXTRACT-START-ZERO-DELAY-ERROR`, `SV2023-38.36.2-EXTRACT-TIME-CALLBACK-STRUCTURE`, `SV2023-38.36.2-EXTRACT-TIME-CBREADONLYSYNCH`, `SV2023-38.38-EXTRACT-RELEASE-HANDLE-RESULT`
- Clause 31 (2 rows): `SV2023-31.3.3-EXTRACT-DATA-ROLE`, `SV2023-31.3.3-EXTRACT-REFERENCE-ROLE`
- Clause 35 (6 rows): `SV2023-35.5.3-EXTRACT-CONTEXT-NONTRANSITIVE`, `SV2023-35.5.3-EXTRACT-OPTIMIZATION-BARRIER`, `SV2023-35.8-EXTRACT-NO-TASK-FROM-FUNCTION`, `SV2023-35.9-EXTRACT-DISABLE-PROTOCOL-FATAL`, `SV2023-35.9-EXTRACT-DISABLED-NO-EXPORT`, `SV2023-35.9-EXTRACT-FUNCTION-DISABLE-ACK`
- Clause 20 (9 rows): `SV2023-20.6.2-EXTRACT-BITS-DYNAMIC-RESTRICTIONS`, `SV2023-20.6.3-EXTRACT-ISUNBOUNDED`, `SV2023-20.10.1-EXTRACT-ELABORATION-CONTEXT`, `SV2023-20.10.1-EXTRACT-ELABORATION-DIAGNOSTICS`, `SV2023-20.10.1-EXTRACT-ELABORATION-ERROR`, `SV2023-20.10.1-EXTRACT-ELABORATION-EXECUTION`, `SV2023-20.10.1-EXTRACT-ELABORATION-FATAL`, `SV2023-20.10.1-EXTRACT-ELABORATION-NONERROR`, `SV2023-20.16-EXTRACT-PLA-OUTPUT-VARIABLE`
- Clause 21 (9 rows): `SV2023-21.3.4.3-EXTRACT-SCAN-SUPPRESSION`, `SV2023-21.4-EXTRACT-FILE-ADDRESS-RANGE-ERROR`, `SV2023-21.4-EXTRACT-MEMORY-TEXT-LEXICAL`, `SV2023-21.4.2-EXTRACT-ENUM-LOAD`, `SV2023-21.7.3.6.1-EXTRACT-VCDCLOSE`, `SV2023-21.7.4.1-EXTRACT-EXTENDED-HEADER-GRAMMAR`, `SV2023-21.7.4.1-EXTRACT-EXTENDED-NO-PARTS`, `SV2023-21.7.4.1-EXTRACT-EXTENDED-REAL`, `SV2023-21.7.4.2-EXTRACT-PORT-NODE-GRAMMAR`

In clause 31 only the two rows with positive limits are observable, because negative limits and checks on delayed signals depend on a tool option.

<a id="coverage-database"></a>

## `$set_coverage_db_name` and `$load_coverage_db`

19.9 has `$set_coverage_db_name` name the database into which coverage information is saved at the end of a run, and `$load_coverage_db` load cumulative information from another file. The first saves after the run, in a format the tool decides; the second needs a database that an earlier run wrote. Neither can be observed in the output of one run, so no test is written. `SV2023-19.9-EXTRACT-SET-DATABASE-NAME` and `SV2023-19.9-EXTRACT-LOAD-DATABASE` need setup.

<a id="single-use"></a>

## System tasks and functions used by one test only

These 21 still appear in the code of only one test; a second test with another stimulus is added for each: `$async$and$plane`, `$async$nand$array`, `$async$nand$plane`, `$async$nor$array`, `$async$nor$plane`, `$async$or$array`, `$changing_gclk`, `$fdisplayh`, `$fdisplayo`, `$fmonitorb`, `$fmonitorh`, `$fmonitoro`, `$fstrobeb`, `$fstrobeh`, `$fstrobeo`, `$fwriteb`, `$fwriteo`, `$monitorh`, `$monitoro`, `$strobeb`, `$strobeo`.

<a id="no-fixed-oracle"></a>

## Clauses without a test with a fixed-release oracle

188 of the 930 leaf clauses in scope have no test with a fixed-release oracle (`iverilog@13.0`, `verilator@5.052` or `verilator@5.054`). In clauses 3 to 15 and 20 to 28 they are these 39; whether tests in a form that Icarus Verilog 13.0 or a fixed Verilator release can reproduce can be added is examined for each.

4.4.2.5 4.9.2 6.6.4.1 6.6.4.2 6.6.8 6.7.2 6.7.3 6.22.6 7.3.2 7.9.8 8.26.4 8.26.6.2 8.29 8.30.1 8.30.2 8.30.3 8.30.4 8.30.5 9.4.4 10.10.3 11.9 12.6.1 12.6.2 12.6.3 15.5.4 15.5.5.1 15.5.5.2 15.5.5.3 20.16.1 20.16.2 20.16.3 20.16.4 23.3.3.7.1 23.3.3.7.2 24.6 25.6 28.15.2 28.16.2.1 28.16.2.2

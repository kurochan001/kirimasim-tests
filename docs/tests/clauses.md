<a id="テストが引用する条項"></a>

# Clauses cited by the tests

[English](clauses.md) / [日本語](clauses.ja.md)

A cited clause is a navigation aid, not proof of all its behaviors: [what a citation count can establish](../faq.en.md#q17-do-two-tests-per-clause-cover-every-behavior).

[All chapters](README.md). For each clause of IEEE 1800-2023 from 3 to 40, this page counts the clauses without subclauses of its own, the numbers in `tools/clauses.txt`, by whether a test cites them in `:lrm:`. A clause can also be cited only through a parent clause, which says less about what is tested. Clauses that set out no behavior of their own, clause 34, behavior left to the tool or its setup, and the content of VCD files are out of scope (the tags of `tools/clauses.txt`). The page is written by `tools/suite_catalog.py`.

Of 1095 clauses in scope, 1095 are cited by a test, 0 only through a parent clause, and 0 not at all; 64 are out of scope.

| Clause | Title | Cited | Only through a parent | Not cited | Out of scope |
| ---: | --- | ---: | ---: | ---: | ---: |
| 3 | Design and verification building blocks | 17 ||| 1 |
| 4 | Scheduling semantics | 32 ||| 3 |
| 5 | Lexical conventions | 16 ||| 1 |
| 6 | Data types | 76 ||| 1 |
| 7 | Aggregate data types | 49 ||| 2 |
| 8 | Classes | 43 ||| 1 |
| 9 | Processes | 25 ||| 1 |
| 10 | Assignment statements | 18 ||| 1 |
| 11 | Operators and expressions | 42 ||| 2 |
| 12 | Procedural programming statements | 20 ||| 1 |
| 13 | Tasks and functions (subroutines) | 15 ||| 1 |
| 14 | Clocking blocks | 15 ||| 2 |
| 15 | Interprocess synchronization and communication | 21 ||| 1 |
| 16 | Assertions | 69 ||| 2 |
| 17 | Checkers | 11 ||||
| 18 | Constrained random value generation | 44 ||| 2 |
| 19 | Functional coverage | 24 ||| 1 |
| 20 | Utility system tasks and system functions | 32 ||| 2 |
| 21 | Input/output system tasks and system functions | 48 ||| 3 |
| 22 | Compiler directives | 22 ||| 2 |
| 23 | Modules and hierarchy | 34 ||| 1 |
| 24 | Programs | 7 ||| 1 |
| 25 | Interfaces | 12 ||| 8 |
| 26 | Packages | 6 ||| 1 |
| 27 | Generate constructs | 5 ||| 1 |
| 28 | Gate-level and switch-level modeling | 26 ||| 2 |
| 29 | User-defined primitives | 14 ||| 1 |
| 30 | Specify blocks | 23 ||| 1 |
| 31 | Timing checks | 21 ||| 1 |
| 32 | Backannotation using the standard delay format | 11 ||| 1 |
| 33 | Configuring the contents of a design | 19 ||| 8 |
| 34 | Protected envelopes | 68 ||| 1 |
| 35 | Direct programming interface | 21 ||| 1 |
| 36 | Programming language interface (PLI/VPI) overview | 21 ||| 1 |
| 37 | VPI object model diagrams | 96 ||| 1 |
| 38 | VPI routine definitions | 47 ||||
| 39 | Assertion API | 7 ||| 2 |
| 40 | Code coverage control and API | 18 ||| 2 |

<a id="まだ引用されていない条項"></a>

## Not cited yet

Clauses in scope that no test cites; those marked with * have a parent clause that a test cites.

None.

<a id="対象外"></a>

## Out of scope

- `none`, it sets out no behavior of its own: 3.1, 4.1, 4.2, 4.8, 5.1, 6.1, 7.1, 7.11, 8.1, 9.1, 10.1, 11.1, 11.6.3, 12.1, 13.1, 14.1, 14.8, 15.1, 16.1, 16.13.4, 18.1, 18.2, 19.1, 20.1, 20.13, 21.1, 22.1, 22.14.1, 23.1, 24.1, 25.1, 25.3.1, 25.5.1, 25.5.2, 25.5.3, 25.7.1, 25.7.2, 25.7.3, 26.1, 27.1, 28.1, 28.2, 29.1, 30.1, 31.1, 32.1, 33.1, 35.1, 36.1, 37.1, 39.1, 39.2, 40.1, 40.4.8
- `excluded`, clause 34, protected envelopes: 34.1
- `tool`, left to the tool or its setup: 33.2.2, 33.6.2, 33.6.3, 33.6.4, 33.6.5, 33.8.2, 33.8.3
- `dump`, the content of VCD files: 21.7.2.4, 21.7.4.4

<a id="一覧にない引用番号"></a>

## Cited numbers missing from the list

These numbers are cited by tests but are not in `tools/clauses.txt`; either the citation or the list needs a correction: 6.3.3, 6.12.2.

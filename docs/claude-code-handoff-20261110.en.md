<a id="handoff-2026-11-10"></a>

# Handoff 2026-11-10

[English](claude-code-handoff-20261110.en.md) / [日本語](claude-code-handoff-20261110.md)

This hands over the work on the external review of 2026-11-09 and the decisions made after it.
The figures are those of `0370f9d4`. See the [generated summary](behavior-coverage-summary.en.md) for the latest values and the [history](history.md) for each step.

<a id="state"></a>

## Current state

- Design coverage is 90.14% (11,086/12,298).
- Execution coverage from the tools anyone can reproduce (Icarus Verilog, Verilator and SymbiYosys) is 51.12% (6,287/12,298). This is the figure given first.
- With Ghost, execution coverage is 78.00% (9,592/12,298).

| Commit | What it does |
| --- | --- |
| `9eab9bf2`–`829671c2` | The six items of the external review: execution coverage without Ghost, the list of expectations to review, the review of spec-only tests, mappings and tests for chapters 4, 14, 24, 25, 33 and 40, tests for the 2023 additions, and a results history without simulators that have no runner |
| `03fcaf19` | The Nightly builds Lyra in a job of its own, `lyra-build`, so the tests get the whole 6-hour limit |
| `6f4bc48b` | 18 differences of Verilator 5.052 in the new tests are in the [simulator differences](simulator-differences.md#tests-added-20261109) |
| `3d4f871a` | `tools/differences_status.py` reads code that holds backticks, so 12 more listed tests count in its report |
| `d1bc6396` | The README, FAQ Q16 and the summary give the execution coverage without Ghost first |
| `908d00f9` | Five run-time error requirements (15.3.2–15.3.4, 25.7.4, 25.9) are normal requirements now and mapped to their tests |
| `0370f9d4` | Pinned slang as a reference ([slang reference](slang-reference.en.md)), counted nowhere |

The differences found in kirimasim were reported as kirimasim issues #116 to #120.

<a id="next-nightly"></a>

## What to check first

The Nightly of 2026-11-10 is the first since the Lyra build has a job of its own. Check:

- whether the `lyra-build` and `lyra` jobs both succeed within their limits;
- how the matches of each simulator changed since the last run;
- whether the `results` branch has the list of expectations to review (`review-candidates.md`);
- whether the report of the listed differences (`differences-on-master.md`) includes the 12 tests it now picks up.

<a id="open-decisions"></a>

## Waiting for a decision

- How to treat `ch3/test_compilation_unit_shared_across_files`. 3.12.1 leaves to the tool which files form one compilation unit, but the test takes one of the choices as a rule. There are two options:
  - state the use it needs in the test and let the runner choose it;
  - leave it out of the normal runs.
- Four legal tests that slang rejects and that are unclear: `ch17/test_checker_always_statement_kinds`, `ch18/test_inline_local_scope_binding`, `ch22/test_ifdef_directive_names_not_defined`, `ch33/test_duplicate_cell_last_definition_wins`.
- Whether to look into the following two groups. Each report to slang is decided on its own.
  - the 48 legal tests for which slang is stricter than the standard;
  - the 48 illegal tests that both slang and kirimasim accept.

<a id="deferred"></a>

## Decided, to do later

- About 13 existing tests observe a requirement without citing its clause. Their citations are added when Ghost's results are next saved again. A citation changes the input digest of the test, which makes saved results stale.
- VCD tests are on hold. They come after slang.
- The history of the `results` branch is not rewritten.
- The slang version follows kirimasim's pin. When kirimasim changes it, build the driver again and add a new dated record.

<a id="rules"></a>

## Working rules

- Expected results come from the clauses of the standard, never from a simulator's output.
- No commercial simulator is run or compared. The source of GPL/LGPL implementations (such as Icarus Verilog and Verilator) is neither read nor copied.
- Documents are updated in English and Japanese together. Then run `tools/documentation_languages.py` with `--update`, `--record` and `--check`, in that order.
- One commit per item. A commit reaches `main` only after the Check of the one before it has passed.
- A change to metadata, to how figures are counted or to how the `results` branch is handled is proposed and approved first.
- Generated tests are fixed in their generator. Generated files are never edited by hand.
- When a test's expectation is fixed, its reason and the cited clause go into the test's comment and the history.
- `:spec_check: ai` stays until a person checks the test.
- After a change to a requirement's contract (such as its kind), write the baseline again with `tools/behavior_coverage.py --update --write-baseline --reason "..."`.

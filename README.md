# kirimasim-tests

[日本語](README.ja.md)

[![Check](https://github.com/kurochan001/kirimasim-tests/actions/workflows/check.yml/badge.svg)](https://github.com/kurochan001/kirimasim-tests/actions/workflows/check.yml)
[![Nightly](https://github.com/kurochan001/kirimasim-tests/actions/workflows/nightly.yml/badge.svg)](https://github.com/kurochan001/kirimasim-tests/actions/workflows/nightly.yml)
[![License: Apache-2.0 WITH LLVM-exception](https://img.shields.io/badge/license-Apache--2.0%20WITH%20LLVM--exception-blue)](LICENSE)

A conformance test suite for the simulation semantics of IEEE 1800-2023
SystemVerilog.

For terminology and common questions, see the [glossary](docs/glossary.md)
and [FAQ](docs/faq.md) (Japanese). They explain test expectations, result
statuses, Nightly, coverage and the SVA/formal checks used by this suite.
This README describes the suite as it is now; records of earlier work and
measurements are in the [history](docs/history.md).

Each simulation test is a small, self-contained design with an expected result.
A legal design passes when its normalized standard output matches and any specified
exit-code and diagnostic checks succeed. An illegal design passes when it is
rejected with the required diagnostic (see [how a test is judged](#how-a-test-is-judged)).
The tests are written for the
[kirimasim](https://github.com/kurochan001/kirimasim) simulator. Runners for
Icarus Verilog, Verilator, kirimasim and
[Lyra](https://github.com/hankhsu1996/lyra) are included. An unreleased guest,
**Ghost**, is also taking part under an alias for now. The metadata
format is that of
[sv-tests](https://github.com/chipsalliance/sv-tests).

Most simulation expectations follow simulator-independent standard rules.
Tests of implementation-defined behavior state the assumed format explicitly;
the [FST waveform tests](docs/fst-tests-20261029.md) target kirimasim's planned
FST backend and are not requirements to use FST in every simulator.

What sets the suite apart:

- **Every test cites the standard.** `:lrm:` lists the clauses of IEEE
  1800-2023 that the test checks, and a comment at the top of the test
  describes, in our own words, what it checks.
- **Every expected output says where it comes from.** `:oracle:` records
  whether the expected output was checked against the standard, and which
  simulators produce it. Where possible it was cross-checked with Icarus
  Verilog 13.0, or with Verilator 5.052 where Icarus Verilog cannot run the
  test or does not follow the standard. Where neither follows the standard,
  the expected output follows the standard.
- **Tests print only what the standard fixes.** They do not depend on the
  order of events that the standard leaves open, on random values, on the
  default time unit or on the exact wording of a simulator's messages.

> **Status: early.** Every test has been checked against the standard by an
> AI model, and none by a person yet (`:spec_check: ai`).
> Reports of wrong expectations are welcome.

## Contents

<!-- suite-stats:begin -->
The suite has **9176 tests** in 38 chapters. 2739 of them are generated (`tests/gen/`, see "Generated tests"): 18 by `combination_aggregates`, 9 by `combination_events`, 13 by `combination_io`, 18 by `combination_monitors`, 16 by `combination_nba`, 36 by `interaction_array`, 36 by `interaction_case`, 34 by `interaction_case_inside`, 32 by `interaction_cast`, 100 by `interaction_compare`, 40 by `interaction_compound`, 72 by `interaction_concat`, 32 by `interaction_cond`, 72 by `interaction_divide`, 64 by `interaction_edge`, 51 by `interaction_expr`, 44 by `interaction_index`, 46 by `interaction_inside`, 70 by `interaction_logic`, 72 by `interaction_method`, 36 by `interaction_nba`, 36 by `interaction_port`, 60 by `interaction_query`, 48 by `interaction_queue`, 46 by `interaction_range`, 38 by `interaction_resize`, 36 by `interaction_select`, 56 by `interaction_shift`, 92 by `interaction_shortcircuit`, 36 by `interaction_stream`, 36 by `interaction_struct`, 36 by `interaction_task`, 496 by `keywords`, 325 by `scheduling`, 136 by `strength`, 49 by `wide_paths`, 144 by `width_sign`, 158 by `xz_propagation`.

| Expected result recorded with | Tests |
| --- | ---: |
| Icarus Verilog 13.0 (`iverilog@13.0` in `:oracle:`) | 5170 |
| Verilator 5.052, with no Icarus Verilog 13.0 oracle recorded | 1602 |
| The standard only, with no fixed-release simulator oracle recorded | 2404 |

1811 tests depend on x or z values (`:fourstate: yes`). 618 tests come with C code: 123 DPI tests (`:dpi_c:`) and 495 VPI tests (`:vpi_c:`). 1932 tests are illegal designs, which a simulator has to reject (`:should_fail_because:`). 35 tests check the exit code of the simulation (`:expected_exit:`). 23 tests have more than one source file (`:files:`), 4 define macros (`:defines:`), 7 name include directories (`:incdirs:`), 39 name the top-level module or configuration (`:top_module:`), and 13 pass arguments to the simulation (`:args:`). Every test has been checked against the standard by an AI model (`:spec_check: ai`); none has been checked by a person yet.

| Clause | Title | Tests | Icarus | Verilator | Standard only |
| ---: | --- | ---: | ---: | ---: | ---: |
| 3 | Design and verification building blocks | 88 | 66 | 12 | 10 |
| 4 | Scheduling semantics | 412 | 391 | 5 | 16 |
| 5 | Lexical conventions | 346 | 325 | 14 | 7 |
| 6 | Data types | 645 | 396 | 144 | 105 |
| 7 | Aggregate data types | 712 | 291 | 262 | 159 |
| 8 | Classes | 321 | 67 | 182 | 72 |
| 9 | Processes | 284 | 217 | 38 | 29 |
| 10 | Assignment statements | 254 | 169 | 45 | 40 |
| 11 | Operators and expressions | 1644 | 1262 | 132 | 250 |
| 12 | Procedural programming statements | 251 | 169 | 33 | 49 |
| 13 | Tasks and functions (subroutines) | 244 | 137 | 89 | 18 |
| 14 | Clocking blocks | 78 | 4 | 61 | 13 |
| 15 | Interprocess synchronization and communication | 59 | 2 | 36 | 21 |
| 16 | Assertions | 661 | 104 | 75 | 482 |
| 17 | Checkers | 81 |  | 22 | 59 |
| 18 | Constrained random value generation | 200 | 26 | 95 | 79 |
| 19 | Functional coverage | 157 | 2 | 29 | 126 |
| 20 | Utility system tasks and system functions | 330 | 239 | 26 | 65 |
| 21 | Input/output system tasks and system functions | 236 | 145 | 15 | 76 |
| 22 | Compiler directives | 358 | 335 | 13 | 10 |
| 23 | Modules and hierarchy | 292 | 177 | 45 | 70 |
| 24 | Programs | 43 | 21 | 5 | 17 |
| 25 | Interfaces | 119 | 31 | 57 | 31 |
| 26 | Packages | 83 | 53 | 16 | 14 |
| 27 | Generate constructs | 103 | 93 | 8 | 2 |
| 28 | Gate-level and switch-level modeling | 245 | 194 | 3 | 48 |
| 29 | User-defined primitives | 81 | 58 | 11 | 12 |
| 30 | Specify blocks | 60 | 35 | 1 | 24 |
| 31 | Timing checks | 66 | 17 | 1 | 48 |
| 32 | Backannotation using the standard delay format | 50 | 16 |  | 34 |
| 33 | Configuring the contents of a design | 43 | 12 | 9 | 22 |
| 34 | Protected envelopes | 4 | 2 | 2 |  |
| 35 | Direct programming interface | 131 | 5 | 84 | 42 |
| 36 | Programming language interface (PLI/VPI) overview | 89 | 34 | 19 | 36 |
| 37 | VPI object model diagrams | 227 | 18 | 1 | 208 |
| 38 | VPI routine definitions | 109 | 56 | 9 | 44 |
| 39 | Assertion API | 39 |  | 1 | 38 |
| 40 | Code coverage control and API | 31 | 1 | 2 | 28 |
<!-- suite-stats:end -->

The total includes 268 `:type: formal` tests. They are checked with SymbiYosys
through `:formal_case:` rather than by comparing simulator standard output;
see [running formal tests](#symbiyosys).

Additional SVA validation is recorded separately from these oracle counts:
the reference evaluator reproduces **45 test outputs**. The latest formal
rerun (2026-10-29) covers the full **267-case catalogue**: **267 BMC checks**, **44 unbounded
PDR proofs**, **267 covers** and five expected deliberate-error failures.
A separate parameter-boundary sweep has **111 cases**, all passing both BMC and PDR;
its suite bindings identify **127 sequence fragments in 91 directives across
28 tests**. The two formal sets overlap and are not added as distinct models.
These model counts are not added to the suite total, and these results do not
reclassify tests in the tables above. Both saved reports were regenerated on
2026-10-29 and pass their current-source and task-completeness checks; see the
guide for execution and validation commands.
See the [SVA reference and formal verification guide](docs/sva-reference-formal-verification.md)
and [boundary-sweep results](docs/sva-formal-expansion-20261026.md) for the
scope, evidence and reproduction commands.

The [catalog](docs/tests/README.md) lists every test, chapter by chapter,
with what it checks and the clauses it cites, and
[docs/tests/clauses.md](docs/tests/clauses.md) shows, chapter by chapter,
which clauses of the standard the tests cite. The
[depth report](docs/coverage-depth.md) counts the tests behind each clause
and lists the clauses that one test covers with a standard-only expected
output. Every in-scope leaf clause from 3 to 40 is directly cited by at
least two tests; the page
lists the others and why they are left out (the tags of `tools/clauses.txt`):
general text, clause 34, behavior left to the tool, and the content of VCD
files, except the parts that `test_vcd_dump_readback` reads back (21.7.2.1
to 21.7.2.3 and 21.7.5).

This is clause citation coverage, not proof that every requirement or
combination in IEEE 1800-2023 is exercised. The citation-depth scope is the
leaf clauses of chapters 3 to 40 selected by `tools/clauses.txt`, with the
current count and exclusions in the [depth report](docs/coverage-depth.md).
Annexes and explicitly excluded clauses are not silently included in a
claim about the entire standard. CI enforces the
two-test floor with `tools/coverage_depth.py --check --minimum-tests 2`;
parent-clause citations do not satisfy that floor for a child clause.

The [behavior summary](docs/behavior-coverage-summary.md) and
[detailed report](docs/behavior-coverage.md) measure explicitly reviewed
requirements and observable test outcomes. Their
[registry and workflow](coverage/README.md) inventory clauses 1–41 and annexes
A–Q, including parent introductions and previously excluded material. The
source review covers all 1,740 sections. Provisional percentages use every
registered requirement/condition/observation row, including interpretation
holds and unmapped rows. Confirmed whole-standard percentages use the approved
denominator after interpretations and overlapping requirement units have been
reconciled. The reports separate design coverage, execution
evidence, simulator outcomes and source-review progress. CI checks the registry
and generated summaries. Nightly records percentages, outstanding items,
simulator outcomes and denominator identities on the `results` branch.
Existing tests contribute only after their stimuli and expected outcomes have
been linked to requirements. The summary shows how many test files have at least
one reviewed link; unlinked tests may exercise additional requirements that are
not yet counted. Review existing tests before adding new ones for an unmapped row.
The [existing-test matching inventory](docs/test-requirement-matching.md) lists
chapter progress and links to the complete candidate worklist and content findings.
Collective witnesses require every member test to pass in one simulator snapshot;
partial successes from separate runs are not combined into a successful requirement.

[Feature-interaction verification](docs/interaction-verification.md) uses constrained
pairwise coverage, selected three-factor groups and mandatory boundary witnesses.
Its focused selection has 1,426 tests across twenty-nine models: scheduling, NBA capture,
arithmetic context, packed part-selects, conditional merging, shifts, cast pipelines
and task argument visibility, packed structures, case matching, port connections,
unpacked array copies, bit-vector queries, streaming permutations, comparisons,
array reduction pipelines, variable bit indices, queue updates with capacity limits,
division/remainder context, dynamic-array resizing, concatenated assignments,
packed logical/reduction pipelines, short-circuit side effects, event-edge expressions,
heap-backed file monitors across registration contexts, compound shifts with
selected targets, integral set membership across typed containers, value ranges
with typed bounds, and case-inside item selection. The case-inside model selects 34
tests from 8,704 assignments, covering 315 pairs, 154 triples and seven mandatory
witnesses. The range model selects 46 tests from 5,680 assignments, covering
303 pairs, 178 triples and six mandatory witnesses. Membership
selects 46 tests from 5,984 assignments, covering 305 pairs, 174 triples and five
mandatory witnesses. The compound-shift model selects 40 tests from 7,560 assignments,
covering 308 pairs, 90 triples and four mandatory witnesses. The file-monitor model
selects 18 tests from 36 assignments, covering all 40 pairs and three mandatory
witnesses. The short-circuit and event-edge models select 156 tests from 6,184
assignments that satisfy their constraints. The full suite retains all existing tests.
The [interaction report](docs/interaction-coverage.md) separates the selection plan
from fingerprint-qualified passes in each individual run; it does not change the
whole-standard requirement denominator.
The [design rationale and practical methodology](docs/interaction-verification-method.md)
(Japanese) explain model selection, implementation and evidence, how to add new
models, and how to apply the approach to other projects and LSI verification.

The [saved-run summary](docs/interaction-verification.md#保存実行の概要) records the
build revision, execution scope and pass/unsupported/fail counts. A complete
selection plan and a successful Check do not mean all crosses passed on every
simulator. These saved cross runs are separate from the full Nightly suite.

For continuation in Claude Code, see the [2026-10-30 handoff](docs/claude-code-handoff-20261030-cross-verification.md)
for the repository state, verified builds, remaining gaps and resumption commands.

[Issue #21's regression report](docs/p1-combination-regressions-20261030.md) and
[reviewed registry](coverage/combination-gaps.json) link existing witnesses to 74 new
tests: nine event, sixteen NBA, eighteen aggregate, thirteen I/O and eighteen
file-monitor cases. Only the eighteen file-monitor cases join a registered finite
interaction model; the other 56 exercise mechanism boundaries and are kept outside
the t-way coverage totals. The report records unresolved interpretations, separate
native-API work and results for each saved simulator run.
Use `python3 tools/combination_gaps.py --check` to check registry/report consistency,
and `python3 tools/combination_gaps.py --list-tests` to list all bound regression
tests, including reused tests. The consistency check does not require simulator passes.

The [method from the PDF to tests](docs/requirements-to-tests-method.md) describes,
step by step, how the requirements were extracted from the standard, how existing
tests are matched to them and new tests written, how an independent reviewer checks
both, and how the results are merged and measured, with the
[matching kit](tools/matching_kit/README.md) that the steps use.

The requirement denominator is **12,298 requirements**, after duplicate rows
were merged; the [denominator review](docs/denominator-review-20261028.md)
approved it. The reviewer was an AI, not an independent human.
Design coverage is **89.33% (10,986/12,298)**;
execution coverage from the saved `coverage/results/` evidence is
**59.60% (7,330/12,298)**, or 51.00% (6,272/12,298)
counting only Icarus Verilog, Verilator and SymbiYosys.
Clauses 1 to 40 alone are at 87.40% (8,272/9,465) design coverage.
See the [generated behavior summary](docs/behavior-coverage-summary.md) for the
measurement inputs and denominator.
The full existing-test semantic review is still incomplete.
The reports of each extraction, matching and test-addition step are linked
from the [history](docs/history.md); they record the observations,
standard-derived expectations, simulator differences, mutation checks and
execution evidence.

Tests are grouped in directories by the chapter (clause) of IEEE 1800-2023
that the first clause in their `:lrm:` belongs to. The columns Icarus,
Verilator and Standard only count the tests by where their expected output
was recorded, as in the first table. Clauses 1 and 2 set out no behavior to
test. Clause 34 (protected envelopes) has only four tests, of the envelope
syntax and of Verilator leaving a data block out of the source: neither
Icarus Verilog nor Verilator decrypts an envelope, and the
[protected-envelope boundary](docs/protected-envelope-boundary.md) gives the
audit-time reasons for the untested requirements; after the denominator review,
209 of the 214 clause-34 requirements remain unmapped. Which parts of a design
have coverage depends on the tool and its options, so the tests of clause 40
print only what holds for every result, such as the values the standard
allows and how the results of the coverage functions relate.

## Nightly results

<!-- workflow-verification:begin -->
**Latest Nightly:** [Nightly](https://github.com/kurochan001/kirimasim-tests/actions/runs/40972765631) completed all five simulator jobs and published the
[results snapshot](https://github.com/kurochan001/kirimasim-tests/blob/87b351e63412292ce137361c0ebd610b6522f8e1/README.md) for suite [`360ef70c`](https://github.com/kurochan001/kirimasim-tests/commit/360ef70c73218de1f44dd83c1cda24f60e242537) (8,779 tests) at
10:43 JST (01:43 UTC) on 2026-10-30; the [Check](https://github.com/kurochan001/kirimasim-tests/actions/runs/40965048026) of that commit also succeeded.
Lyra was built from [`8eff7abdc335`](https://github.com/hankhsu1996/lyra/commit/8eff7abdc335).
Matching tests / recorded results:

- Icarus Verilog: **5,502 / 8,511**.
- Verilator: **5,151 / 8,511**.
- kirimasim: **6,108 / 8,511**.
- Lyra: **6,537 / 8,511**.
- Ghost: **7,159 / 8,779**.

`differ`, `known difference` and `unsupported` results remain in the denominator.
The first four runners exclude the 268 formal tests; Ghost selects the full
catalogue. The SymbiYosys results are reported separately above.
<!-- workflow-verification:end -->

Every night, a [GitHub Actions workflow](.github/workflows/nightly.yml) runs
the applicable tests of `main` with the latest development version of each simulator:
the `master` branches of Icarus Verilog and Verilator and the `main` branches
of kirimasim and Lyra, resolved anew when each job starts. Builds are reused
only for the same resolved commit. Ghost joins from a private build. It adds the results to the
history on the
[`results`](https://github.com/kurochan001/kirimasim-tests/tree/results)
branch. The chart below is redrawn after each run; the
[report on that branch](https://github.com/kurochan001/kirimasim-tests/tree/results#readme)
also shows the share of tests that match, the results by chapter, each
simulator's results over time, and the tests whose result changed since the
previous night.

**Ghost** is an unidentified simulator appearing in the nightly tests before
its public debut. For now, only its results step out from behind the curtain:
its real name, source and build logs remain private. It runs the same tests
against the same standard-derived expectations as the other participants.

The scheduled start is **04:23 Japan Standard Time (JST, UTC+09:00)** every
day, or 19:23 UTC on the preceding date. Results are published after the
simulator jobs finish; GitHub scheduling delays and build times can move the
update hours later. The results report's `Latest run` and `Recent runs`
timestamps are in **UTC** and record when the report is generated, rather
than when the workflow starts. Add nine hours to read them in JST. Actual
start times and pending runs are shown in
[GitHub Actions](https://github.com/kurochan001/kirimasim-tests/actions/workflows/nightly.yml).
See the [Japanese guide to update times and report versions](docs/nightly-results.md).

The chart represents the suite commit and test count named in that report.
Adding tests to `main` updates the catalog and suite statistics; their nightly
results appear after a subsequent workflow runs that commit and publishes
its results. Check `suite commit` and the test count before comparing a chart
with the current suite.

![Tests that match their expected results](https://raw.githubusercontent.com/kurochan001/kirimasim-tests/results/charts/overview.svg?v=nightly-40972765631)

Each simulator has its own marker: a circle for Icarus Verilog, a square for
Verilator, a diamond for kirimasim, a downward triangle for Lyra and an orange
upward triangle for Ghost. The
markers
are drawn as outlines that fit inside each other, so simulators with the same
or close counts stay visible together, and the legend gives each one's count
in the latest run.

### By chapter

Each cell shows **matching tests / tests with recorded results**, followed
by the match rate for that chapter and simulator. Known differences and
unsupported tests, including those skipped before execution, remain in the
denominator. This table updates with the Nightly charts;
its date and simulator versions are shown at the top. Click it to view the
full-size image.

[![Matching tests by chapter](https://raw.githubusercontent.com/kurochan001/kirimasim-tests/results/charts/chapters.svg?v=nightly-40972765631)](https://raw.githubusercontent.com/kurochan001/kirimasim-tests/results/charts/chapters.svg?v=nightly-40972765631)

### Result statuses

Each test of a run gets one of these statuses:

| Status | Meaning |
| --- | --- |
| match | The output and any specified exit-code and runtime-diagnostic checks match, or an illegal design is rejected with the required diagnostic. |
| differ | A result does not match, a required diagnostic is missing, an illegal design is accepted, or a build or run fails without being classified otherwise. |
| known difference | An Icarus or Verilator test does not match and has no oracle token for that fixed release. Also used by kirimasim when a test has only another simulator's expectation and no common or kirimasim-specific expectation. |
| unsupported | The simulator reported a construct it does not support yet, or it cannot run this kind of test (kirimasim cannot load the C code of DPI and VPI tests yet, and Lyra that of VPI tests). |

For Icarus Verilog and Verilator, a Nightly differ is a test tagged for the
fixed release that does not match with the selected development version.
An untagged test that now matches is a candidate for review, including the
reason for any rejection; the result alone does not certify a fix or add an
oracle token.

The nightly results are reported, and with one exception a test that does not
match does not make the workflow fail: the kirimasim job fails when a test
that matched in the previous night's results differs now (a ratchet, see
"Workflows"). New tests and tests that kirimasim does not support yet do not
fail it. The expected outputs recorded with Icarus Verilog
13.0 and Verilator 5.052 are checked with those releases by a
[second workflow](.github/workflows/check.yml) whenever the tests or the
tools change (see "Workflows").

## Simulation speed

The suite checks what simulators compute, not how fast. For reference, the
kirimasim repository keeps a comparison of their speed on small designs of
its own ([bench/](https://github.com/kurochan001/kirimasim/tree/main/bench)).
Its latest run, on Linux under WSL2 (AMD Ryzen 9 7950X) on 2026-10-25, used
each simulator's newest development commit and eleven designs, and gave the
times in the first four columns: the median of five runs at the stated count
less the median of five runs with `+n=1`. The Ghost column is a later
measurement on the same machine (2026-10-28); because a full run takes much
longer, it is extrapolated as described in the notes.

| Design | `+n=` | kirimasim | Icarus Verilog 14.0 devel | Verilator 5.053 devel | Lyra (LLVM backend) | Ghost* |
| --- | :---: | :---: | :---: | :---: | :---: | :---: |
| `comb_chain` | 3,000,000 | 9.249 s | 9.796 s | 0.223 s | 2.878 s | 1,153 s* |
| `nba_shift` | 1,000,000 | 25.486 s | 26.585 s | 0.196 s | 5.900 s | 2,707 s* |
| `proc_wait` | 1,000,000 | 6.786 s | 5.688 s | 2.283 s | 6.164 s | 1,816 s* |
| `fork_join` | 4,000,000 | 4.837 s | 5.023 s | 1.190 s | 4.860 s | 909 s* |
| `wide_arith` | 1,500,000 | 4.944 s | 2.036 s | 0.086 s | 0.380 s | 131.4 s |
| `mem_rw` | 4,000,000 | 4.937 s | 3.645 s | 0.696 s | 2.705 s | 1,258 s* |
| `func_call` | 1,500,000 | 4.917 s | 7.511 s | 0.005 s | 0.395 s | 291 s* |
| `string_fmt` | 500,000 | 5.003 s | 8.080 s | 0.135 s | 0.279 s | 477 s* |
| `dyn_queue` | 4,000,000 | 4.112 s | 6.686 s | 0.083 s | 0.412 s | 400 s* |
| `gate_udp` | 400,000 | 5.378 s | 3.517 s | 0.046 s | not supported | 835 s* |
| `casez_struct` | 5,000,000 | 3.976 s | 4.117 s | 0.018 s | 0.466 s | 525 s* |

`*` Full count for `wide_arith`; otherwise extrapolated from reduced counts.

- kirimasim was at commit `b66834254c65`, Icarus Verilog at 14.0 devel
  `2b8d42dc088f`, Verilator at 5.053 devel `1838b6ed035c` and Lyra at
  `63922502ff0a`, built with `bazel build -c opt`. These benchmark measurements
  use the recorded commits; Nightly resolves the latest upstream commits for
  each run. The Lyra column uses its LLVM backend at `-O 0`. In these
  measurements, omitting `--backend` selected its C++ backend: on these
  designs it was 3.3 to 67 times slower than the LLVM backend, and its times
  are in kirimasim's benchmark details linked below.
  Every measured run gave the expected result; Lyra does not support gates or
  UDPs yet, so it built no program for `gate_udp`. The times do not include
  building a design (Verilator's C++, Lyra's program).
- Ghost was at commit `a2420294`, measured on
  2026-10-28 on the same WSL2/Ryzen 9 7950X machine. A full run takes 2 to
  45 minutes per run for Ghost, so most of its column is extrapolated: three
  runs at each of two reduced counts, the second twice the first
  (10,000/20,000, 2,000/4,000, or 1,000/2,000); the larger count took 1.97 to
  2.09 times as long as the smaller, and the slope was applied to the stated
  count.
  The full-count `wide_arith` run (131.4 s) matches its extrapolation within
  about 2% and its result line was checked. The other columns are the
  2026-10-25 medians.
- Ghost was 27 to 268 times slower than kirimasim on these designs (the
  smallest gap is `wide_arith`, the largest `proc_wait`) and 39 to 345 times
  slower than Icarus Verilog. These are the default runtime options of its
  release build; the column shows a large performance gap, not a functional
  difference.
- The first four designs exercise `always_comb` chains, nonblocking
  assignments, waiting processes and `fork`/`join`. The other seven use
  256-bit arithmetic (`wide_arith`), a 1024-word memory (`mem_rw`), task and
  recursive function calls (`func_call`), `$sformatf` (`string_fmt`), a queue
  and a dynamic array (`dyn_queue`), gates and a UDP (`gate_udp`), and `casez`
  into a packed struct (`casez_struct`).
- kirimasim was slower than Icarus Verilog on `proc_wait`, `wide_arith` (2.4
  times), `mem_rw` and `gate_udp`, clearly faster on `func_call`,
  `string_fmt` and `dyn_queue`, and within about 6% on the other four. On
  `dyn_queue` its peak memory grows with the count (547 MiB at 4,000,000).
  Comparisons with earlier runs are in the [history](docs/history.md).
- Small designs on one machine do not stand for the speed of real designs.
  Build times, startup, memory and the commands that reproduce the runs are
  in kirimasim's
  [benchmark details](https://github.com/kurochan001/kirimasim/blob/main/docs/BENCHMARKS.md#development-versions-on-linux-wsl2-2026-10-25).

## Layout

```text
tests/chNN/<name>.sv            a test, with its metadata header
tests/chNN/<name>.expected      its expected standard output
tests/chNN/<name>.c             C code of a DPI or VPI test
tests/chNN/<other>.sv, .svh     a source or include file that a test names in :files:
tests/chNN/<dir>/               an include directory that a test names in :incdirs:
tests/gen/chNN/<name>.sv        a generated test (do not edit; see "Generated tests")
generators/<generator>.py       a generator of tests and its reference model
generators/generate.py          writes tests/gen/, or checks it with --check
generators/oracles.txt          which releases produce each generated test's output
docs/simulator-differences.md   where Icarus Verilog 13.0 and Verilator 5.052 differ from the standard
docs/history.md                 records of earlier work, measurements and checks
docs/tests/                     the catalog: every test with what it checks, by chapter
docs/tests/clauses.md           which clauses of the standard the tests cite
docs/glossary.md               terminology and abbreviations used by this suite (Japanese)
docs/faq.md                    questions about expectations, results, coverage and verification (Japanese)
docs/coverage-depth.md          how many tests each clause has, and the priority gaps
docs/behavior-coverage-summary.md provisional and confirmed behavior coverage, by chapter and simulator
docs/interaction-verification.md feature-interaction models, focused execution and evidence rules
docs/interaction-coverage.md     planned and executed coverage of registered interaction models
docs/p1-combination-regressions-20261030.md reviewed boundaries and run evidence for Issue #21
coverage/combination-gaps.json   reviewed links from Issue #21 candidates to regression tests
docs/requirements-to-tests-method.md the method from the standard's PDF to requirements, tests and coverage
coverage/behavior-summary.json  the current behavior measurements and denominator identity
coverage/behavior-history.json  saved measurement history with denominator identities
tools/run_icarus.py             runs the suite with Icarus Verilog
tools/run_verilator.py          runs the suite with Verilator
tools/run_kirimasim.py          runs the suite with kirimasim
tools/run_lyra.py               runs the suite with Lyra
tools/run_ghost.py              runs the unreleased guest under its public alias
tools/normalize_output.py       normalizes a simulator's output before it is compared
tools/suite_results.py          the JSON form of a runner's results (--json)
tools/results_history.py        keeps the nightly history and draws its charts
tools/results_ratchet.py        lists the tests that matched in the previous run and differ now
tools/suite_stats.py            counts the tests and keeps both README language versions' tables
tools/suite_catalog.py          writes the catalog of the tests, docs/tests/
tools/coverage_depth.py         writes docs/coverage-depth.md, the depth report
tools/interaction_coverage.py   selects focused cross tests and checks execution coverage
tools/combination_gaps.py       lists Issue #21 regression tests and checks the registry/report
tools/clauses.txt               the clause numbers of the standard, for docs/tests/clauses.md
tools/lint_metadata.py          checks the metadata and the form of the tests
tools/lint_baseline.txt         the problems of existing tests that the check reports as known
tools/new_test.py               writes the skeleton of a new test
tools/matching_kit/             proposes, checks, judges and merges links between requirements and tests
.github/workflows/check.yml     checks the expected outputs with the releases
.github/workflows/nightly.yml   the nightly run
```

The `results` branch holds
`history.json` (one entry per run), `latest/<simulator>.json` (the result of
every test in each simulator's latest run), `charts/*.svg` and the report,
`README.md`. The charts and the report show only the simulators that `tools/`
has a runner for; the history keeps the runs of a simulator whose runner was
removed, but they are not drawn. The publish job also writes `behavior-coverage-summary.md`,
`behavior-coverage.md`, `behavior-summary.json`, `behavior-coverage.json`
and `behavior-history.json` for behavioral coverage of that run, plus
`interaction-coverage.md` and `interaction-coverage.json` for each simulator's
feature-interaction coverage. The
[Japanese guide](docs/nightly-results.md) explains how these differ from the
saved evidence on `main`.
The Nightly publish job normally updates this branch. Local results can also
be imported with their execution time, suite commit and `--source local`.

## Test format

A test is one SystemVerilog file (a few also have C code, other source files
or include files next to them, see `:dpi_c:`, `:vpi_c:`, `:files:` and
`:incdirs:`). It starts with a
metadata comment, followed by a comment that explains what the test checks,
and then the design. For example (an illustration, not a test of the suite):

```systemverilog
/*
:name: test_nonblocking_swap
:description: two nonblocking assignments that read each other's target exchange their values
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.4.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nonblocking_swap.expected
*/
// IEEE 1800-2023 §10.4.2: the right-hand sides of nonblocking assignments are
// evaluated before any of their targets is updated, so a <= b and b <= a
// exchange the values of a and b.

module test_nonblocking_swap;
  int a = 1, b = 2;

  initial begin
    a <= b;
    b <= a;
    #1 $display("a=%0d b=%0d", a, b);
  end
endmodule
```

with `test_nonblocking_swap.expected` holding the line `a=2 b=1`.

### Metadata

The metadata comment is compatible with sv-tests, which ignores the fields
it does not know.

| Field | Meaning |
| --- | --- |
| `:name:` | Test name, unique in the suite, the same as the file name |
| `:description:` | What the test checks |
| `:tags:` | Directory: `chNN`, the chapter of the first clause in `:lrm:` |
| `:type:` | `simulation` for simulation tests, `elaboration` for illegal designs that must be rejected, or `formal` for SymbiYosys model checks |
| `:formal_case:` | For `:type: formal`, the case in `tools/sva_reference/formal_cases.py` that `tools/run_sby.py` checks; no expected standard output is required |
| `:lrm:` | IEEE 1800-2023 clauses the test checks, for example `1800-2023 11.4.3` |
| `:oracle:` | Where the expected output comes from: `spec` (it was checked against the cited clauses of the standard; `:spec_check:` says by whom), `iverilog@13.0` (Icarus Verilog 13.0 produced it), `verilator@5.052` (Verilator 5.052 produced it) |
| `:spec_check:` | Who checked a `spec` expectation against the standard: `ai` (an AI model read the cited clauses; no person has checked this test yet) or `human` (a person checked it) |
| `:fourstate:` | Whether the result depends on x or z values (`yes` / `no`): the test has x or z literals, `$isunknown`, `casex`/`casez`, tri-state or strength constructs, or x or z in its expected output |
| `:nondeterministic:` | Whether the result can depend on an ordering the standard leaves open |
| `:expected_stdout:` | Expected standard output, or `@<file>` naming a file next to the test. It is the fallback for every simulator that has no field of its own |
| `:expected_stdout_<simulator>:` | Expected standard output for one simulator: `<simulator>` is `icarus`, `verilator`, `kirimasim` or `lyra`. It wins over `:expected_stdout:`, which may stay as the fallback for the other simulators. Add it only when the difference follows from the standard, such as a form the standard leaves to the tool, and say in the test comment why. Every referenced expectation file is part of the input fingerprint, so a change to any of them invalidates the stored execution evidence |
| `:dpi_c:` | `@<file>`: C code next to the test that implements its DPI imports and calls its exports (chapter 35) |
| `:vpi_c:` | `@<file>`: a VPI application next to the test, which registers its system tasks and callbacks from `vlog_startup_routines` (chapters 36 to 40) |
| `:should_fail_because:` | The design is illegal, for the reason given, and a simulator has to reject it. Such a test has `:type: elaboration`, no expected output (`:expected_stdout:` or a simulator-specific field), and an `:expected_stderr_regex:` that names the place of the error |
| `:expected_exit:` | The exit code that the simulation has to end with: `0`, `nonzero` (above 0) or a number. The standard fixes only that `$fatal` ends the run with an error code (20.10), so the tests use `nonzero` for it |
| `:expected_stderr_regex:` | A Python regular expression for the diagnostic text passed by the runner (see "How a test is judged" below). For an illegal design, an error line must match the reviewed source locations, such as `test_x\.sv:12:`, and any required diagnostic concepts. Appropriate alternative locations can be accepted; unsupported syntax is not evidence of the intended violation. For other tests, the run's messages must match the pattern. The full diagnostic text is not fixed |
| `:args:` | Arguments for the simulation, separated by spaces: plusargs such as `+count=3` |
| `:generator:` | `<generator>@<version>`: the test was written by `generators/<generator>.py` (see "Generated tests") |
| `:interaction_model:` | `<model>@<version>`: the registered interaction model for a generated cross test |
| `:interaction_values:` | `factor=value` assignments for that model; coverage also verifies the generator and execution fingerprints |
| `:files:` | Other files next to the test, separated by spaces: sources (`.sv`, `.v`), compiled before the test in the order written, and files that the design includes with `` `include ``, whose directory becomes an include directory. Their names do not start with `test_`. Whether the files form one compilation unit or several is left to the tool (3.12.1), and the tests do not depend on it |
| `:defines:` | Macros that the simulator defines before the first source file, separated by spaces: `NAME` or `NAME=VALUE` (the `-D` or `+define+` option of a tool). The standard leaves such options to the tool; the tests use them only to set macros that `` `ifdef `` and macro uses then see as if `` `define `` had set them (22.5.1) |
| `:incdirs:` | Include directories, relative to the directory of the test, separated by spaces, where `` `include "<file>" `` looks after the current working directory (22.4); a runner gives them to the simulator after the directories of the include files in `:files:` |
| `:top_module:` | The top-level module or configuration to elaborate. Without it, every module that nothing instantiates is a top-level module (23.3.1). A module selects it and its hierarchy; a configuration selects the design and binding rules it declares (33.4, 33.5.3) |

### How a test is judged

A test passes when the simulator's standard output, after removing empty
lines and the simulator's own banners (see `tools/normalize_output.py` and the
runners), is exactly the expected output. Spaces on nonempty lines are
preserved. The messages of the severity tasks
(`$info`, `$warning`, `$error` and `$fatal`), whose form the standard leaves to
the tool (20.10), are removed as well, since Icarus Verilog and Verilator
print them on standard output. The exit code and runtime messages are checked
only when the test asks for it with `:expected_exit:` or
`:expected_stderr_regex:`. For runtime checks, Icarus, Verilator and Lyra
match the raw standard output plus standard error before those messages are
removed; the kirimasim runner matches standard error only.
The new associative-array diagnostic tests therefore detect a missing warning,
or an unwanted warning, even when the normalized standard output matches.
They recognize warning severity markers without fixing the complete message
wording or a source location; see the
[test addition report](docs/associative-gap-tests-20261023.md).

An illegal design (`:should_fail_because:`) passes when the simulator rejects
it with an error at the place that `:expected_stderr_regex:` names, and fails
when the simulator accepts it or reports its error somewhere else. For
kirimasim, an error saying that the design uses a construct it does not
support yet makes the test unsupported, as for other tests.

A test whose output depends on the time unit or precision (a nonzero time
printed with `%t`, `$timeformat`, `$printtimescale`, fractional delays or
delays with time units) sets them with `` `timescale `` before its first design
element: the default time unit and precision are implementation-specific
(IEEE 1800-2023 3.14.2.3).

Tests of file input and output (IEEE 1800-2023 21.3 to 21.5) and of SDF
annotation (chapter 32), which write the SDF file they annotate, create files
named after the test in the current directory, and `$coverage_save`
(40.3.2.5) can store coverage data there. The runners run every test in a
temporary directory.

### Tests with C code

A test with `:dpi_c:` or `:vpi_c:` is the SystemVerilog file together with
its C file, which has the same name. The C file includes only the standard
headers `svdpi.h` (Annex I), `vpi_user.h` (Annex K) or `sv_vpi_user.h`
(Annex M) and those of the C library, and it compiles both as C and as C++
(Verilator compiles it as C++). Guard the opening and closing of
`extern "C"` with `#ifdef __cplusplus` so they are enabled only for C++.
Results are returned to SystemVerilog and printed with `$display` where
possible; C code that prints uses `vpi_printf`, or `printf` followed by
`fflush(stdout)`. The system tasks and functions that a VPI application
registers are named `$vt_...`, except in the test of overriding built-in ones.
sv-tests' runners do not know these fields and compile only
the SystemVerilog file, so such a test fails there.

### Where the expected outputs come from

Each expected output is decided from the cited clauses of the standard first.
The test is then run with Icarus Verilog 13.0:

1. If Icarus Verilog produces the expected output, `:oracle:` lists
   `iverilog@13.0` next to `spec`.
2. If it cannot compile the test, or does not follow the standard there, the
   test is run with Verilator 5.052 with two different random seeds for the
   initial values. If Verilator produces the expected output both times,
   `:oracle:` lists `verilator@5.052`. Verilator is a two-state simulator, so
   such tests have `:fourstate: no`. A test that was also run with the other
   release lists both when both produce its expected output.
3. If neither simulator follows the standard, `:oracle:` is `spec` alone, and
   the comment of the test says what the standard requires.

A test may keep a separate expectation for one simulator with
`:expected_stdout_icarus:`, `:expected_stdout_verilator:`,
`:expected_stdout_kirimasim:` or `:expected_stdout_lyra:`. That field wins
over `:expected_stdout:`, which stays the fallback for the other simulators.
Add it only when both outputs follow the standard and differ in a form the
standard leaves to the tool, such as the white space of `%p`; the test comment
says why. Every expectation file that any of these fields names is part of the
test's input fingerprint, so changing one invalidates the stored result even
when another simulator uses a different file.

For an illegal design (`:should_fail_because:`), the expected result is that
the design is rejected with an error at the place the test names, and
`iverilog@13.0` or `verilator@5.052` in `:oracle:` means that the release
rejects it there. A tool that rejects the design for another reason, such as
a construct it does not support, does not count. When such an error falls on
the line the test names, the runner cannot tell the difference: the comment of
the test says so, and `tools/run_icarus.py` shows the test as `NOW MATCHES`
without its `:oracle:` listing `iverilog@13.0`.

A disagreement between a simulator and the expected output is never resolved
by copying the simulator's output: the clause decides. The places found so
far where Icarus Verilog 13.0 or Verilator 5.052 differs from the standard are
listed in [docs/simulator-differences.md](docs/simulator-differences.md).

### Independent SVA checks and formal models

The [SVA reference evaluator](tools/sva_reference/README.md) independently
reproduces 45 selected test outputs from sampled input traces. An optional
Yosys/SymbiYosys suite additionally compares its semantics with separately
written RTL models under unconstrained inputs. The current 267-case catalogue
passed 267 BMC checks and 44 unbounded streaming PDR proofs on 2026-10-29. The
[boundary sweep](docs/sva-formal-expansion-20261026.md) passed BMC and PDR for
all 111 cases, with bindings to 127 sequence fragments in 28 suite tests.
These sets overlap; the bindings cover Boolean sequence calculations, not
whole assertions or simulator behavior. Both sets include reachability
witnesses and deliberate-error counterexamples. They do not change oracle
metadata or simulator execution coverage. The
[Japanese guide](docs/sva-reference-formal-verification.md)
explains the scope, results and reproduction commands; the
[technical report](tools/sva_reference/FORMAL_REVIEW.md) links the saved evidence.

### Generated tests

The tests under `tests/gen/` are written by the generators in `generators/`.
Each generator has a reference model of the clauses it tests, written from the
standard in Python without the help of any simulator, which gives the expected
outputs, and it writes many small variations of one kind of test:

| Generator | Chapter | What it varies |
| --- | ---: | --- |
| `scheduling` | 4 | How a variable is written (blocking, nonblocking, nonblocking with an intra-assignment delay, through a continuous assignment, by `force`), how it is read (in the same process, by another process waiting for it, `$strobe`, `$monitor`), where the write is (initial, always, task, function, fork branch, interface, generate block) and after which delay (none, `#0`, `#1`); only the combinations whose result the standard fixes |
| `interaction_nba` | 10 | Constrained pairwise combinations of width (1, 32, 33, 64, 65, 129), bit/logic, known/X/Z values, scalar/fixed unpacked array, array direction, initial/automatic task and immediate/delayed NBA; selected triples and boundary witnesses additionally check value/index capture before mutation and task return |
| `interaction_expr` | 11 | Operand widths/signs, destination width and add/subtract/multiply; 51 selected cases with four input pairs each check context extension, carries and truncation |
| `interaction_select` | 11 | Packed-vector width/direction, +:/-: indexed slices, span/position, bit/logic and known/X/Z data; 36 selected cases check reads, writes and unselected-bit preservation |
| `interaction_cond` | 11 | Branch signs, condition 0/1/X/Z, known/X/Z branch patterns, destination width and bit/logic; 32 selected cases check selection, bitwise merge and conversion |
| `interaction_shift` | 11 | Operator/count/sign, source and destination width, known/X/Z values and bit/logic; 56 selected cases check context extension, boundary counts, X/Z sign fill and unknown counts |
| `interaction_compound` | 11 | Width/state/sign, scalar/array-element/packed-slice targets, three compound shifts and signed 8/65-bit counts; 40 cases check once-only LHS evaluation, full containers, guard bits and widened reads |
| `interaction_inside` | 11 | Set/needle widths and signs, bit/logic set elements, explicit list/fixed/dynamic/queue storage, size and X/Z patterns; 46 cases check wildcard comparison before four-state OR, empty sets, reverse lists and result conversion |
| `interaction_range` | 11 | Bound/needle widths and signs, bit/logic bounds, closed/reversed/`$`-bounded/absolute- and relative-tolerance ranges, X/Z and ranges mixed with values; 46 cases check bound extension at the comparison type, empty ranges, swapped and truncated tolerance bounds, and X/Z in a range against X/Z in a value |
| `interaction_case_inside` | 12 | Case-expression/item widths and signs, bit/logic items, a first item that is a value, range, fixed array or list, X/Z, no qualifier or `unique0`, and a third item held in a variable or returned by a counting call; 34 cases check that an X comparison moves on to later items, item extension, one evaluation of the case expression and evaluation after a match |
| `interaction_cast` | 6 | Source sign/value, size/signing/typed casts, cast width, later addition and destination state; 32 selected cases distinguish intermediate conversion from final conversion |
| `interaction_task` | 13 | Width/state/value, input/output/inout/ref, scalar/array-element actuals and immediate/delayed return; 36 selected cases check copy-in, copy-out, immediate reference updates and neighbor preservation |
| `interaction_struct` | 7 | Member order, whole/member signs, width/state/value, member/whole writes and blocking/NBA updates; 36 selected cases check tag preservation, packed layout and independent sign extension |
| `interaction_case` | 12 | Selector/item widths and signs, case/casez/casex, X/Z and item patterns; 36 selected cases check exact/wildcard matching, duplicate-item priority and fallback branches |
| `interaction_port` | 23 | Source width/sign/value, input/output, sink width, named/positional binding, ANSI/non-ANSI declaration and sample state; 36 selected cases check values through hierarchy and final sampling conversion |
| `interaction_array` | 7 | Equivalent array element types, width/sign/state, source/destination index order, value and whole/slice copy; 36 cases observe declaration order, source independence and an untouched guard element |
| `interaction_query` | 20 | Width, state, argument shape, value/position and countbits controls; 60 cases check bit counts, one-hot/unknown predicates and duplicate controls |
| `interaction_stream` | 11 | Width, direction, slice size, tag, pack/unpack, target state and value; 36 cases check partial blocks and inverse unpack permutations |
| `interaction_compare` | 11 | Operand widths/signs, ten comparison operators and known/X/Z patterns; 100 cases check extension, asymmetric wildcards and one-bit results stored into wider logic/bit variables |
| `interaction_method` | 7 | Element width/state/sign, fixed/dynamic/queue storage, five reduction methods and four conversion forms; 72 cases check conversion before reduction, overflow and return-type extension |
| `interaction_index` | 11 | Width, range origin/direction, bit/logic, index sign/class and write value; 44 cases check variable reads/writes, invalid-access defaults and preservation of other bits |
| `interaction_queue` | 7 | Element width/state/sign, capacity, initial size, six operations and value; 48 cases check ordering, overflow warnings/discard, empty-pop defaults and independent copies |
| `interaction_divide` | 11 | Operand widths/signs, assignment width/state, division/remainder and zero/X/Z values; 72 cases check rounding toward zero, remainder signs and context before final conversion |
| `interaction_resize` | 7 | Element width/state/sign/value, old/new sizes and copy/self/reset construction; 38 cases check retained prefixes, type defaults, truncation and independent copies |
| `interaction_concat` | 11 | Total/split/RHS widths, source/member signs, mixed bit/logic fields, blocking/NBA and known/X/Z values; 72 cases check resizing before partition, per-field conversion, capture and member/concatenation extension |
| `interaction_logic` | 11 | Width, input/result state, expression shape, value and position; 70 cases each observe six packed reductions and logical negation, controlling bits, state conversion order and unsigned one-bit result extension |
| `interaction_shortcircuit` | 11 | Operand widths/states/truth classes and result state; 92 cases each check four binary logical operators, call counts, independent side effects, X/Z truth and conversion order |
| `interaction_edge` | 9 | Width/state, event expression, changed position, before/after values and blocking/NBA; 64 cases each observe both backgrounds and three event counts after setup has settled |
| `combination_events` | 6, 9, 15 | Nine mechanism-boundary cases for automatic event lifetimes, returned/selected event handles, computed event controls, `iff`, deferred triggers and named-fork cleanup |
| `combination_nba` | 10, 13 | Sixteen mechanism-boundary cases for delayed/event-controlled NBA through `ref static`, captured indices and values, string characters and array-slice copyback |
| `combination_aggregates` | 6, 11, 13 | Eighteen mechanism-boundary cases for unpacked-structure references and lifetimes, array input copies, nested packed selections and streaming into strings/nested targets |
| `combination_io` | 9, 10, 21 | Thirteen mechanism-boundary cases for `$fread` destinations and byte order, heap-backed implicit sensitivity and VCD contents read back inside SV |
| `combination_monitors` | 21 | Eighteen selected cases for `heap_file_monitor_context@1`: registration context × queue/dynamic array × MCD/FD; file readback checks Postponed values, selectors, size, replacement, `$monitoroff` independence and cancellation after close |
| `width_sign` | 11 | Operands and targets of 63 to 1000 bits, signed and unsigned, with the operators whose result size and sign 11.6 to 11.8 decide |
| `xz_propagation` | 11 | Operands with x and z bits for every operator of 11.4 that has rules for them |
| `strength` | 28 | Two drivers of a net with different strengths and values, on wire, tri, wand, triand, wor, trior, tri0 and tri1 nets and through bufif gates, shown with `%v` |
| `wide_paths` | 6, 7, 11, 13 | Values of 63, 64, 65, 127, 128, 129 and 200 bits, 2-state and 4-state with x and z above bit 64, signed and unsigned, on the paths a value takes: assignments to wider, narrower and 2-state targets, part-selects and slices of packed arrays and writes to them, concatenation, replication, shifts past the width, comparisons and `?:` with an x condition, `$bits`, and function results, task inputs, output and ref arguments; shown with `%h`, `%b` and `%0d` |
| `keywords` | 5, 22 | Illegal designs: each reserved keyword of IEEE 1800-2023 (Annex B) declared as a variable name under ``begin_keywords "1800-2023"``, and each keyword that a version of 22.14 adds declared so under ``begin_keywords`` of that version; a tool has to reject the declaration |

The docstring of each generator says which rules its model follows and which
combinations it leaves out because the standard does not decide them. A
change goes into the generator, not into the generated files:

```sh
python3 generators/generate.py            # write tests/gen/
python3 generators/generate.py --check    # check that tests/gen/ is up to date
```

Then update the tables of this README and the catalog as for any new test
(see "Contributing").

As for other tests, the expected outputs are then run with Icarus Verilog 13.0
and Verilator 5.052, and `generators/record_oracles.py` records which of them
produce them in `generators/oracles.txt`, from which `:oracle:` is written. A
test that neither release produces follows the model alone (`:oracle: spec`);
where the model and a simulator differ, the clause decides, as above.

## Running the suite

The simulation runners need Python 3.10 or later, and have these options in common:

| Option | Meaning |
| --- | --- |
| `TEST ...` | Run only these test files. Icarus, Verilator, kirimasim and Lyra exclude `:type: formal`, even when explicitly named. Verilator defaults to its oracle-tagged tests; `--all` selects all non-formal tests. Icarus, kirimasim and Lyra default to all non-formal tests; Ghost selects all test files |
| `-j N`, `--jobs N` | Run N tests at once (default: 1) |
| `--json FILE` | Also write the result of every test to FILE (see `tools/suite_results.py`) |

Each simulation runner gives the simulator the metadata that sets up a run, in the
form the simulator takes:

| Field | Icarus Verilog | Verilator | kirimasim | Lyra |
| --- | --- | --- | --- | --- |
| `:files:` (sources) | before the test | before the test | before the test | before the test |
| `:files:` (include files) and `:incdirs:` | `-I` | `-I` | `+incdir+` | `-I` |
| `:defines:` | `-D` | `-D` | `+define+` | `-D` |
| `:top_module:` | `-s` | `--top-module` | `--top=` | `--top` |
| `:args:` | to `vvp` | to the model | after the test | after `--` |

A runner prints one line for each test that does not match (`FAIL`, or
`KNOWN` for a known difference, `UNSUPPORTED` for kirimasim and Lyra), and
`tools/run_icarus.py` one for each known difference that matches (`NOW
MATCHES`), then a summary line, and exits with 1 if a test it counts does not
match.

The Icarus and Verilator terminal summaries count only tests tagged with that
fixed release's oracle. Their JSON output also records an untagged test as
`pass` when it matches. Nightly reads all recorded results, so its denominator
and matching count can differ from the terminal summary. Oracle metadata is
not changed automatically.

### Icarus Verilog

```sh
python3 tools/run_icarus.py -j 8
python3 tools/run_icarus.py --iverilog-bin /path/to/icarus-13.0/bin
```

Each test is compiled with `iverilog -g2012 -gspecify -ginterconnect`: without
`-gspecify` Icarus Verilog ignores specify blocks, and `-ginterconnect` lets it
annotate SDF interconnect delays. For a test with `:vpi_c:`, the C file is
built with `iverilog-vpi` and loaded with `vvp -m`, that is, only when the
design runs. Icarus Verilog takes the return types of user-defined system
functions from a `.sft` file when it compiles, and the runner gives it none:
it takes a call in procedural code as a 32-bit result, and it does not
compile a call in a continuous assignment. Icarus Verilog has no DPI, so the
tests with `:dpi_c:` are known differences. The expected outputs were
checked with Icarus Verilog 13.0; another version can differ, so name the
directory of 13.0 with `--iverilog-bin` when the `iverilog` on `PATH` is
another one.

Where Icarus Verilog 13.0 does not follow the standard, the expected output
follows the standard and `:oracle:` does not list `iverilog@13.0`.
`tools/run_icarus.py` reports such a test as a known difference and does not
count it as a failure (or as `NOW MATCHES` if it matches). The same applies to
tests that Icarus Verilog 13.0 cannot compile; their `:oracle:` lists
`verilator@5.052` when that release was confirmed, or remains `spec` alone
when neither fixed-release oracle is recorded.

### Verilator

```sh
python3 tools/run_verilator.py -j 8
python3 tools/run_verilator.py --seed 7
python3 tools/run_verilator.py --all -j 8
```

By default this runs only the tests whose `:oracle:` lists `verilator@5.052`;
`--all` runs every non-formal test, and counts those not recorded with Verilator as
known differences when they do not match. Each test is built with
`verilator --binary --timing --coverage-user` and run with random initial
values (`--seed` chooses them); without `--coverage-user`, Verilator does not
run cover statements. Verilator's own lines are removed before comparing: its
banners and its run-time warnings (`%Warning-...`), which it prints on
standard output, for example when the constraints of a `randomize()` call
cannot be met. The model runs with `+verilator+error+limit+1000000`: by
default Verilator stops at the first `$error`, which the standard has report
an error and go on (20.10). Tests whose results depend on random values print only what
the standard fixes, such as whether every constraint held. The C file of a
test with `:dpi_c:` is built into the model; for `:vpi_c:` the model is also
built with `--vpi` and `--public-flat-rw`, but Verilator does not support
user-defined system tasks, which the VPI tests use. Verilator solves the
constraints of `randomize()` with an SMT solver, `z3` by default, which has to
be on `PATH`; without it the tests of randomization do not match.

Most of the time of a test goes into compiling the runtime library of
Verilator, which is the same for every test. With `OBJCACHE=ccache` in the
environment, the makefile of each model compiles through
[ccache](https://ccache.dev), so the library is compiled once, and a later run
also reuses the C++ of the tests that did not change; both workflows do this.

### kirimasim

```sh
python3 tools/run_kirimasim.py --kirimasim /path/to/kirimasim -j 8
```

Each test runs as `kirimasim <test>.sv` in a temporary directory. kirimasim
prints only what the design prints on standard output, so nothing of its own
needs to be removed. A test that uses a construct kirimasim does not support
yet (exit code 2 with an `error: unsupported:` message) is reported as
unsupported, and so are the tests with C code, which kirimasim cannot load
yet. No kirimasim oracle is recorded; non-formal tests are selected.
When a test has only another simulator's expectation and neither a common
nor a kirimasim-specific expectation, it is `known` and excluded from the
terminal match-rate denominator. Its status is still recorded in JSON.

### Lyra

```sh
python3 tools/run_lyra.py --lyra /path/to/lyra --commit SHA -j 8
```

[Lyra](https://github.com/hankhsu1996/lyra) compiles a design through slang
and LLVM into a program and runs it. It builds only on x86-64 Linux and has
no releases, so `--commit` names the commit that was built, which the results
record as the version. Each test runs in a temporary directory as `lyra run`;
without `:top_module:`, slang takes every module that nothing instantiates,
the C file of `:dpi_c:` is given with `--dpi-link`, and the arguments of
`:args:` follow `--`. Lyra keeps what it builds for reuse in a cache
directory that the tests share (`--cache-dir`, or a temporary directory),
and each test is built with `-j 1`. Lyra prints its diagnostics on standard
error and says of every construct it does not carry out yet that it "is not
yet supported", which makes the test unsupported. The lines that Lyra prints
on standard output itself, which open with the place they are about (such as
the count of a cover statement), are removed before comparing, and the lines
that the test prints are kept. An illegal design
is checked with `lyra check`. Lyra has no VPI, so the tests with `:vpi_c:`
are unsupported. No expected output was recorded with Lyra, so every test
counts.

### Ghost

```sh
python3 tools/run_ghost.py --simulator /path/to/private/simulator \
  --profile /path/to/private-profile.json --include /path/to/include -j 8 \
  --json out/ghost.json
```

Ghost is a temporary alias for an unreleased simulator. The private runtime
profile supplies `arguments`, `environment`, `include_subdirs`, `trailer`,
`banner_pattern` and `severity_pattern`; it stays outside this repository.
The runner uses the common `:expected_stdout:`, checks exit codes and required
diagnostics, and compiles DPI/VPI C sources into shared libraries. Every test
counts; there are no known-difference exclusions. Tool banners and severity
messages are removed as the profile specifies, while test output is kept.
Only generic failure reasons and a hash identifying the executable enter
public results. The executable's version and private diagnostics stay private.
If the executable or profile changes during a run, its results are discarded.

The nightly job reads `GHOST_REPOSITORY`, `GHOST_DEPLOY_KEY`,
`GHOST_PARSER_REPOSITORY`, `GHOST_PARSER_REF`, `GHOST_PARSER_PATH`,
`GHOST_BUILD_TARGET`, `GHOST_EXECUTABLE` (relative to the private checkout)
and `GHOST_PROFILE` from repository secrets. It runs only in this repository;
forks can still run the public simulators. To end the guest appearance, remove
the job and its entry in `publish.needs`, and remove the runner. Its history
will remain saved, following the same rules as other retired participants.

### SymbiYosys

The suite includes 268 tests with `:type: formal`. They name a `:formal_case:`
and are run by `tools/run_sby.py`, which compares the reference evaluator with
an independent RTL model. The Icarus, Verilator, kirimasim and Lyra runners
exclude them. Ghost's current runner still selects all test files; its
results for formal test files are not SymbiYosys proof evidence.

```sh
python3 tools/run_sby.py --sby "$SBY_BIN" --json /tmp/sby.json
```

This runner needs Python 3.10 or later and a working SymbiYosys/Yosys/solver
environment. It runs cases sequentially. `--no-prove` omits PDR proofs;
BMC, registered cover jobs and deliberate-error checks still run.
`--timeout N` is passed as the timeout for each formal job. See the
[runner selection record](docs/runner-selection-20261028.md) and
[formal verification guide](docs/sva-reference-formal-verification.md).

### Other simulators

A runner for another simulator needs to do four things for each test: run it
in an empty temporary directory, with the sources, macros, include
directories, top-level module and arguments of its metadata (see the table
above), remove the lines the simulator prints on
standard output by itself, pass the rest through `tools/normalize_output.py`,
and compare the result with the expected output. The runners above are short
and can serve as templates; with `--json` and `tools/suite_results.py`, the
results of a new runner can be added to the nightly history as well.

### Recording and drawing results locally

The nightly history can be built from local runs too. For example, to keep a
history in `my-results/`:

```sh
python3 tools/run_icarus.py -j 8 --json out/icarus.json
python3 tools/run_kirimasim.py --kirimasim /path/to/kirimasim -j 8 --json out/kirimasim.json
python3 tools/results_history.py update --history my-results --source local out/*.json
```

`update` compares each simulator with its previous run in the same history,
adds the run to `my-results/history.json`, and draws `my-results/charts/*.svg`
and `my-results/README.md`. A simulator that `tools/` no longer has a runner
for stays in the history but is not drawn. `python3 tools/results_history.py render
--history my-results` draws them again from the history alone.
The defaults use the current time and suite `HEAD`. When importing earlier
results, pass `--time`, `--suite-commit` and `--run-url` with the actual
execution time, suite commit and result location.

## Workflows

`.github/workflows/check.yml` runs on every push to `main` and every pull
request that changes `tests/`, `tools/`, `generators/`, `docs/tests/`, this
README or its Japanese version, `coverage/`, `docs/behavior-coverage.md`,
`docs/coverage-depth.md`, `docs/interaction-*.md`
or the workflow itself, and can be started by hand from the Actions
tab (`workflow_dispatch`). Its jobs fail when the
suite has a problem:

- **icarus** builds Icarus Verilog 13.0 from its `v13_0` tag (kept in the
  Actions cache) and runs every non-formal test. Every test whose `:oracle:` lists
  `iverilog@13.0` must match; the others are known differences.
- **verilator** builds Verilator 5.052 from its `v5.052` tag (kept in the
  cache), installs `z3` for `randomize()` and ccache, whose cache it keeps for
  the next run, and runs the tests whose `:oracle:` lists `verilator@5.052`,
  which must all match.
- **readme** checks that the tables of both README language versions are up
  to date
  (`tools/suite_stats.py --check`), that the generated tests are what the
  generators write (`generators/generate.py --check`), that the catalog
  in `docs/tests/` is up to date (`tools/suite_catalog.py --check`), that
  `docs/coverage-depth.md` is up to date and every in-scope leaf clause has
  two direct tests (`tools/coverage_depth.py --check --minimum-tests 2`),
  and that no test breaks a rule of the metadata or of "Contributing" that
  `tools/lint_metadata.py` checks, other than the known problems of existing
  tests in `tools/lint_baseline.txt`. It also runs the tooling unit tests,
  validates behavioral coverage and its baseline with source review required,
  checks the freshness of the requirement-matching inventory, and validates the
  interaction models, selected witnesses and saved execution report
  (`tools/interaction_coverage.py --check`).

`.github/workflows/nightly.yml` is scheduled at 19:23 UTC every day
(04:23 JST the following day), and can be
started by hand as well. For a fresh run of the latest suite and settings,
[dispatch it on `main`](docs/nightly-results.md#最新のmainで手動実行する).
GitHub can start a scheduled run hours late when it is busy. Runs do not overlap: one that starts while another is running waits
for it, and a newer one replaces a run that is still waiting. Its results are
only reported, except for the ratchet of the kirimasim job. It has six jobs:

- **icarus** builds the latest `master` of Icarus Verilog (kept in the cache
  by its commit) and runs every non-formal test.
- **verilator** builds the latest `master` of Verilator (kept in the cache
  by its commit), installs `z3` and ccache, whose cache it keeps for the next
  night, and runs every non-formal test with `--all`. Each process of the run gets at
  most 6 GB of address space (`ulimit -v`): a design that makes Verilator
  recurse without end would otherwise take all the memory of the runner,
  which stops the job.
- **kirimasim** builds the latest `main` of kirimasim with its `release`
  preset and runs every non-formal test. Then it compares the results with
  `latest/kirimasim.json` of the `results` branch, the previous night's, with
  `tools/results_ratchet.py`, and fails when a test that matched there differs
  now; tests that are new or unsupported, and a night without previous
  results, do not count. The results are uploaded before, so the night's
  entry has them either way.
- **lyra** resolves the latest `main` commit at the start of every job and
  sets `LYRA_COMMIT` to that SHA. The same SHA selects the source checkout,
  build cache and commit recorded with the results. An uncached commit is
  built with Bazel, including LLVM; earlier hosted builds took 42 to 89
  minutes. The executable and its runfiles are copied out of Bazel's tree
  without its location-dependent manifest. It runs every non-formal test;
  earlier test runs took 35 to 70 minutes.
- **ghost** privately builds the unreleased guest and runs every test. Its
  checkout locations and runtime profile come from secrets. Only the public
  alias, build hash and test verdicts are uploaded; source and build output
  stay on the runner.
- **publish** collects the `--json` results of the jobs that finished, adds
  them to the history on the `results` branch with
  `tools/results_history.py update`, measures behavioral coverage using only
  that run's result files, and pushes the branch. The summary of the run
  lists each simulator's counts, tests whose result changed and behavioral
  coverage. Publishing waits for all five simulator jobs to finish, including
  failed jobs; a successful publish is what updates the chart and report.
  Only a run of `main` publishes: a run started by hand on another branch
  runs the simulators and uploads their results without publishing them.

A simulator whose nightly job fails before it has results is left out of
that night's entry, and its next run is compared with its last results.

## Contributing

Changes that modify, remove, or relax an existing expected result must say
why and cite the IEEE 1800-2023 clause. Do not copy text, figures, or example
code from the standard; describe behavior in your own words and cite clause
numbers.

`tools/new_test.py` writes the skeleton of a new test, with its metadata
and an empty `.expected` file, and TODO where the test still needs its
description, its comment, its design and its expected output:

```sh
python3 tools/new_test.py ch16 test_sequence_and --lrm "16.9.5"
python3 tools/new_test.py ch9 test_illegal_always_comb_delay --lrm "9.2.2.2" --illegal
```

A new test should:

- be named `test_<what it checks>.sv` and placed in `tests/chNN/`, where NN is
  the chapter of the first clause in its `:lrm:`;
- start with the metadata comment and a comment of lines of at most 80
  columns that explains what the cited clauses require and how the test
  observes it; lines of code are at most 100 columns. No comment line starts
  with the word "Verilator": Verilator reads a comment that starts with it as
  a directive and stops with BADVLTPRAGMA;
- print only what the standard fixes, and end with `$finish` or by running
  out of events. An event control on a signal and on a value computed from
  it, such as the output of a continuous assignment, can wake once or twice
  in the same time step, so print such values at fixed times instead;
- be a legal design apart from the one error of an illegal design. In
  particular, an input port in an ANSI port list needs the keyword `var`
  (`input var int d`) when a net cannot have its type, such as a two-state
  type or a virtual interface: an input port without a port kind is a net,
  and a net has a four-state integral type or an array or structure of them
  (23.2.2.3, 6.7.1);
- if it is an illegal design, give the reason in `:should_fail_because:` and
  the file and line of the error in `:expected_stderr_regex:` (each line where
  a tool can rightly report it, when there are several), and contain no other
  error. When a release rejects the design on that line only because it does
  not support a construct there, the comment of the test says so;
- have its expected output decided from the standard and, where possible,
  confirmed with Icarus Verilog 13.0 or Verilator 5.052 as described in
  "Where the expected outputs come from"; where either release does not follow
  the standard, the place goes into
  [docs/simulator-differences.md](docs/simulator-differences.md) and the
  comment of the test says so.

For each newly reviewed behavior, record its requirement and observation in
[`coverage/behaviors.json`](coverage/behaviors.json), including boundary and illegal
cases. Keep unreviewed requirements visible rather than inferring behavioral
coverage from the clause citation.

After adding tests, update the tables of both README language versions, the
catalog of the tests and the page of the clauses they cite, and check the
metadata, as the check workflow does:

```sh
python3 tools/suite_stats.py --update
python3 tools/suite_catalog.py --update
python3 tools/coverage_depth.py --update
python3 tools/behavior_coverage.py --update
python3 tools/requirement_matching.py --update
python3 tools/interaction_coverage.py --update
python3 tools/lint_metadata.py
```

`tools/lint_metadata.py` reports what a script can check of the rules above:
the fields and their values, `:lrm:` and the directory, x or z literals in a
test with `:fourstate: no`, the expected output, the fields of an illegal
design, the files that the metadata names, the line lengths, comment lines
that start with the word Verilator, a `` `timescale `` when a time is printed,
and TODO left from the skeleton. Its docstring lists the rules.

Most of the material here was produced with AI assistance (Claude Code
and OpenCode); people are responsible for checking the expected results
against the standard.

## License

Apache License 2.0 with LLVM Exceptions (`Apache-2.0 WITH LLVM-exception`).
See [LICENSE](LICENSE).

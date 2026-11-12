<a id="handoff-2026-11-12"></a>

# Handoff 2026-11-12

[English](claude-code-handoff-20261112.en.md) / [日本語](claude-code-handoff-20261112.md)

This hands over the repository review of 2026-11-11 and 12 and its fixes.
The figures are those of `f5623e32`. See the [generated summary](behavior-coverage-summary.en.md) for the latest values and the [history](history.md) for each step.
The state before that is in the [handoff of 2026-11-10](claude-code-handoff-20261110.en.md).

<a id="state"></a>

## Current state

- Design coverage is 90.21% (11,094/12,298).
- Execution coverage from Icarus Verilog, Verilator and SymbiYosys is 50.21% (6,175/12,298). This is the figure given first.
- With the results of Ghost and of kirimasim added, it is 77.59% (9,542/12,298).
- The suite has 12,272 tests.

| Commit | What it does |
| --- | --- |
| `5bbaf860` | The metadata field `:compilation_unit: single`: a test that needs use model a) of 3.12.1 says so |
| `b8e36f20` | Corrections of documents and of small faults in the report tools |
| `0ef0f28e` | Nightly: the output of the private fetches stays out of the public log; the Lyra tests stop after 345 minutes; a job fails when its runner ends without writing results |
| `e09ccc7c`, `b7ad6729` | No two tests are equal: two hand-written tests and one generated test are removed, and two cross models are version 2 |
| `b9aa09f9`, `5afb1a83` | The Icarus Verilog, Verilator, kirimasim and Lyra runners fail a run that ended by a signal, and builds have a time limit. Absolute paths in saved results are replaced, and every test ran again on the pinned releases |
| `0ed54dcc`, `77b4b5d7`, `a7af0635` | Pinned-release tokens that illegal tests had not earned are removed from `:oracle:` ([record](oracle-token-review-20261112.en.md)). Every remaining token was checked by running a legal counterpart |
| `5fcd8b7b` | Observations of Icarus Verilog that are not differences of a release are in the simulator differences |
| `f3cd2702` | The lint baseline compares counts, the results history stays in time order, and the tools read and write UTF-8 |
| `26e1d791` | 148 tests that no simulator passes were reviewed, and 17 were fixed ([record](pass-nowhere-review-20261112.en.md)) |
| `68f5ecc7`, `f5623e32` | Eight requirements whose errors are reported while the design runs are normal requirements now and mapped to tests; ten tests are new |

In the Nightly of 2026-11-12 (`68f5ecc7`) every job succeeded. The fetches of Ghost worked in their new form, and Lyra ended within its limit.

<a id="open-decisions"></a>

## Waiting for a decision

- How to treat 17 contested tests and two more that need a decision (`ch4/test_illegal_final_deferred_action_schedules_event`, `ch18/test_illegal_randsequence_negative_weight`). Both readings and a proposal for each are in the [review record](pass-nowhere-review-20261112.en.md).
- Two rows of the ledger (`SV2023-20.14.2-EXTRACT-POSITIVE-PARAMETERS`, `SV2023-7.8.4-EXTRACT-XZ-KEY-INVALID`) have the error kind, but the standard requires no error there.
- Logs of earlier Nightly runs still show the commit of a private fetch. Whether to delete them is for the owner.

<a id="deferred"></a>

## Decided, to do later

To do together when Ghost's results are next saved again, because a changed test makes Ghost's saved results stale:

- citations for about 13 existing tests that do not cite their clause;
- fixes of `ch18/test_inline_local_scope_binding`, `ch22/test_ifdef_directive_names_not_defined` and `ch33/test_duplicate_cell_last_definition_wins`;
- the four chapter 23 tests of uwire ports (inout becomes output);
- rewording of passages that match the standard at length, the comments of 15 imported tests, and seven pairs of equal `:name:` values.

To do together when a runner next changes, because a change makes every saved result of that simulator stale:

- for two illegal tests with "error" in their names, a warning line can count as an error;
- eight tests where Icarus Verilog 13.0 ends abnormally after its error are not detected;
- a timeout of Lyra leaves a grandchild process;
- saved formal results stay fresh when the code that judges them changes.

Also:

- The run-time error requirements of the VPI (38.34 and others) are not mapped yet.
- VCD tests are on hold.
- When the Lyra tests grow by about 3,000, split the job.

<a id="rules"></a>

## Working rules

These add to the rules of the [handoff of 2026-11-10](claude-code-handoff-20261110.en.md#rules).

- Others push to `main` too. Fetch `origin/main` before every push; if it moved, rebase and check again.
- A change to `tools/suite_results.py`, `tools/normalize_output.py` or `tools/run_<simulator>.py` makes the saved results of that simulator invalid. Ghost's results cannot be saved again locally.
- An illegal test lists a pinned release only when the release accepts the legal use and rejects only the illegal form at the marked line. Run a legal counterpart to check.
- New tests and corrected expectations have an author and a separate, independent reviewer.
- On macOS, giving `OBJCACHE=ccache` straight to the Verilator runner can produce a false build failure.

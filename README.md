# kirimasim-tests

[![Check](https://github.com/kurochan001/kirimasim-tests/actions/workflows/check.yml/badge.svg)](https://github.com/kurochan001/kirimasim-tests/actions/workflows/check.yml)
[![Nightly](https://github.com/kurochan001/kirimasim-tests/actions/workflows/nightly.yml/badge.svg)](https://github.com/kurochan001/kirimasim-tests/actions/workflows/nightly.yml)

A conformance test suite for the simulation semantics of IEEE 1800-2023
SystemVerilog.

Each test is a small, self-contained design that prints what it observes. A
simulator passes a test when its standard output, normalized, is exactly the
test's expected output. The tests are written for the
[kirimasim](https://github.com/kurochan001/kirimasim) simulator, but nothing in
them is specific to it: runners for Icarus Verilog, Verilator, kirimasim and
sukimasim (kirimasim's predecessor, which is not public) are included, and the
metadata format is that of
[sv-tests](https://github.com/chipsalliance/sv-tests).

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
  default time unit or on the format of a simulator's messages.

> **Status: early.** Every test has been checked against the standard by an
> AI model (Claude Code), and none by a person yet (`:spec_check: ai`).
> Reports of wrong expectations are welcome.

## Contents

<!-- suite-stats:begin -->
The suite has **3350 tests** in 37 chapters. 763 of them are generated (`tests/gen/`, see "Generated tests"): 325 by `scheduling`, 136 by `strength`, 144 by `width_sign`, 158 by `xz_propagation`.

| Expected output recorded with | Tests |
| --- | ---: |
| Icarus Verilog 13.0 (`iverilog@13.0` in `:oracle:`) | 2345 |
| Verilator 5.052, where Icarus Verilog 13.0 differs from the standard or cannot compile the test | 662 |
| The standard only, where neither simulator follows it | 343 |

523 tests depend on x or z values (`:fourstate: yes`). 126 tests come with C code: 21 DPI tests (`:dpi_c:`) and 105 VPI tests (`:vpi_c:`). 86 tests are illegal designs, which a simulator has to reject (`:should_fail_because:`). 5 tests check the exit code of the simulation (`:expected_exit:`). 6 tests have more than one source file (`:files:`), and 5 pass arguments to the simulation (`:args:`). Every test has been checked against the standard by an AI model (`:spec_check: ai`); none has been checked by a person yet.

| Clause | Title | Tests | Icarus | Verilator | Standard only |
| ---: | --- | ---: | ---: | ---: | ---: |
| 3 | Design and verification building blocks | 11 | 5 | 4 | 2 |
| 4 | Scheduling semantics | 351 | 346 | 2 | 3 |
| 5 | Lexical conventions | 33 | 29 | 3 | 1 |
| 6 | Data types | 292 | 211 | 62 | 19 |
| 7 | Aggregate data types | 285 | 117 | 160 | 8 |
| 8 | Classes | 138 | 31 | 93 | 14 |
| 9 | Processes | 110 | 93 | 8 | 9 |
| 10 | Assignment statements | 105 | 85 | 16 | 4 |
| 11 | Operators and expressions | 689 | 627 | 57 | 5 |
| 12 | Procedural programming statements | 119 | 102 | 16 | 1 |
| 13 | Tasks and functions (subroutines) | 108 | 60 | 46 | 2 |
| 14 | Clocking blocks | 29 |  | 24 | 5 |
| 15 | Interprocess synchronization and communication | 26 | 1 | 21 | 4 |
| 16 | Assertions | 73 | 16 | 16 | 41 |
| 17 | Checkers | 11 |  |  | 11 |
| 18 | Constrained random value generation | 36 | 1 | 30 | 5 |
| 19 | Functional coverage | 26 |  | 8 | 18 |
| 20 | Utility system tasks and system functions | 187 | 166 | 11 | 10 |
| 21 | Input/output system tasks and system functions | 83 | 74 | 5 | 4 |
| 22 | Compiler directives | 30 | 29 | 1 |  |
| 23 | Modules and hierarchy | 69 | 53 | 8 | 8 |
| 24 | Programs | 10 | 4 |  | 6 |
| 25 | Interfaces | 49 | 11 | 34 | 4 |
| 26 | Packages | 29 | 20 | 8 | 1 |
| 27 | Generate constructs | 68 | 63 | 4 | 1 |
| 28 | Gate-level and switch-level modeling | 176 | 139 | 3 | 34 |
| 29 | User-defined primitives | 16 | 10 | 4 | 2 |
| 30 | Specify blocks | 20 | 16 |  | 4 |
| 31 | Timing checks | 14 | 1 |  | 13 |
| 32 | Backannotation using the standard delay format | 14 | 8 |  | 6 |
| 33 | Configuring the contents of a design | 14 | 2 | 2 | 10 |
| 34 | Protected envelopes | — | | | |
| 35 | Direct programming interface | 21 |  | 15 | 6 |
| 36 | Programming language interface (PLI/VPI) overview | 13 | 8 |  | 5 |
| 37 | VPI object model diagrams | 49 | 3 |  | 46 |
| 38 | VPI routine definitions | 21 | 13 |  | 8 |
| 39 | Assertion API | 12 |  |  | 12 |
| 40 | Code coverage control and API | 13 | 1 | 1 | 11 |
<!-- suite-stats:end -->

The [catalog](docs/tests/README.md) lists every test, chapter by chapter,
with what it checks and the clauses it cites, and
[docs/tests/clauses.md](docs/tests/clauses.md) shows, chapter by chapter,
which clauses of the standard the tests cite. Every clause from 3 to 40 that
sets out behavior a test can observe is cited by at least one test; the page
lists the others and why they are left out (the tags of `tools/clauses.txt`):
general text, clause 34, behavior left to the tool, and the content of VCD
files.

Tests are grouped in directories by the chapter (clause) of IEEE 1800-2023
that the first clause in their `:lrm:` belongs to. The columns Icarus,
Verilator and Standard only count the tests by where their expected output
was recorded, as in the first table. Clauses 1 and 2 set out no behavior to
test. Clause 34 (protected envelopes) has no tests: what a protected envelope
contains depends on the encryption each tool defines. Which parts of a design
have coverage depends on the tool and its options, so the tests of clause 40
print only what holds for every result, such as the values the standard
allows and how the results of the coverage functions relate.

## Nightly results

Every night, a [GitHub Actions workflow](.github/workflows/nightly.yml) runs
every test of `main` with the latest development version of each simulator:
the `master` branches of Icarus Verilog and Verilator and the `main` branches
of kirimasim and sukimasim, built that night. It adds the results to the
history on the
[`results`](https://github.com/kurochan001/kirimasim-tests/tree/results)
branch. The chart below is redrawn after each run; the
[report on that branch](https://github.com/kurochan001/kirimasim-tests/tree/results#readme)
also shows the share of tests that match, the results by chapter, each
simulator's results over time, and the tests whose result changed since the
previous night.

![Tests that match their expected output](https://raw.githubusercontent.com/kurochan001/kirimasim-tests/results/charts/overview.svg)

Each simulator has its own marker: a circle for Icarus Verilog, a square for
Verilator, a diamond for kirimasim and a triangle for sukimasim. The markers
are drawn as outlines that fit inside each other, so simulators with the same
or close counts stay visible together, and the legend gives each one's count
in the latest run.

sukimasim is not public. Its repository is private, and the nightly workflow
builds it from there with a read-only key; only its results are published.
Running the suite with sukimasim yourself needs access to that repository.

Each test of a run gets one of these statuses:

| Status | Meaning |
| --- | --- |
| match | The normalized standard output is exactly the expected output. |
| differ | It is not, or the test could not be built or run. |
| known difference | It is not, and the expected output was not recorded with this simulator, because its release that the suite was checked with (Icarus Verilog 13.0 or Verilator 5.052) does not produce it (see `:oracle:`). |
| unsupported | The simulator reported a construct it does not support yet, or it cannot run this kind of test (kirimasim cannot load the C code of DPI and VPI tests yet). |

So for Icarus Verilog and Verilator, a test that differs is one that the
release matches but the development version does not, and a known
difference that matches is one that the development version has fixed.

The nightly results are only reported: a test that does not match does not
make the workflow fail. The expected outputs recorded with Icarus Verilog
13.0 and Verilator 5.052 are checked with those releases by a
[second workflow](.github/workflows/check.yml) whenever the tests or the
tools change (see "Workflows").

## Layout

```text
tests/chNN/<name>.sv            a test, with its metadata header
tests/chNN/<name>.expected      its expected standard output
tests/chNN/<name>.c             C code of a DPI or VPI test
tests/chNN/<other>.sv, .svh     a source or include file that a test names in :files:
tests/gen/chNN/<name>.sv        a generated test (do not edit; see "Generated tests")
generators/<generator>.py       a generator of tests and its reference model
generators/generate.py          writes tests/gen/, or checks it with --check
generators/oracles.txt          which releases produce each generated test's output
docs/simulator-differences.md   where Icarus Verilog 13.0 and Verilator 5.052 differ from the standard
docs/tests/                     the catalog: every test with what it checks, by chapter
docs/tests/clauses.md           which clauses of the standard the tests cite
tools/run_icarus.py             runs the suite with Icarus Verilog
tools/run_verilator.py          runs the suite with Verilator
tools/run_kirimasim.py          runs the suite with kirimasim
tools/run_sukimasim.py          runs the suite with sukimasim
tools/normalize_output.py       normalizes a simulator's output before it is compared
tools/suite_results.py          the JSON form of a runner's results (--json)
tools/results_history.py        keeps the nightly history and draws its charts
tools/suite_stats.py            counts the tests and keeps the tables of this README
tools/suite_catalog.py          writes the catalog of the tests, docs/tests/
tools/clauses.txt               the clause numbers of the standard, for docs/tests/clauses.md
.github/workflows/check.yml     checks the expected outputs with the releases
.github/workflows/nightly.yml   the nightly run
```

The `results` branch, written only by the nightly workflow, holds
`history.json` (one entry per run), `latest/<simulator>.json` (the result of
every test in the latest run), `charts/*.svg` and the report, `README.md`.

## Test format

A test is one SystemVerilog file (a few also have C code or other source
files next to them, see `:dpi_c:`, `:vpi_c:` and `:files:`). It starts with a
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
| `:type:` | `simulation` for tests that are run |
| `:lrm:` | IEEE 1800-2023 clauses the test checks, for example `1800-2023 11.4.3` |
| `:oracle:` | Where the expected output comes from: `spec` (it was checked against the cited clauses of the standard; `:spec_check:` says by whom), `iverilog@13.0` (Icarus Verilog 13.0 produced it), `verilator@5.052` (Verilator 5.052 produced it) |
| `:spec_check:` | Who checked a `spec` expectation against the standard: `ai` (an AI model, Claude Code, read the cited clauses; no person has checked this test yet) or `human` (a person checked it) |
| `:fourstate:` | Whether the result depends on x or z values (`yes` / `no`): the test has x or z literals, `$isunknown`, `casex`/`casez`, tri-state or strength constructs, or x or z in its expected output |
| `:nondeterministic:` | Whether the result can depend on an ordering the standard leaves open |
| `:expected_stdout:` | Expected standard output, or `@<file>` naming a file next to the test |
| `:dpi_c:` | `@<file>`: C code next to the test that implements its DPI imports and calls its exports (chapter 35) |
| `:vpi_c:` | `@<file>`: a VPI application next to the test, which registers its system tasks and callbacks from `vlog_startup_routines` (chapters 36 to 40) |
| `:should_fail_because:` | The design is illegal, for the reason given, and a simulator has to reject it. Such a test has `:type: elaboration`, no `:expected_stdout:`, and an `:expected_stderr_regex:` that names the place of the error |
| `:expected_exit:` | The exit code that the simulation has to end with: `0`, `nonzero` (above 0) or a number. The standard fixes only that `$fatal` ends the run with an error code (20.10), so the tests use `nonzero` for it |
| `:expected_stderr_regex:` | A Python regular expression for the simulator's messages (standard error, and the lines on standard output that the simulator prints itself). For an illegal design, a line of the messages that says "error" has to match it; the tests give the file and line of the error, such as `test_x\.sv:12:`, which every simulator prints. For other tests, the messages of the run have to match it. The wording of a message is never compared |
| `:args:` | Arguments for the simulation, separated by spaces: plusargs such as `+count=3` |
| `:generator:` | `<generator>@<version>`: the test was written by `generators/<generator>.py` (see "Generated tests") |
| `:files:` | Other files next to the test, separated by spaces: sources (`.sv`, `.v`), compiled before the test in the order written, and files that the design includes with `` `include ``, whose directory becomes an include directory. Their names do not start with `test_`. Whether the files form one compilation unit or several is left to the tool (3.12.1), and the tests do not depend on it |

### How a test is judged

A test passes when the simulator's standard output, after removing empty
lines and the simulator's own banners (see `tools/normalize_output.py` and the
runners), is exactly the expected output. The messages of the severity tasks
(`$info`, `$warning`, `$error` and `$fatal`), whose form the standard leaves to
the tool (20.10), are removed as well, since Icarus Verilog and Verilator
print them on standard output. The exit code and standard error are checked
only when the test asks for it with `:expected_exit:` or
`:expected_stderr_regex:`.

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
(Verilator compiles it as C++), with its definitions inside `extern "C"`.
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
   such tests have `:fourstate: no`.
3. If neither simulator follows the standard, `:oracle:` is `spec` alone, and
   the comment of the test says what the standard requires.

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

### Generated tests

The tests under `tests/gen/` are written by the generators in `generators/`.
Each generator has a reference model of the clauses it tests, written from the
standard in Python without the help of any simulator, which gives the expected
outputs, and it writes many small variations of one kind of test:

| Generator | Chapter | What it varies |
| --- | ---: | --- |
| `scheduling` | 4 | How a variable is written (blocking, nonblocking, nonblocking with an intra-assignment delay, through a continuous assignment, by `force`), how it is read (in the same process, by another process waiting for it, `$strobe`, `$monitor`), where the write is (initial, always, task, function, fork branch, interface, generate block) and after which delay (none, `#0`, `#1`); only the combinations whose result the standard fixes |
| `width_sign` | 11 | Operands and targets of 63 to 1000 bits, signed and unsigned, with the operators whose result size and sign 11.6 to 11.8 decide |
| `xz_propagation` | 11 | Operands with x and z bits for every operator of 11.4 that has rules for them |
| `strength` | 28 | Two drivers of a net with different strengths and values, on wire, tri, wand, triand, wor, trior, tri0 and tri1 nets and through bufif gates, shown with `%v` |

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

Every runner needs Python 3.10 or later, and has these options in common:

| Option | Meaning |
| --- | --- |
| `TEST ...` | Run only these test files (default: every `tests/**/test_*.sv`) |
| `-j N`, `--jobs N` | Run N tests at once (default: 1) |
| `--json FILE` | Also write the result of every test to FILE (see `tools/suite_results.py`) |

A runner prints one line for each test that does not match (`FAIL`, or
`KNOWN` for a known difference, `UNSUPPORTED` for kirimasim), then a summary
line, and exits with 1 if a test it counts does not match.

### Icarus Verilog

```sh
python3 tools/run_icarus.py -j 8
python3 tools/run_icarus.py --iverilog-bin /path/to/icarus-13.0/bin
```

Each test is compiled with `iverilog -g2012 -gspecify -ginterconnect`: without
`-gspecify` Icarus Verilog ignores specify blocks, and `-ginterconnect` lets it
annotate SDF interconnect delays. For a test with `:vpi_c:`, the C file is
built with `iverilog-vpi` and loaded with `vvp -m`. Icarus Verilog has no DPI,
so the tests with `:dpi_c:` are known differences. The expected outputs were
checked with Icarus Verilog 13.0; another version can differ, so name the
directory of 13.0 with `--iverilog-bin` when the `iverilog` on `PATH` is
another one.

Where Icarus Verilog 13.0 does not follow the standard, the expected output
follows the standard and `:oracle:` does not list `iverilog@13.0`.
`tools/run_icarus.py` reports such a test as a known difference and does not
count it as a failure (or as `NOW MATCHES` if it matches). The same applies to
tests that Icarus Verilog 13.0 cannot compile; their `:oracle:` lists
`verilator@5.052` instead.

### Verilator

```sh
python3 tools/run_verilator.py -j 8
python3 tools/run_verilator.py --seed 7
python3 tools/run_verilator.py --all -j 8
```

By default this runs only the tests whose `:oracle:` lists `verilator@5.052`;
`--all` runs every test, and counts those not recorded with Verilator as
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

### kirimasim

```sh
python3 tools/run_kirimasim.py --kirimasim /path/to/kirimasim -j 8
```

Each test runs as `kirimasim <test>.sv` in a temporary directory. kirimasim
prints only what the design prints on standard output, so nothing of its own
needs to be removed. A test that uses a construct kirimasim does not support
yet (exit code 2 with an `error: unsupported:` message) is reported as
unsupported, and so are the tests with C code, which kirimasim cannot load
yet. No expected output was recorded with kirimasim, so every test counts.

### sukimasim

```sh
python3 tools/run_sukimasim.py --sukimasim /path/to/sukimasim
python3 tools/run_sukimasim.py --strip-diagnostics -j 8
```

sukimasim is the simulator that came before kirimasim. It is not public: its
repository is private, so this runner is of use only with access to it (its
results are in the nightly report). No expected output was recorded with it,
so every test counts, and none is a known difference or unsupported. Each
test runs in a temporary directory with `--quiet --quiet-stats --quiet-exit`
and `SUKIMASIM_FINISH_STRICT_MODE=1`. The lines that sukimasim prints on
standard output itself are removed before comparing: everything from
`[sukimasim] Simulation completed` on, the lines that its `--diff` option
ignores, and its `$finish` message. `TEST PASSED` is removed only as part of
what follows `[sukimasim] Simulation completed`, because many tests print it
themselves. With `--strip-diagnostics` the messages that sukimasim prints while
it runs, such as `[TIMING] ...`, are removed as well. The C file of a test with
`:dpi_c:` or `:vpi_c:` is built into a shared library against sukimasim's
include directory (`--include`; by default the `include` directory beside the
one that holds the executable) and loaded with `--lib`. sukimasim has no
`sv_vpi_user.h`, so the runner provides one that includes `vpi_user.h`.

### Other simulators

A runner for another simulator needs to do four things for each test: run it
in an empty temporary directory, remove the lines the simulator prints on
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
python3 tools/results_history.py update --history my-results out/*.json
```

`update` compares each simulator with its previous run in the same history,
adds the run to `my-results/history.json`, and draws `my-results/charts/*.svg`
and `my-results/README.md`. `python3 tools/results_history.py render
--history my-results` draws them again from the history alone.

## Workflows

`.github/workflows/check.yml` runs on every push to `main` and every pull
request that changes `tests/`, `tools/`, `generators/`, `docs/tests/`, this
README or the workflow itself, and can be started by hand from the Actions
tab (`workflow_dispatch`). Its jobs fail when the
suite has a problem:

- **icarus** builds Icarus Verilog 13.0 from its `v13_0` tag (kept in the
  Actions cache) and runs every test. Every test whose `:oracle:` lists
  `iverilog@13.0` must match; the others are known differences.
- **verilator** builds Verilator 5.052 from its `v5.052` tag (kept in the
  cache), installs `z3` for `randomize()`, and runs the tests whose
  `:oracle:` lists `verilator@5.052`, which must all match.
- **readme** checks that the tables of this README are up to date
  (`tools/suite_stats.py --check`), that the generated tests are what the
  generators write (`generators/generate.py --check`), and that the catalog
  in `docs/tests/` is up to date (`tools/suite_catalog.py --check`).

`.github/workflows/nightly.yml` runs at 19:23 UTC every day, and can be
started by hand as well. Its results are only reported. It has five jobs:

- **icarus** builds the latest `master` of Icarus Verilog (kept in the cache
  by its commit) and runs every test.
- **verilator** builds the latest `master` of Verilator (kept in the cache
  by its commit), installs `z3`, and runs every test with `--all`.
- **kirimasim** builds the latest `main` of kirimasim with its `release`
  preset and runs every test.
- **sukimasim** checks out the latest `main` of sukimasim from its private
  repository with a read-only deploy key (the `SUKIMASIM_DEPLOY_KEY` secret),
  and the `sukimasim-improvements` branch of its parser,
  [slang-sukimasim](https://github.com/kurochan001/slang-sukimasim), builds
  it and runs every test. Only the results leave the job: the output of the
  build is not shown in the log, and nothing of sukimasim is cached. The job
  runs only in this repository.
- **publish** collects the `--json` results of the jobs that finished, adds
  them to the history on the `results` branch with
  `tools/results_history.py update`, and pushes the branch. The summary of
  the run lists each simulator's counts and the tests whose result changed.

A simulator whose nightly job fails before it has results is left out of
that night's entry, and its next run is compared with its last results.

## Contributing

Changes that modify, remove, or relax an existing expected result must say
why and cite the IEEE 1800-2023 clause. Do not copy text, figures, or example
code from the standard; describe behavior in your own words and cite clause
numbers.

A new test should:

- be named `test_<what it checks>.sv` and placed in `tests/chNN/`, where NN is
  the chapter of the first clause in its `:lrm:`;
- start with the metadata comment and a comment of lines of at most 80
  columns that explains what the cited clauses require and how the test
  observes it; lines of code are at most 100 columns. No comment line starts
  with the word "Verilator": Verilator reads a comment that starts with it as
  a directive and stops with BADVLTPRAGMA;
- print only what the standard fixes, and end with `$finish` or by running
  out of events;
- if it is an illegal design, give the reason in `:should_fail_because:` and
  the file and line of the error in `:expected_stderr_regex:`, and contain
  no other error;
- have its expected output decided from the standard and, where possible,
  confirmed with Icarus Verilog 13.0 or Verilator 5.052 as described in
  "Where the expected outputs come from"; where either release does not follow
  the standard, the place goes into
  [docs/simulator-differences.md](docs/simulator-differences.md) and the
  comment of the test says so.

After adding tests, update the tables of this README, the catalog of the
tests and the page of the clauses they cite, which the check workflow
requires:

```sh
python3 tools/suite_stats.py --update
python3 tools/suite_catalog.py --update
```

Most of the material here was produced with AI assistance (Claude Code);
people are responsible for checking the expected results against the
standard.

## License

Apache License 2.0. See [LICENSE](LICENSE).

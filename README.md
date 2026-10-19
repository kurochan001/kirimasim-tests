# kirimasim-tests

[![Nightly](https://github.com/kurochan001/kirimasim-tests/actions/workflows/nightly.yml/badge.svg)](https://github.com/kurochan001/kirimasim-tests/actions/workflows/nightly.yml)

A conformance test suite for the simulation semantics of IEEE 1800-2023
SystemVerilog.

Each test is a small, self-contained design that prints what it observes. A
simulator passes a test when its standard output, normalized, is exactly the
test's expected output. The tests are written for the
[kirimasim](https://github.com/kurochan001/kirimasim) simulator, but nothing in
them is specific to it: runners for Icarus Verilog, Verilator, kirimasim and
sukimasim are included, and the metadata format is that of
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
The suite has **2176 tests** in 37 chapters.

| Expected output recorded with | Tests |
| --- | ---: |
| Icarus Verilog 13.0 (`iverilog@13.0` in `:oracle:`) | 1453 |
| Verilator 5.052, where Icarus Verilog 13.0 differs from the standard or cannot compile the test | 569 |
| The standard only, where neither simulator follows it | 154 |

190 tests depend on x or z values (`:fourstate: yes`). 70 tests come with C code: 11 DPI tests (`:dpi_c:`) and 59 VPI tests (`:vpi_c:`). Every test has been checked against the standard by an AI model (`:spec_check: ai`); none has been checked by a person yet.

| Clause | Title | Tests | Icarus | Verilator | Standard only |
| ---: | --- | ---: | ---: | ---: | ---: |
| 3 | Design and verification building blocks | 6 | 2 | 3 | 1 |
| 4 | Scheduling semantics | 19 | 16 | 1 | 2 |
| 5 | Lexical conventions | 25 | 24 | 1 |  |
| 6 | Data types | 241 | 181 | 55 | 5 |
| 7 | Aggregate data types | 271 | 113 | 155 | 3 |
| 8 | Classes | 117 | 28 | 85 | 4 |
| 9 | Processes | 84 | 77 | 5 | 2 |
| 10 | Assignment statements | 93 | 81 | 10 | 2 |
| 11 | Operators and expressions | 375 | 318 | 56 | 1 |
| 12 | Procedural programming statements | 119 | 102 | 16 | 1 |
| 13 | Tasks and functions (subroutines) | 94 | 52 | 42 |  |
| 14 | Clocking blocks | 13 |  | 11 | 2 |
| 15 | Interprocess synchronization and communication | 22 | 1 | 19 | 2 |
| 16 | Assertions | 54 | 16 | 11 | 27 |
| 17 | Checkers | 6 |  |  | 6 |
| 18 | Constrained random value generation | 21 |  | 19 | 2 |
| 19 | Functional coverage | 20 |  | 8 | 12 |
| 20 | Utility system tasks and system functions | 168 | 157 | 8 | 3 |
| 21 | Input/output system tasks and system functions | 72 | 66 | 3 | 3 |
| 22 | Compiler directives | 22 | 21 | 1 |  |
| 23 | Modules and hierarchy | 53 | 46 | 5 | 2 |
| 24 | Programs | 7 | 3 |  | 4 |
| 25 | Interfaces | 42 | 11 | 30 | 1 |
| 26 | Packages | 24 | 17 | 7 |  |
| 27 | Generate constructs | 64 | 62 | 2 |  |
| 28 | Gate-level and switch-level modeling | 28 | 24 | 3 | 1 |
| 29 | User-defined primitives | 8 | 5 | 3 |  |
| 30 | Specify blocks | 8 | 7 |  | 1 |
| 31 | Timing checks | 7 |  |  | 7 |
| 32 | Backannotation using the standard delay format | 13 | 7 |  | 6 |
| 33 | Configuring the contents of a design | 7 |  | 1 | 6 |
| 34 | Protected envelopes | — | | | |
| 35 | Direct programming interface | 11 |  | 8 | 3 |
| 36 | Programming language interface (PLI/VPI) overview | 7 | 4 |  | 3 |
| 37 | VPI object model diagrams | 30 | 2 |  | 28 |
| 38 | VPI routine definitions | 13 | 9 |  | 4 |
| 39 | Assertion API | 6 |  |  | 6 |
| 40 | Code coverage control and API | 6 | 1 | 1 | 4 |
<!-- suite-stats:end -->

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
every test of `main` with Icarus Verilog 13.0, Verilator 5.052 and the latest
`main` of kirimasim, and adds the results to the history on the
[`results`](https://github.com/kurochan001/kirimasim-tests/tree/results)
branch. The chart below is redrawn after each run; the
[report on that branch](https://github.com/kurochan001/kirimasim-tests/tree/results#readme)
also shows the share of tests that match, the results by chapter, each
simulator's results over time, and the tests whose result changed since the
previous night.

![Tests that match their expected output](https://raw.githubusercontent.com/kurochan001/kirimasim-tests/results/charts/overview.svg)

Each test of a run gets one of these statuses:

| Status | Meaning |
| --- | --- |
| match | The normalized standard output is exactly the expected output. |
| differ | It is not, or the test could not be built or run. |
| known difference | It is not, and the expected output was not recorded with this simulator: Icarus Verilog and Verilator are known not to produce it (see `:oracle:`). |
| unsupported | The simulator reported a construct it does not support yet, or it cannot run this kind of test (kirimasim cannot load the C code of DPI and VPI tests yet). |

The expected outputs recorded with Icarus Verilog 13.0 and Verilator 5.052
must all match them: a test that does not makes the job of that simulator
fail, because it points to a problem in the suite. The results of kirimasim
are only reported.

## Layout

```text
tests/chNN/<name>.sv            a test, with its metadata header
tests/chNN/<name>.expected      its expected standard output
tests/chNN/<name>.c             C code of a DPI or VPI test
tools/run_icarus.py             runs the suite with Icarus Verilog
tools/run_verilator.py          runs the suite with Verilator
tools/run_kirimasim.py          runs the suite with kirimasim
tools/run_sukimasim.py          runs the suite with sukimasim
tools/normalize_output.py       normalizes a simulator's output before it is compared
tools/suite_results.py          the JSON form of a runner's results (--json)
tools/results_history.py        keeps the nightly history and draws its charts
tools/suite_stats.py            counts the tests and keeps the tables of this README
.github/workflows/nightly.yml   the nightly run
```

The `results` branch, written only by the nightly workflow, holds
`history.json` (one entry per run), `latest/<simulator>.json` (the result of
every test in the latest run), `charts/*.svg` and the report, `README.md`.

## Test format

A test is one SystemVerilog file. It starts with a metadata comment, followed
by a comment that explains what the test checks, and then the design. For
example (an illustration, not a test of the suite):

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

### How a test is judged

A test passes when the simulator's standard output, after removing empty
lines and the simulator's own banners (see `tools/normalize_output.py` and the
runners), is exactly the expected output. Only standard output is compared:
not the exit code, and not standard error.

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

A disagreement between a simulator and the expected output is never resolved
by copying the simulator's output: the clause decides.

## Running the suite

Every runner needs Python 3.10 or later, and has these options in common:

| Option | Meaning |
| --- | --- |
| `TEST ...` | Run only these test files (default: every `tests/**/*.sv`) |
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
so the tests with `:dpi_c:` are known differences.

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
`verilator --binary --timing` and run with random initial values (`--seed`
chooses them). Verilator's own lines are removed before comparing: its
banners and its run-time warnings (`%Warning-...`), which it prints on
standard output, for example when the constraints of a `randomize()` call
cannot be met. Tests whose results depend on random values print only what
the standard fixes, such as whether every constraint held. The C file of a
test with `:dpi_c:` is built into the model; for `:vpi_c:` the model is also
built with `--vpi` and `--public-flat-rw`, but Verilator does not support
user-defined system tasks, which the VPI tests use.

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

sukimasim is the simulator that came before kirimasim. No expected output was
recorded with it, so every test counts and none is a known difference. Each
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

## Nightly workflow

`.github/workflows/nightly.yml` runs at 19:23 UTC every day, and can be
started by hand from the Actions tab (`workflow_dispatch`). It has four jobs:

- **icarus** builds Icarus Verilog 13.0 from its `v13_0` tag (kept in the
  Actions cache) and runs every test.
- **verilator** builds Verilator 5.052 from its `v5.052` tag (kept in the
  cache) and runs every test with `--all`.
- **kirimasim** builds the latest `main` of kirimasim with its `release`
  preset and runs every test.
- **publish** collects the `--json` results of the jobs that finished, adds
  them to the history on the `results` branch with
  `tools/results_history.py update`, and pushes the branch. The summary of
  the run lists each simulator's counts and the tests whose result changed.
  It also warns when the tables of this README are out of date.

A simulator whose job fails before it has results is left out of that
night's entry, and its next run is compared with its last results.

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
  observes it; lines of code are at most 100 columns;
- print only what the standard fixes, and end with `$finish` or by running
  out of events;
- have its expected output decided from the standard and, where possible,
  confirmed with Icarus Verilog 13.0 or Verilator 5.052 as described in
  "Where the expected outputs come from".

After adding tests, update the tables of this README:

```sh
python3 tools/suite_stats.py --update
```

Most of the material here was produced with AI assistance (Claude Code);
people are responsible for checking the expected results against the
standard.

## License

Apache License 2.0. See [LICENSE](LICENSE).

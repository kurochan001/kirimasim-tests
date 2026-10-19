# kirimasim-tests

A conformance test suite for IEEE 1800-2023 SystemVerilog simulators.

The tests are written for the [kirimasim](https://github.com/kurochan001/kirimasim)
simulator, but they are meant to be usable with any simulator. Every test
records where its expected result comes from and which clauses of the
standard it checks.

> **Status: early.** The suite has 2043 tests. Each one was checked
> against IEEE 1800-2023 by reading the cited clauses, and its expected output
> matches Icarus Verilog 13.0 or, for tests that Icarus Verilog 13.0 cannot
> compile or does not run as the standard says, Verilator 5.052. A few tests
> follow the standard where neither simulator does (see below).

## Layout

```text
tests/chNN/<name>.sv            the test, with a metadata header
tests/chNN/<name>.expected      expected standard output (multi-line)
tests/chNN/<name>.c             C code of a DPI or VPI test (see below)
tools/normalize_output.py       removes simulator banners before comparing
tools/run_icarus.py             runs the suite with Icarus Verilog
tools/run_verilator.py          runs the Verilator-oracle tests with Verilator
```

Tests are grouped by the chapter of IEEE 1800-2023 that their first
`:lrm:` clause belongs to. Chapters 3 to 39 have tests, except chapter 34
(protected envelopes), which depends on encryption that each tool defines.
Chapters 1 and 2 set out no behavior to test; the system functions of chapter
40 return what the coverage collected by each tool gives.

## Test format

Each test starts with a metadata comment compatible with
[sv-tests](https://github.com/chipsalliance/sv-tests). sv-tests ignores the
extra fields.

| Field | Meaning |
| --- | --- |
| `:name:` | Test name, unique in the suite |
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
| `:vpi_c:` | `@<file>`: a VPI application next to the test, which registers its system tasks and callbacks from `vlog_startup_routines` (chapters 36 to 39) |

A test passes when the simulator's standard output, after removing empty
lines and the simulator's own banners (see `tools/normalize_output.py`),
is exactly the expected output.

A test whose output depends on the time unit or precision (a nonzero time
printed with `%t`, `$timeformat`, `$printtimescale`, fractional delays or
delays with time units) sets them with `` `timescale `` before its first design
element: the default time unit and precision are implementation-specific
(IEEE 1800-2023 3.14.2.3).

A test with `:dpi_c:` or `:vpi_c:` is the SystemVerilog file together with
its C file, which has the same name. The C file includes only the standard
headers `svdpi.h` (Annex I), `vpi_user.h` (Annex K) or `sv_vpi_user.h`
(Annex M) and those of the C library, and it compiles both as C and as C++
(Verilator compiles it as C++), with its definitions inside `extern "C"`.
Results are returned to SystemVerilog and printed with `$display` where
possible; C code that prints uses `vpi_printf`, or `printf` followed by
`fflush(stdout)`. sv-tests' runners do not know these fields and compile only
the SystemVerilog file, so such a test fails there.

Tests of file input and output (IEEE 1800-2023 21.3 to 21.5) and of SDF
annotation (chapter 32), which write the SDF file they annotate, create files
named after the test in the current directory. Both runners run every test
in a temporary directory.

## Running with Icarus Verilog

```sh
python3 tools/run_icarus.py
python3 tools/run_icarus.py --iverilog-bin /path/to/icarus-13.0/bin
```

Each test is compiled with `iverilog -g2012 -gspecify -ginterconnect`: without
`-gspecify` Icarus Verilog ignores specify blocks, and `-ginterconnect` lets it
annotate SDF interconnect delays. For a test with `:vpi_c:`, the C file is
built with `iverilog-vpi` and loaded with `vvp -m`. Icarus Verilog has no DPI,
so the tests with `:dpi_c:` are known differences.

Where Icarus Verilog 13.0 does not follow the standard, the expected output
follows the standard and `:oracle:` is `spec` without `iverilog@13.0`.
`tools/run_icarus.py` reports such a test as a known difference and does not
count it as a failure. The same applies to tests that Icarus Verilog 13.0
cannot compile; their `:oracle:` lists `verilator@5.052` instead.

## Running with Verilator

```sh
python3 tools/run_verilator.py
python3 tools/run_verilator.py --seed 7
```

This runs only the tests whose `:oracle:` lists `verilator@5.052`. Verilator is
a two-state simulator, so all of these tests are `:fourstate: no`. Each test is
built with `verilator --binary --timing` and run with random initial values
(`--seed` chooses them); the expected outputs were checked to be the same with
two different seeds. Verilator's own lines are removed before comparing: its
banners and its run-time warnings (`%Warning-...`), which it prints on standard
output, for example when the constraints of a `randomize()` call cannot be met.
Tests whose results depend on random values print only what the standard fixes,
such as whether every constraint held. The C file of a test with `:dpi_c:` is
built into the model; for `:vpi_c:` the model is also built with `--vpi` and
`--public-flat-rw`, but Verilator does not support user-defined system tasks,
which the VPI tests use.

## Contributing

Changes that modify, remove, or relax an existing expected result must say
why and cite the IEEE 1800-2023 clause. Do not copy text, figures, or example
code from the standard; describe behavior in your own words and cite clause
numbers.

Most of the material here was produced with AI assistance (Claude Code);
people are responsible for checking the expected results against the
standard.

## License

Apache License 2.0. See [LICENSE](LICENSE).

# kirimasim-tests

A conformance test suite for IEEE 1800-2023 SystemVerilog simulators.

The tests are written for the [kirimasim](https://github.com/kurochan001/kirimasim)
simulator, but they are meant to be usable with any simulator. Every test
records where its expected result comes from and which clauses of the
standard it checks.

> **Status: early.** The suite has 1880 tests. Each one was checked
> against IEEE 1800-2023 by reading the cited clauses, and its expected output
> matches Icarus Verilog 13.0 or, for tests that Icarus Verilog 13.0 cannot
> compile, Verilator 5.052. A few tests follow the standard where neither
> simulator does (see below).

## Layout

```text
tests/chNN/<name>.sv            the test, with a metadata header
tests/chNN/<name>.expected      expected standard output (multi-line)
tools/normalize_output.py       removes simulator banners before comparing
tools/run_icarus.py             runs the suite with Icarus Verilog
tools/run_verilator.py          runs the Verilator-oracle tests with Verilator
```

Tests are grouped by the chapter of IEEE 1800-2023 that their first
`:lrm:` clause belongs to.

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

A test passes when the simulator's standard output, after removing empty
lines and the simulator's own banners (see `tools/normalize_output.py`),
is exactly the expected output.

A test whose output depends on the time unit or precision (a nonzero time
printed with `%t`, `$timeformat`, `$printtimescale`, fractional delays or
delays with time units) sets them with `` `timescale `` before its first design
element: the default time unit and precision are implementation-specific
(IEEE 1800-2023 3.14.2.3).

## Running with Icarus Verilog

```sh
python3 tools/run_icarus.py
python3 tools/run_icarus.py --iverilog-bin /path/to/icarus-13.0/bin
```

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
two different seeds.

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

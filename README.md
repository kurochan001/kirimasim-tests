# haremasim-tests

A conformance test suite for IEEE 1800-2023 SystemVerilog simulators.

The tests are written for the [haremasim](https://github.com/kurochan001/haremasim)
simulator, but they are meant to be usable with any simulator. Every test
records where its expected result comes from and which clauses of the
standard it checks.

> **Status: early.** The suite has 177 tests. Each one was checked
> against IEEE 1800-2023 by reading the cited clauses, and its expected output
> matches Icarus Verilog 13.0.

## Layout

```text
tests/chNN/<name>.sv            the test, with a metadata header
tests/chNN/<name>.expected      expected standard output (multi-line)
tools/normalize_output.py       removes simulator banners before comparing
tools/run_icarus.py             runs the suite with Icarus Verilog
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
| `:oracle:` | Where the expected output comes from: `spec` (a person checked it against the standard), `iverilog@13.0` (Icarus Verilog 13.0 produced it) |
| `:fourstate:` | Whether the test uses x or z values (`yes` / `no`) |
| `:nondeterministic:` | Whether the result can depend on an ordering the standard leaves open |
| `:expected_stdout:` | Expected standard output, or `@<file>` naming a file next to the test |

A test passes when the simulator's standard output, after removing empty
lines and the simulator's own banners (see `tools/normalize_output.py`),
is exactly the expected output.

## Running with Icarus Verilog

```sh
python3 tools/run_icarus.py
python3 tools/run_icarus.py --iverilog-bin /path/to/icarus-13.0/bin
```

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

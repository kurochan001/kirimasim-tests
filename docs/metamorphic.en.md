# Metamorphic checks

[English](metamorphic.en.md) / [日本語](metamorphic.md)

A test is transformed in a way that does not change its meaning, the original and the copy are run on the same simulator and their normalized outputs are compared. No expected output is used, so a wrong expectation does not hide a simulator defect or a hidden dependency of the test. The tool is `tools/metamorphic.py`. It rewrites no `.sv` or expectation of the repository but a copy in a temporary directory, and it does not change the runners: it calls their judge function and takes the normalized output that the runner is about to compare.

<a id="transforms"></a>

## Transforms and why they keep the meaning

- M1 renaming: the variables and nets the file declares are renamed uniformly (5.6, 3.13, 23.9: a name only binds a declaration to its uses). Left out: tests where a name appears in the expected output, in a string or in a VCD or SDF file, and tests with C code, `:top_module:`, several files, `include, `define or escaped identifiers.
- M2 white space and comments: a comment and a line break are added after every semicolon outside strings, comments and directive lines (5.3, 5.4: white space and comments only separate tokens). Left out: tests that can print a line or file position (`__LINE__`, `line, %l, severity tasks, assertions) and tests whose run printed a position in the file.
- M3 larger time unit: the unit and the precision of every `timescale directive are multiplied by ten (3.14, 22.7: delays are counted in the unit, and $time, $stime and $realtime return values in it, 20.3). Left out: tests with time literals that carry a unit (5.8), %t or $timeformat (21.2.1.3, 20.4.2), $printtimescale, $timeunit, $timeprecision, timeunit declarations, SDF or value change dumps, and tests without a `timescale directive.

Every transform also leaves out a test whose run printed a path, since a simulator can write a diagnostic on the standard output. When the outputs differ, the original is run three more times; if its output changes, the difference is recorded as "original varies".

<a id="icarus"></a>

## Icarus Verilog 13.0 (2026-11-21)

Version: `Icarus Verilog version 13.0 (stable) (v13_0)`. The simulation tests were run (illegal designs and formal tests left out).

| Transform | same | different | original varies | not compared | excluded |
| --- | ---: | ---: | ---: | ---: | ---: |
| M1 | 2575 | 0 | 0 | 1718 | 8688 |
| M2 | 7578 | 0 | 3 | 3647 | 1753 |
| M3 | 1157 | 0 | 0 | 1166 | 10658 |

Why tests were left out:

- M1: a renamed name appears in the expected output 6075, a renamed name appears in a string 1078, C code 742, no renamable declaration 385, `define 223, :top_module: 51, an escaped identifier 50, the run prints a path 42, several files 20, the design names its signals in a file 15, `include 7
- M2: can print a line or file position 827, C code 742, the run prints a path 77, an escaped identifier 50, the run prints a position in the file 30, several files 20, `include 7
- M3: no `timescale directive 8889, prints or reads time units 867, C code 742, a time literal with a unit 78, the run prints a path 55, several files 20, `include 7

Differences and their class:

| Test | Transform | State | Class |
| --- | --- | --- | --- |
| `gen/ch20/test_gen_cross_query_w129_b_prefix_one_low_mixed` | M2 | original varies | simulator defect |
| `gen/ch20/test_gen_cross_query_w129_l_prefix_x_low_zero` | M2 | original varies | simulator defect |
| `gen/ch20/test_gen_cross_query_w64_b_prefix_many_middle_unknown` | M2 | original varies | simulator defect |

<a id="kirimasim"></a>

## kirimasim (2026-11-21)

Version: `kirimasim 0.1.1 (commit a6222f0656d4), built with AppleClang 21.0.0.21000401`. The simulation tests were run (illegal designs and formal tests left out).

| Transform | same | different | original varies | not compared | excluded |
| --- | ---: | ---: | ---: | ---: | ---: |
| M1 | 3550 | 0 | 0 | 785 | 8646 |
| M2 | 9912 | 0 | 0 | 1423 | 1646 |
| M3 | 1791 | 0 | 0 | 587 | 10603 |

Why tests were left out:

- M1: a renamed name appears in the expected output 6075, a renamed name appears in a string 1078, C code 742, no renamable declaration 385, `define 223, :top_module: 51, an escaped identifier 50, several files 20, the design names its signals in a file 15, `include 7
- M2: can print a line or file position 827, C code 742, an escaped identifier 50, several files 20, `include 7
- M3: no `timescale directive 8889, prints or reads time units 867, C code 742, a time literal with a unit 78, several files 20, `include 7

Differences and their class:

None.

The kirimasim results are not added to any published count; they are recorded here only.

<a id="findings"></a>

## Findings

- On Icarus Verilog 13.0 no test gave another output after any transform.
- Three tests compared under M2 (`gen/ch20/test_gen_cross_query_*`) changed their output when the original was run again (eight in another run of the same day; the number changes from run to run). This is the nondeterministic `$countones` of a concatenation or replication argument whose width is not a multiple of 32, already recorded in the 20.9 row of [the simulator differences](simulator-differences.md) and by `icarus_unstable` in `generators/interaction_query.py`. On 2026-11-12 it did not vary on macOS; this time it did on macOS arm64: twelve runs of `test_gen_cross_query_w129_l_prefix_x_low_zero` gave `ones=` 2 (nine times), 8 (twice) and 9 (once), where the standard gives 2. It is not caused by the transform, so it is classed as a simulator defect.
- The first attempt showed 76 differences. Icarus writes diagnostics on the standard output with the path and line of the file, and names can be observed through VCD and SDF files; these were gaps in the exclusions. With the paths replaced, the exclusions after the run and the added M1 exclusions (strings, VCD, SDF) there are none.
- On kirimasim no transform gave a difference.
- No hidden dependency of a test was found.

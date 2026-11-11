<a id="ghost-triage-2026-11-11"></a>

# Ghost triage of the 2026-11-11 run

[English](ghost-triage-20261111.en.md) / [日本語](ghost-triage-20261111.md)

This is a triage of one full run of Ghost against `kirimasim-tests` at
`36ba5dd1`. It records the public counts and the test-side actions. The
private profile, executable version, paths and raw diagnostics are not
reproduced here; only the executable hash identifies the build.

<a id="scope"></a>

## Scope

- Suite: `36ba5dd1`, 11,897 non-formal simulation tests.
- Ghost: private build, executable sha256
  `6154f1bce2d75faddde2022961a140d1d2228462b73a5893e6fac315118a0d44`.
- Runner: `tools/run_ghost.py` with the saved private profile, DPI/VPI C
  sources compiled into shared libraries.
- Runs: all tests at `-j 24`, then every failure again at `-j 8`.

<a id="result"></a>

## Result

The first run reported 350 failures. The `-j 8` retry left 345: 221 illegal
designs were accepted and 124 failed for another reason. A separate run with
strict LRM checking enabled reported 210 failures; the `-j 8` retry left 124
deterministic failures, 119 of them the same tests. The 86 tests that
disappeared are treated as load-dependent flakiness, not as results.

The 124 failures are classified as follows.

| Class | Tests | Destination |
| --- | ---: | --- |
| Illegal designs accepted by the default profile, rejected with strict LRM checking | 221 | test-side [#70](https://github.com/kurochan001/kirimasim-tests/issues/70) |
| Rejected, but the diagnostic place or wording differs | 15 | test-side [#71](https://github.com/kurochan001/kirimasim-tests/issues/71) |
| A legal fixture that violates 6.21 (static initializer) | 1 | test-side [#72](https://github.com/kurochan001/kirimasim-tests/issues/72) |
| Non-VPI product defects | 63 | 20 issues in the private product tracker |
| VPI object-model family, UDP put and two residuals | 30 | existing private object-model and UDP issues, public #65, and a closed constraint residual |
| Covergroup tolerance bin | 1 | an existing open coverage issue in the private tracker |
| Already tracked by open test-side issues #58 to #69 | 14 | no new issue |

Some tests appear in two rows because a diagnostic comparison and a product
behaviour both fail; the rows are not a partition.

<a id="test-side"></a>

## Test-side issues

Three public issues were filed.

- [#70](https://github.com/kurochan001/kirimasim-tests/issues/70): the profile
  used for conformance runs does not enable strict LRM checking. All 221
  accepted illegal designs are rejected, with the expected diagnostic, when
  strict checking is enabled on the same binary. Adding it to the profile is
  the suggested fix.
- [#71](https://github.com/kurochan001/kirimasim-tests/issues/71): 15 illegal
  designs are rejected, but the diagnostic does not name the place or uses a
  different wording. This is the residual of the decision on #27. The design
  is illegal; only the comparison fails.
- [#72](https://github.com/kurochan001/kirimasim-tests/issues/72): the `ch10`
  assignment-pattern fixture declares a block variable with an initializer and
  no `static` or `automatic`, which 6.21 forbids. This is the same fixture
  error as the closed #46, in another test.

The 124 other failures include 14 tests that open test-side issues #58 to #69
already describe: deferred assertion and multiclock fixtures, empty matches,
DPI open arrays, the ch23 explicit-port `%h` form, the ch31 fullskew fixture,
and the ch19 transition bin.

<a id="product-side"></a>

## Product-side issues

Twenty issues were filed in the private product tracker. They group as
follows.

| Area | Tests | Main finding |
| --- | ---: | --- |
| Port collapse and net delay | 12 | both net delays are kept (3+7 behaves as 10), a wire/tri port stays `x`, and some runs do not end |
| Constraint solver and distributions | 11 | satisfiable sets report no solution; soft priority, `solve...before`, randc and object seeding are wrong |
| Covergroup options and bins | 5 | `option.x` is not per instance, real ranges split into the wrong intervals, a block event never samples |
| Utility system functions | 3 | `$bits` of an empty associative array, reduction functions on unpacked aggregates, `$bitstoshortreal` |
| Assertion VPI and coverage VPI | 4 | counters stay zero, a non-matching cover property reports failures, `vpiCoveredMax` is -1 |
| Assertions | 3 | `dist` in an assertion evaluates nothing; an edge of a boolean expression ticks on an operand edge |
| Force, release and streaming | 3 | part-select force freezes unforced bits; release does not re-evaluate a continuous assignment; streaming into class handles writes implicit state |
| FST and file I/O | 3 | the first FST block is corrupt; a word-count warning is missing; `wait_order` omits the file and line |
| Compilation unit, config and literals | 4 | an included compilation-unit variable initializes to 0; a config `use` clause is rejected; the fill literal keeps 32 bits |
| DPI, interconnect and interfaces | 4 | `svGetPartselBit` keeps bits above the width; an inherited interconnect port reports a loop; two interface instances share a function result |
| Illegal designs that pass elaboration | 2 | a virtual-interface continuous assign and a dynamic array to an output open-array DPI formal fail only at run time |

The private tracker also received a comment on its VPI object-model issue
with the additional fixtures that still fail in that family, and one comment
on the constraint-solver issue with a generated product-constraint fixture.

<a id="flakiness"></a>

## Flakiness

At `-j 24`, 86 tests failed and then passed when the same 124 failed files were
rerun at `-j 8`. They are not counted as failures and no issue was filed for
them. The pattern is a load-dependent loss of output or an end-of-run delay,
not a reproducible difference. A Nightly run at a lower parallelism should
confirm whether it recurs.

<a id="reproduction"></a>

## Reproduction

The public part is reproducible with the runner in this repository and a
private profile outside it.

```sh
cd kirimasim-tests
python3 tools/run_ghost.py --simulator /path/to/private/simulator \
  --profile /path/to/private-profile.json --include /path/to/include \
  -j 8 --json out/ghost.json
```

To reproduce the 221 accepted illegal designs, run the same command with and
without strict LRM checking in the private profile and compare the verdicts of
the `:should_fail_because:` tests.

<a id="notes"></a>

## Notes

- The private main moved while the run was in progress. A copy of the
  executable was fixed before the retry, and the counts above refer to the
  hash in Scope. A rebuild from a later private main may change individual
  results.
- The 221 accepted designs are one profile decision, not 221 independent
  defects. They are kept out of the product count.
- No commercial simulator was run for this triage, and no output of one is
  recorded here.

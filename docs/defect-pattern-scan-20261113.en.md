<a id="defect-pattern-scan-2026-11-13"></a>

# Suite-wide search for the defect patterns found in the review (2026-11-13)

[English](defect-pattern-scan-20261113.en.md) / [日本語](defect-pattern-scan-20261113.md)

The review of the tests that only Ghost passes ([Clause 37](ghost-only-review-ch37-20261113.en.md), [Clauses 36, 38, 39 and 40](ghost-only-review-vpi-20261113.en.md), [the remaining clauses](ghost-only-review-rest-20261113.en.md)) found three kinds of defect that other tests may also have.
This record gives the result of searching the whole suite for them.
The verdicts come from the standard alone; no simulator output was used.
No test was changed in this search.

<a id="method"></a>

## Method

- For patterns 1 and 2, a script that is not kept searched the 626 C files of the tests. I read the code at every place it found.
- Pattern 3 concerns the 63 simulation tests with timing checks. For the 42 of Clauses 31 and 32 that pass on Ghost alone, the review already checked the changes at time 0. One AI review read the other 21 (the seven outside Clauses 31 and 32 that pass on Ghost alone, and 14 others), for changes at time 0 only.
- All checks were made by AI. They are not an independent human review.

<a id="pattern-1"></a>

## Pattern 1: two results of `vpi_get_str` used together

By 38.11 every call of `vpi_get_str` puts its string in the same temporary buffer. When two results are arguments of one call, the standard does not settle which strings are printed.

- The mechanical search found 34 places in 27 files. Most of them use the first result only to test for NULL, as in `vpi_get_str(…) ? vpi_get_str(…) : "…"`, or pass each result through a helper that copies the string at once; these are fine.
- The candidates where a saved pointer is used after a later call (10 places in 9 files) are all fine as well. `ch38/test_vpi_string_buffers` is a test of the shared buffer itself.
- The following six tests have the defect. They replace the rough figure of "29 C files of Clause 37" in the record of the Clause 37 review.

| Test | Status |
|---|---|
| `ch37/test_vpi_class_internal_scopes` | Recorded in the Clause 37 review |
| `ch37/test_vpi_frame_automatics_thread` | Recorded in the Clause 37 review |
| `ch37/test_vpi_interconnect_net_typespec` | Recorded in the Clause 37 review |
| `ch37/test_vpi_io_direction_undefined` | Recorded in the Clause 37 review |
| `ch37/test_vpi_local_connectivity_ports` | Recorded in the Clause 37 review |
| `ch37/test_vpi_struct_and_tagged_patterns` | New; no simulator passes it now |

<a id="pattern-2"></a>

## Pattern 2: a startup routine does what is not allowed yet

By 36.10.2 the routines of `vlog_startup_routines` can call only `vpi_register_systf` and `vpi_register_cb`, and only six callback reasons can be registered.

- The following 16 tests have the defect. Ten were recorded in the review of Clauses 36, 38, 39 and 40.

| Test | What it does | Status |
|---|---|---|
| `ch36/test_vpi_compatibility_h_1364v1995`, `_1364v2001`, `_1364v2005`, `_1800v2005`, `_1800v2009`, `_1800v2012` (six tests) | Calls `vpi_printf` | Recorded |
| `ch38/test_vpi_array_get_errors`, `ch38/test_vpi_array_put_formats`, `ch38/test_vpi_net_array_deposit` (three tests) | Registers `cbAfterDelay` | Recorded |
| `ch39/test_vpi_assertion_system_control` | Registers `cbAssertionSys…` | Recorded |
| `ch36/test_vpi_compatibility_1800v2017_mode`, `ch36/test_vpi_compatibility_1800v2023_mode` (two tests) | Calls `vpi_printf` and other routines | New; no simulator passes them now |
| `ch20/test_assertcontrol_callbacks_system` | Registers `cbAssertionSys…` | New; no simulator passes it now |
| `ch38/test_vpi_array_get_formats`, `ch38/test_vpi_get_array_static` (two tests) | Registers `cbAfterDelay` | New; Verilator and Ghost pass them |
| `ch38/test_vpi_release_remove_signatures` | Registers `cbAfterDelay` | New; Icarus and Ghost pass it |

- The following are not counted as defects. `ch36/test_vpi_end_of_simulation_after_final` and a few others call `vpi_printf` only when a registration fails, which does not touch the expectation. In `ch38/test_vpi_startup_routines_null_end` the `vpi_printf` is in a routine after the NULL entry of the array, which is never called; that is what the test checks.

<a id="pattern-3"></a>

## Pattern 3: a change at time 0 changes the result of a timing check

At time 0 a port net changes from z to a value (6.7.1, 4.9.1, 4.9.6). When that change is a reference or a violation for a timing check, the printed lines can change.

- None of the 21 tests checked prints anything different because of a change at time 0. Either the change is not an edge of the kind the check waits for, or its effect does not reach the output.
- In the whole suite, only `ch31/test_timing_edge_descriptors_all` and `ch32/test_sdf_tchk_edge_condition_match`, recorded in the review of the remaining clauses, have the defect.

<a id="next"></a>

## What happens next

- The seven new tests (one of pattern 1 and six of pattern 2) are not among the tests that pass on Ghost alone. Like the other defects, they will be corrected when Ghost's results are saved again. For three of them the results of Icarus or Verilator change too.
- The figures of the review of the tests that only Ghost passes are unchanged. The coverage figures are unchanged.

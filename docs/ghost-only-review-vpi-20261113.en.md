<a id="ghost-only-review-vpi-2026-11-13"></a>

# Review of the tests that only Ghost passes: Clauses 36, 38, 39 and 40 (2026-11-13)

[English](ghost-only-review-vpi-20261113.en.md) / [日本語](ghost-only-review-vpi-20261113.md)

This record gives the result of comparing with IEEE 1800-2023 the 141 tests of Clause 36 (PLI/VPI overview), Clause 38 (VPI routines), Clause 39 (assertion API) and Clause 40 (coverage API) that match their expectation on Ghost alone.
The method is that of the [review of Clause 37](ghost-only-review-ch37-20261113.en.md).
The verdicts come from the standard alone; no simulator output was used.
No test was changed in this review.

<a id="what-was-reviewed"></a>

## What was reviewed

- In the Nightly of 2026-11-12 the tests that pass on Ghost alone number 28 in Clause 36, 41 in Clause 38, 37 in Clause 39 and 35 in Clause 40.
- Two reviews read all 141 tests without seeing each other's results. Where the verdicts differ, the text, the tables and the diagrams of the standard decided.
- All reviews were made by AI. They are not an independent human review.

<a id="verdicts"></a>

## Verdicts

| Verdict | Tests |
|---|---:|
| The expectation is right | 108 |
| The expectation is wrong | 3 |
| The test is flawed | 19 |
| The reading is contested | 11 |
| Total | 141 |

The two reviews agreed on "right" for 105 tests.

<a id="wrong"></a>

## The three wrong expectations

| Test | Clauses | What is wrong |
|---|---|---|
| `ch39/test_vpi_assertion_system_task_control` | 20.11, 39.4.2 | It expects a `cbAssertionKill` callback for `$assertkill` with arguments. Table 20-8 of 20.11 gives `cbAssertionReset` and `cbAssertionDisable` for that case. The line at 36 becomes a disable. |
| `ch40/test_coverage_control_interface_scope` | 40.3.2.1, 40.3.2.2 | It passes the hierarchical path of the instance as a string. By the NOTE of Table 40-2 a string is a definition name and an instance is given by a hierarchical path. No definition has that name, so the results are `SV_COV_ERROR` and -1, and both lines print 0. |
| `ch40/test_coverage_control_program_scope` | 40.3.2.1, 40.3.2.2 | It also passes the path of the program instance as a string. Both lines print 0. |

<a id="flawed"></a>

## The 19 flawed tests

| Test | Clauses | What is flawed |
|---|---|---|
| `ch36/test_vpi_compatibility_h_1364v1995`, `_1364v2001`, `_1364v2005`, `_1800v2005`, `_1800v2009`, `_1800v2012` (six tests) | 36.10.2 | They call `vpi_printf` from the routine of `vlog_startup_routines`. By 36.10.2 only `vpi_register_systf` and `vpi_register_cb` can be called at that stage. The printed content follows Annex L. |
| `ch38/test_vpi_array_get_errors`, `ch38/test_vpi_array_put_formats`, `ch38/test_vpi_net_array_deposit` (three tests) | 36.10.2 | They register `cbAfterDelay` from the startup routine. 36.10.2 allows six reasons at startup, and `cbAfterDelay` is not one of them. The values follow 38.16 and 38.35. |
| `ch39/test_vpi_assertion_system_control` | 36.10.2, 39.4.1 | It registers the `cbAssertionSys…` callbacks from the startup routine. They are not among the six reasons of 36.10.2 either. |
| `ch38/test_vpi_callback_registration_errors` | 38.36.1 | It registers `cbForce` without a value structure. 38.36.1 requires the value format, so the reason for the refusal of the bit-select registration cannot be told. |
| `ch38/test_vpi_put_value_delay_modes` | 38.34, 4.7 | Several values are updated at the same time and one always block prints them. The order of the updates and of the block is not fixed, so extra lines with intermediate values also follow the standard. |
| `ch38/test_vpi_stmt_callback_kinds` | 37.12, 38.36.1.1 | It tells the statements apart by their position in the `vpiStmt` iteration. The standard does not fix that order (minor). |
| `ch39/test_vpi_assertion_kill_keeps_past_sampling` | 39.4.2 | It reads the callback times as integers without checking the time type. 39.4.2 does not fix the type. The other tests of the chapter check it. |
| `ch40/test_coverage_reset_and_stop` | 40.2.2, 40.3.2.1 | Right after the reset the variable `r`, which is inside the measured scope, goes from 0 to 1 before the read. Whether that bit counts is not settled. |
| `ch40/test_coverage_save_merge` | 40.2.2, 40.3.2.5 | Between the two reads the variables `cov_before` and `saved`, which are inside the measured scope, change. The value need not be the same before and after the save. |
| `ch40/test_coverage_scope_sums` | 40.2.2, 40.3.2.3 | It reads the top module and its hierarchy in separate statements. Those statements and their variables change the coverage in between. |
| `ch40/test_coverage_uninstantiated_module` | 23.3.1, 40.3.2.1 | By 23.3.1 a module that is instantiated nowhere is a top-level module with one implicit instance. That it has no instance depends on the tool's choice of the top. |
| `ch40/test_coverage_get_status_and_relations` | 40.2.1, 40.3.2.2 | It expects coverage type 99 to be an incorrect argument. 40.2.1 lets vendors add types (minor). |

<a id="contested"></a>

## The 11 contested tests

| Test | Clauses | What is contested |
|---|---|---|
| `ch36/test_vpi_chk_error_callbacks` | 38.36.2 | 38.36.2 does not say that an erroneous registration returns `NULL`. That it is an error is settled. |
| `ch36/test_vpi_compiletf_sizetf` | 36.10.2, 38.37.1 | 36.10.2 does not state that a compiletf runs before `cbEndOfCompile`. |
| `ch38/test_vpi_error_callback_runtime_errors` | 38.36.3, 20.10 | 38.36.3 does not say whether `$error` causes `cbError`. 20.10 calls it a run-time error. |
| `ch38/test_vpi_get_value_array` | 38.16, 38.15 | Whether elements of `logic [7:0]` can be read with `vpiIntVal` is contested. 38.16 makes a format that does not fit the element type an error. |
| `ch38/test_vpi_get_value_real_conversion` | 38.15 | Whether "16 digits of precision" of the string of a real means significant digits or fraction digits is contested. |
| `ch38/test_vpi_mcd_open_reuse` | 38.25 | 38.25 does not say whether flushing a channel without a file fails. The other five lines are right. |
| `ch38/test_vpi_value_change_event` | 38.36.1, 37.27 | It places `cbValueChange` on a named event object. 38.36.1 speaks of event statements. |
| `ch39/test_vpi_assertion_reset_restores_initial_state` | 39.5.2 | Whether the "initial state" that a reset restores includes the enable and action settings is contested. |
| `ch40/test_coverage_control_package_scope` | 40.3.2.1, 40.5.3 | It passes the name of a package as the scope. 40.3.2.1 speaks only of module definition names, and under that reading the expectation is wrong. 40.5.3 can be read to make a package a scope. |
| `ch40/test_coverage_fsm_next_state_pragmas` | 40.4, 40.4.5 | The maximum 5 depends on whether the pragmas also stop the automatic extraction of a signal without a pragma. |
| `ch40/test_vpi_coverage_save_merge` | 38.4, 40.5.3 | Whether `vpi_control` returns 0 (38.4) or -1 (40.5.3) for a merge of a name that was not saved is contested. |

<a id="figures"></a>

## What the diagrams settled

- `ch38/test_vpi_intermod_path_levels`: the diagram of 37.37 has a double arrow from the inter mod path to the ports. `vpiPort` iterates them, and the expectation is right.
- `ch39/test_vpi_assertion_handles`: the diagram of 37.49 has an arrow from the assertion to the instance. The expectation is right.

<a id="next"></a>

## What happens next

- The three wrong tests and the 19 flawed tests will be corrected when Ghost's results are saved again.
- The 11 contested tests wait for a decision.
- C code that uses, from the startup routine, a routine or a reason that 36.10.2 does not allow may also exist in tests that pass elsewhere. The next review will search the whole suite.
- The coverage figures are unchanged.

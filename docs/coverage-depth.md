# Coverage depth

[All chapters](README.md). This page is written by `tools/coverage_depth.py` from the metadata of the tests; edit the tests, not this page. It counts how many tests cite each clause in `:lrm:` and which releases produce their expected outputs. A citation is not a measure of how deeply a behavior is exercised: one test can cite several clauses, and several tests can cite one clause.

## Summary

| Measure | Value |
| --- | ---: |
| Tests | 3801 |
| Clauses in scope | 932 |
| Clauses out of scope | 227 |
| Clauses with one test | 186 |
| Clauses with two tests or fewer | 445 |
| Clauses with only standard-only tests | 258 |
| Clauses with one test and only a standard-only test | 65 |

| Oracle | Tests |
| --- | ---: |
| both releases | 171 |
| Icarus Verilog 13.0 only | 2355 |
| Verilator 5.052 only | 773 |
| standard only | 502 |

## By chapter

| Chapter | Title | Tests | In scope | Tests/clause | One test | Standard only |
| ---: | --- | ---: | ---: | ---: | ---: | ---: |
| 3 | Design and verification building blocks | 27 | 7 | 3.9 | 0 | 2 |
| 4 | Scheduling semantics | 382 | 27 | 14.1 | 10 | 5 |
| 5 | Lexical conventions | 35 | 16 | 2.2 | 9 | 1 |
| 6 | Data types | 303 | 74 | 4.1 | 26 | 19 |
| 7 | Aggregate data types | 309 | 49 | 6.3 | 12 | 10 |
| 8 | Classes | 154 | 42 | 3.7 | 15 | 19 |
| 9 | Processes | 114 | 25 | 4.6 | 5 | 9 |
| 10 | Assignment statements | 106 | 17 | 6.2 | 3 | 4 |
| 11 | Operators and expressions | 704 | 42 | 16.8 | 14 | 6 |
| 12 | Procedural programming statements | 120 | 14 | 8.6 | 4 | 2 |
| 13 | Tasks and functions (subroutines) | 126 | 14 | 9.0 | 5 | 4 |
| 14 | Clocking blocks | 53 | 14 | 3.8 | 0 | 5 |
| 15 | Interprocess synchronization and communication | 36 | 20 | 1.8 | 0 | 8 |
| 16 | Assertions | 99 | 66 | 1.5 | 0 | 63 |
| 17 | Checkers | 29 | 9 | 3.2 | 2 | 19 |
| 18 | Constrained random value generation | 60 | 44 | 1.4 | 0 | 16 |
| 19 | Functional coverage | 43 | 22 | 2.0 | 0 | 32 |
| 20 | Utility system tasks and system functions | 187 | 31 | 6.0 | 13 | 10 |
| 21 | Input/output system tasks and system functions | 86 | 36 | 2.4 | 17 | 4 |
| 22 | Compiler directives | 39 | 20 | 1.9 | 10 | 0 |
| 23 | Modules and hierarchy | 72 | 32 | 2.2 | 12 | 8 |
| 24 | Programs | 29 | 6 | 4.8 | 1 | 13 |
| 25 | Interfaces | 50 | 9 | 5.6 | 6 | 4 |
| 26 | Packages | 39 | 6 | 6.5 | 0 | 1 |
| 27 | Generate constructs | 68 | 4 | 17.0 | 0 | 1 |
| 28 | Gate-level and switch-level modeling | 176 | 26 | 6.8 | 5 | 34 |
| 29 | User-defined primitives | 40 | 13 | 3.1 | 1 | 3 |
| 30 | Specify blocks | 23 | 20 | 1.1 | 0 | 5 |
| 31 | Timing checks | 23 | 17 | 1.4 | 0 | 19 |
| 32 | Backannotation using the standard delay format | 23 | 10 | 2.3 | 2 | 14 |
| 33 | Configuring the contents of a design | 25 | 9 | 2.8 | 0 | 16 |
| 35 | Direct programming interface | 31 | 17 | 1.8 | 0 | 10 |
| 36 | Programming language interface (PLI/VPI) overview | 29 | 13 | 2.2 | 0 | 9 |
| 37 | VPI object model diagrams | 76 | 92 | 0.8 | 13 | 70 |
| 38 | VPI routine definitions | 41 | 44 | 0.9 | 0 | 15 |
| 39 | Assertion API | 21 | 7 | 3.0 | 1 | 21 |
| 40 | Code coverage control and API | 23 | 18 | 1.3 | 0 | 21 |

## Priority queue: one test, standard only

These clauses have exactly one citing test, and that test has `:oracle: spec` alone. They are the first candidates for a second test or an independent oracle.

- `4.4.2.5`: `tests/ch17/test_checker_reactive_triggered.sv`
- `4.4.2.8`: `tests/ch4/test_reactive_region_set_order.sv`
- `6.3.2.1`: `tests/ch6/test_trireg_default_value_strength.sv`
- `6.6.4.1`: `tests/ch6/test_trireg_holds_charge.sv`
- `6.6.4.2`: `tests/ch28/test_trireg_charge_decay.sv`
- `6.7.2`: `tests/ch6/test_nettype_initial_value_resolution.sv`
- `6.7.3`: `tests/ch6/test_nettype_initial_value_resolution.sv`
- `6.16.13`: `tests/ch6/test_string_conversion.sv`
- `6.16.14`: `tests/ch6/test_string_conversion.sv`
- `6.17`: `tests/ch6/test_event_variable_alias_null.sv`
- `6.22.6`: `tests/ch6/test_nettype_rename_matches.sv`
- `7.8.6`: `tests/ch7/test_assoc_array_unknown_index.sv`
- `7.9.8`: `tests/ch7/test_assoc_traversal_narrow_index.sv`
- `7.10.3`: `tests/ch7/test_queue_reference_persistence.sv`
- `8.26.5`: `tests/ch8/test_interface_class_cast.sv`
- `8.29`: `tests/ch8/test_object_strongly_reachable.sv`
- `8.30.1`: `tests/ch8/test_illegal_weak_reference_non_class.sv`
- `8.30.2`: `tests/ch8/test_weak_reference_get_clear.sv`
- `8.30.5`: `tests/ch8/test_weak_reference_get_id.sv`
- `9.4.4`: `tests/ch9/test_wait_sequence_triggered.sv`
- `10.10.1`: `tests/ch10/test_unpacked_array_concat_rules.sv`
- `10.10.3`: `tests/ch10/test_unpacked_array_concat_rules.sv`
- `11.3.1`: `tests/ch11/test_real_operand_result_types.sv`
- `12.6.1`: `tests/ch12/test_pattern_matching.sv`
- `12.6.2`: `tests/ch12/test_pattern_matching.sv`
- `12.6.3`: `tests/ch12/test_pattern_matching.sv`
- `17.6`: `tests/ch17/test_checker_covergroup.sv`
- `17.7.2`: `tests/ch17/test_checker_free_variables_assigned.sv`
- `20.16.1`: `tests/ch20/test_pla_async_array_plane.sv`
- `20.16.2`: `tests/ch20/test_pla_async_array_plane.sv`
- `20.16.3`: `tests/ch20/test_pla_async_array_plane.sv`
- `20.16.4`: `tests/ch20/test_pla_async_array_plane.sv`
- `21.2.1.6`: `tests/ch21/test_format_p_struct.sv`
- `21.7.1.1`: `tests/ch21/test_vcd_dump_readback.sv`
- `21.7.1.3`: `tests/ch21/test_vcd_dump_readback.sv`
- `21.7.1.4`: `tests/ch21/test_vcd_dump_readback.sv`
- `21.7.1.6`: `tests/ch21/test_vcd_dump_readback.sv`
- `21.7.2.1`: `tests/ch21/test_vcd_dump_readback.sv`
- `21.7.2.2`: `tests/ch21/test_vcd_dump_readback.sv`
- `21.7.2.3`: `tests/ch21/test_vcd_dump_readback.sv`
- `21.7.5`: `tests/ch21/test_vcd_dump_readback.sv`
- `23.2.2.1`: `tests/ch37/test_vpi_ports.sv`
- `23.3.3.7.2`: `tests/ch23/test_interconnect_primitive_terminal.sv`
- `23.4`: `tests/ch3/test_timeunit_precedence.sv`
- `23.5`: `tests/ch23/test_extern_module.sv`
- `23.10.4.2`: `tests/ch23/test_illegal_defparam_early_resolution.sv`
- `24.3.2`: `tests/ch24/test_program_port_reactive.sv`
- `25.5.5`: `tests/ch25/test_modport_clocking_block.sv`
- `28.15.2`: `tests/ch28/test_trireg_charge_strength.sv`
- `28.16.2.2`: `tests/ch28/test_trireg_three_delay_form.sv`
- `32.4.3`: `tests/ch32/test_sdf_label_specparam.sv`
- `37.23`: `tests/ch37/test_vpi_nettype_declarations.sv`
- `37.55`: `tests/ch37/test_vpi_statement_control_kinds.sv`
- `37.62`: `tests/ch37/test_vpi_statement_control_kinds.sv`
- `37.66`: `tests/ch37/test_vpi_statement_control_kinds.sv`
- `37.67`: `tests/ch37/test_vpi_statement_control_kinds.sv`
- `37.69`: `tests/ch37/test_vpi_statement_kinds.sv`
- `37.70`: `tests/ch37/test_vpi_statement_control_kinds.sv`
- `37.71`: `tests/ch37/test_vpi_statement_control_kinds.sv`
- `37.73`: `tests/ch37/test_vpi_statement_control_kinds.sv`
- `37.74`: `tests/ch37/test_vpi_statement_control_kinds.sv`
- `37.77`: `tests/ch37/test_vpi_statement_control_kinds.sv`
- `37.78`: `tests/ch37/test_vpi_statement_control_kinds.sv`
- `37.83`: `tests/ch37/test_vpi_attribute_object.sv`
- `39.4.2.1`: `tests/ch39/test_vpi_assertion_gclk_future_callback.sv`

## One-test clauses by chapter

| Chapter | Clauses |
| ---: | ---: |
| 4 | 10 |
| 5 | 9 |
| 6 | 26 |
| 7 | 12 |
| 8 | 15 |
| 9 | 5 |
| 10 | 3 |
| 11 | 14 |
| 12 | 4 |
| 13 | 5 |
| 17 | 2 |
| 20 | 13 |
| 21 | 17 |
| 22 | 10 |
| 23 | 12 |
| 24 | 1 |
| 25 | 6 |
| 28 | 5 |
| 29 | 1 |
| 32 | 2 |
| 37 | 13 |
| 39 | 1 |

## Clauses with only standard-only tests

These clauses are cited, but no release produces the expected output of any of their tests.

4.4.2.5, 4.4.2.7, 4.4.2.8, 6.3.2.1, 6.6.4.1, 6.6.4.2, 6.6.8, 6.7.2, 6.7.3, 6.16.13, 6.16.14, 6.17, 6.22.6, 7.3.2, 7.8.6, 7.9.8, 7.10.3, 8.26.4, 8.26.5, 8.26.6.2, 8.29, 8.30.1, 8.30.2, 8.30.3, 8.30.4, 8.30.5, 9.4.4, 10.10.1, 10.10.3, 11.3.1, 11.9, 12.6.1, 12.6.2, 12.6.3, 15.5.4, 15.5.5.1, 15.5.5.2, 15.5.5.3, 16.4.1, 16.4.2, 16.4.3, 16.4.4, 16.4.5, 16.8.1, 16.8.2, 16.9.1, 16.9.2.1, 16.9.4, 16.9.5, 16.9.6, 16.9.7, 16.9.8, 16.9.9, 16.9.10, 16.9.11, 16.10, 16.11, 16.12.1, 16.12.2, 16.12.3, 16.12.4, 16.12.5, 16.12.8, 16.12.9, 16.12.10, 16.12.13, 16.12.14, 16.12.17, 16.12.18, 16.12.19, 16.12.22, 16.13.1, 16.13.2, 16.13.3, 16.13.5, 16.13.6, 16.13.7, 16.14.2, 16.14.6.1, 16.14.6.2, 16.14.6.3, 16.14.6.4, 16.14.8, 16.16.1, 16.17, 17.4, 17.6, 17.7.2, 17.8, 19.4.1, 19.5.1.1, 19.5.1.2, 19.5.5, 19.5.6, 19.5.7, 19.6.1.2, 19.6.1.3, 19.6.1.4, 19.6.2, 19.6.3, 19.7.1, 19.9, 19.10, 19.11.2, 19.11.3, 20.4.1, 20.7.1, 20.11, 20.16.1, 20.16.2, 20.16.3, 20.16.4, 21.2.1.6, 21.7.1.1, 21.7.1.2, 21.7.1.3, 21.7.1.4, 21.7.1.6, 21.7.2.1, 21.7.2.2, 21.7.2.3, 21.7.5, 23.2.2.1, 23.3.3.7.1, 23.3.3.7.2, 23.4, 23.5, 23.10.4.2, 24.3.2, 24.6, 24.7, 25.5.5, 25.6, 28.15.2, 28.16.2.1, 28.16.2.2, 30.7.4.1, 30.7.4.2, 31.3.1, 31.3.2, 31.3.5, 31.4.1, 31.4.2, 31.4.3, 31.4.5, 31.4.6, 31.5, 31.7, 31.8, 32.4.2, 32.4.3, 33.4.1.5, 33.4.2, 35.5.1.5, 35.8, 35.9, 36.8.1, 36.10.1, 36.10.3, 37.3.2, 37.3.4, 37.3.5, 37.3.6, 37.3.8, 37.6, 37.7, 37.8, 37.9, 37.11, 37.13, 37.15, 37.18, 37.19, 37.20, 37.21, 37.22, 37.23, 37.24, 37.25, 37.26, 37.27, 37.28, 37.29, 37.30, 37.31, 37.32, 37.33, 37.34, 37.35, 37.36, 37.38, 37.39, 37.40, 37.41, 37.43, 37.44, 37.46, 37.47, 37.48, 37.49, 37.50, 37.51, 37.52, 37.53, 37.54, 37.55, 37.56, 37.57, 37.58, 37.59, 37.60, 37.61, 37.62, 37.63, 37.64, 37.65, 37.66, 37.67, 37.68, 37.69, 37.70, 37.71, 37.72, 37.73, 37.74, 37.75, 37.76, 37.77, 37.78, 37.79, 37.80, 37.81, 37.82, 37.83, 37.84, 38.8, 38.10, 38.16, 38.36.1.1, 38.36.1.2, 38.36.1.3, 39.3.1, 39.3.2, 39.4.1, 39.4.2.1, 39.5.1, 39.5.2, 39.5.3, 40.2.1, 40.2.2, 40.3.2.1, 40.3.2.2, 40.3.2.3, 40.3.2.4, 40.3.2.5, 40.5.1, 40.5.2, 40.5.3

## Cited clauses with an out-of-scope tag

These clauses are cited by tests but carry a tag in `tools/clauses.txt` that says they are out of scope. Either the tag or the citation needs a review.

- `8.3`: tag `none`
- `11.6.2`: tag `none`

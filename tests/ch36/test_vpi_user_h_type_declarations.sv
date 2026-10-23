/*
:name: test_vpi_user_h_type_declarations
:description: vpi_user.h defines the PLI integer types, vpiHandle and the fields, field order and typedef names of its delay, value, array value, product information, error information and callback structures as Annex K gives them (IEEE 1800-2023 Section 36.7, K.2)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.7 K.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_user_h_type_declarations.c
:expected_stdout: @test_vpi_user_h_type_declarations.expected
*/
// IEEE 1800-2023 §36.7: a VPI application includes vpi_user.h. K.2 fixes
// what the header defines: the PLI_* integer types (with the PLI_TYPES and
// SVPI_TYPES macros), the sized integer types it makes available, vpiHandle,
// the structures t_vpi_delay, t_vpi_value, t_vpi_arrayvalue,
// t_vpi_vlog_info, t_vpi_error_info and t_cb_data with the type and order of
// each field and their s_ and p_ typedef names, the include guard
// VPI_USER_H, and the inclusion of stdarg.h.
//
// The header is the first thing the C file includes, so the macros are
// looked at before any other header could define them. At the start of
// simulation (a cbStartOfSimulation callback, 38.36.3), the VPI application
// prints 1 for each check that holds: a type compared at compile time (C11
// _Generic in C, decltype in C++) with the type K.2 gives, the field order
// compared with offsetof, and the macros tested with #ifdef. A difference
// prints 0.

module test_vpi_user_h_type_declarations;
endmodule

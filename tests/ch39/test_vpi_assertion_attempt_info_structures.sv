/*
:name: test_vpi_assertion_attempt_info_structures
:description: sv_vpi_user.h defines s_vpi_assertion_step_info with the matched expression count and array and the two state numbers, and s_vpi_attempt_info with a detail union of the failing expression and the step pointer followed by the attempt start time, with their types, order and typedef names (IEEE 1800-2023 Section 39.4.2)
:tags: ch39
:type: simulation
:lrm: 1800-2023 39.4.2 36.7 38.36.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_assertion_attempt_info_structures.c
:expected_stdout: @test_vpi_assertion_attempt_info_structures.expected
*/
// IEEE 1800-2023 §39.4.2: an assertion callback gets a pointer to the attempt
// information structure t_vpi_attempt_info (typedef names s_vpi_attempt_info
// and p_vpi_attempt_info): a union named detail, which holds either the
// vpiHandle failExpr or the p_vpi_assertion_step_info step, followed by the
// s_vpi_time attemptStartTime. The step structure t_vpi_assertion_step_info
// (s_vpi_assertion_step_info, p_vpi_assertion_step_info) holds the PLI_INT32
// matched_expression_count, the vpiHandle* matched_exprs and the PLI_INT32
// stateFrom and stateTo, in this order. sv_vpi_user.h (§36.7) defines them.
//
// At the start of the simulation (a cbStartOfSimulation callback, 38.36.3)
// the VPI application prints 1 for each check that holds: a type compared at
// compile time (C11 _Generic in C, decltype in C++), the order of fields and
// the sharing of storage by the union members compared with offsetof. A
// different type or order prints 0, and a missing field does not compile.

module test_vpi_assertion_attempt_info_structures;
endmodule

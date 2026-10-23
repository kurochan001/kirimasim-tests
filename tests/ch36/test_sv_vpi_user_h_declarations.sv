/*
:name: test_sv_vpi_user_h_declarations
:description: sv_vpi_user.h includes vpi_user.h, has its include guard and declares the assertion step and attempt structures, the assertion callback function type and vpi_register_assertion_cb as Annex M gives them (IEEE 1800-2023 Section 36.7, M.2)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.7 M.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_sv_vpi_user_h_declarations.c
:expected_stdout: @test_sv_vpi_user_h_declarations.expected
*/
// IEEE 1800-2023 §36.7: a VPI application includes sv_vpi_user.h. M.2 fixes
// that the header includes vpi_user.h and is guarded by SV_VPI_USER_H, and
// it fixes the fields, field order and s_ and p_ typedef names of
// t_vpi_assertion_step_info and t_vpi_attempt_info (whose detail is a union
// of failExpr and step), the type vpi_assertion_callback_func and the
// declaration of vpi_register_assertion_cb.
//
// The header is the first thing the C file includes. At the start of
// simulation (a cbStartOfSimulation callback, 38.36.3), the VPI application
// prints 1 for each check that holds: a type compared at compile time (C11
// _Generic in C, decltype in C++) with the type M.2 gives, the field order
// compared with offsetof, and the macros tested with #ifdef. A difference
// prints 0.

module test_sv_vpi_user_h_declarations;
endmodule

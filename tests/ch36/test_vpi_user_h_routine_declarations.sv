/*
:name: test_vpi_user_h_routine_declarations
:description: vpi_user.h declares each VPI routine with the return type and the parameter types, pointer levels and variadic form that Annex K gives (IEEE 1800-2023 Section 36.7, K.2)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.7 K.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_user_h_routine_declarations.c
:expected_stdout: @test_vpi_user_h_routine_declarations.expected
*/
// IEEE 1800-2023 §36.7: a VPI application includes vpi_user.h, whose routine
// declarations K.2 lists: each routine has a fixed return type and fixed
// parameter types, in order, with their pointer levels, and vpi_printf,
// vpi_mcd_printf, vpi_control and vpi_handle_multi are variadic.
//
// At the start of simulation (a cbStartOfSimulation callback, 38.36.3), the
// VPI application compares the type of a pointer to each of the 41 routines
// with the function pointer type made from its K.2 declaration and prints 1
// when they are the same type. The comparison is done at compile time (C11
// _Generic in C, decltype in C++) on unevaluated expressions, so no routine
// is called, and a simulator that declares a routine with another return
// type, parameter type, pointer level or number of parameters prints 0 for
// it. A routine the header does not declare at all stops the compilation.

module test_vpi_user_h_routine_declarations;
endmodule

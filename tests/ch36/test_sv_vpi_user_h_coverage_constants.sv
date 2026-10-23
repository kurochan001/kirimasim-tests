/*
:name: test_sv_vpi_user_h_coverage_constants
:description: the coverage and FSM constants of sv_vpi_user.h have the values that Annex M gives them (IEEE 1800-2023 Section 36.7, M.2)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.7 M.1 M.2 38.36.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_sv_vpi_user_h_coverage_constants.c
:expected_stdout: @test_sv_vpi_user_h_coverage_constants.expected
*/
// IEEE 1800-2023 §36.7: a VPI application includes sv_vpi_user.h, the
// normative header that every simulator provides (M.1). M.2 defines each of
// its constants as a fixed number, so an application compiled against one
// simulator's header passes the same numbers as another's.
//
// At the start of simulation (a cbStartOfSimulation callback, 38.36.3), the
// VPI application prints the value of each of the 24 coverage and FSM
// constants in the order of M.2, only when the header defines it: a missing
// constant is a missing line, a wrong value is a different number, and a
// value that is not an integer constant in the range of int does not
// compile. A constant that M.2 defines as another constant or as an OR of
// constants is printed as the number it stands for.

module test_sv_vpi_user_h_coverage_constants;
endmodule

/*
:name: test_vpi_user_h_object_type_constants
:description: the object type constants of vpi_user.h have the values that Annex K gives them (IEEE 1800-2023 Section 36.7, K.2)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.7 K.1 K.2 38.36.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_user_h_object_type_constants.c
:expected_stdout: @test_vpi_user_h_object_type_constants.expected
*/
// IEEE 1800-2023 §36.7: a VPI application includes vpi_user.h, the normative
// header that every simulator provides (K.1). K.2 defines each of its
// constants as a fixed number, so an application compiled against one
// simulator's header passes the same numbers as another's.
//
// At the start of simulation (a cbStartOfSimulation callback, 38.36.3), the
// VPI application prints the value of each of the 90 object type constants
// in the order of K.2, only when the header defines it: a missing constant
// is a missing line, a wrong value is a different number, and a value that
// is not an integer constant in the range of int does not compile. A
// constant that K.2 defines as another constant or as an OR of constants is
// printed as the number it stands for.

module test_vpi_user_h_object_type_constants;
endmodule

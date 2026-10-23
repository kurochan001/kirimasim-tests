/*
:name: test_vpi_user_h_type_guards
:description: vpi_user.h defines its PLI integer types only when PLI_TYPES is not defined and its 64-bit types only when SVPI_TYPES is not defined, so an application's own definitions are kept (IEEE 1800-2023 Section 36.7, K.2)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.7 K.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_user_h_type_guards.c
:expected_stdout: @test_vpi_user_h_type_guards.expected
*/
// IEEE 1800-2023 §36.7: a VPI application includes vpi_user.h. In K.2 the
// typedefs of PLI_INT32, PLI_UINT32, PLI_INT16, PLI_UINT16, PLI_BYTE8 and
// PLI_UBYTE8 are guarded by PLI_TYPES, and those of PLI_INT64 and PLI_UINT64
// by SVPI_TYPES: the header defines each group, and the macro, only when the
// macro is not defined yet, as when another header has already defined them.
//
// The VPI application defines both macros itself and gives every one of these
// types another type than the header would, before it includes vpi_user.h. A
// header that defined them again would give a type two different definitions
// and would not compile. From its startup routine the application prints 1
// for each group whose types are still its own, compared at compile time (C11
// _Generic in C, decltype in C++). It calls no VPI routine, since the types
// of their parameters are not the ones a simulator expects here.

module test_vpi_user_h_type_guards;
endmodule

/*
:name: test_vpi_compatibility_h_1800v2005
:description: with VPI_COMPATIBILITY_VERSION_1800v2005 defined as 1, vpi_user.h includes vpi_compatibility.h, which maps each remapped VPI routine name to its 1800v2005 variant (IEEE 1800-2023 Section 36.12.2.1, L.2)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.12.2.1 K.2 L.1 L.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_compatibility_h_1800v2005.c
:expected_stdout: @test_vpi_compatibility_h_1800v2005.expected
*/
// IEEE 1800-2023 §36.12.2.1: an application selects a compile-based VPI
// compatibility mode by defining one VPI_COMPATIBILITY_VERSION_ macro as 1
// before it includes a VPI header. vpi_user.h includes vpi_compatibility.h
// by itself (K.2, L.1), which then defines VPI_COMPATIBILITY_H and, for
// VPI_COMPATIBILITY_VERSION_1800v2005, makes each of 14 routine names a
// macro for the routine of that mode (L.2), so that the application calls
// those variants.
//
// The VPI application defines the macro, includes vpi_user.h and prints,
// from its startup routine, whether VPI_COMPATIBILITY_H is defined and the
// name that each of the routine names expands to, made into a string by the
// preprocessor, and checks with sizeof that each remapped name is declared,
// which needs vpi_user.h to include vpi_compatibility.h before its routine
// declarations. No remapped routine is called. A header that does not
// include vpi_compatibility.h prints 0 and the routine names unchanged.

module test_vpi_compatibility_h_1800v2005;
endmodule

/*
:name: test_svdpi_h_canonical_types_and_version
:description: svdpi.h gives the implementation-independent canonical types and constants of Annex I, the two reference types as void*, the helper macros, the prototypes of the interface functions and svDpiVersion returning the 1800-2005 representation (IEEE 1800-2023 Sections H.5, H.10 and H.10.1.3)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.3.2 H.5 H.10 H.10.1.3 H.14.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_svdpi_h_canonical_types_and_version.c
:expected_stdout: @test_svdpi_h_canonical_types_and_version.expected
*/
// IEEE 1800-2023 §H.5 and H.10: svdpi.h is the one include file of the C
// layer, implementation independent, and defines the canonical representation
// of 2-state and 4-state values, the types that refer to SystemVerilog data
// objects, the helper macros and constants, and the functions that Annex I
// lists. §H.10.1.3: svScope is void*, a handle to an instance scope,
// svOpenArrayHandle is void*, a handle to an unsized array, and svDpiVersion
// returns a string that names the canonical representation, which is
// "1800-2005" for the value representation Annex I defines.
//
// The C function, called once through an import, compares types at compile
// time (C11 _Generic in C, decltype in C++) and values at run time, and prints
// one line for each group. It gives the sizes of the scalar, vector and
// reference types, the four canonical constants, the three helper macros for
// several widths, the version string, and the declaration of the interface
// functions of each part of Annex I that it names: the scope routines, the
// open-array queries, the element pointers, and the canonical bit and part
// select routines.

module test_svdpi_h_canonical_types_and_version;
  import "DPI-C" function void dpi_check_svdpi_header();

  initial dpi_check_svdpi_header();
endmodule

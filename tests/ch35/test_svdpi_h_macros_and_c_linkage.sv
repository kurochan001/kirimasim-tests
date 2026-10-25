/*
:name: test_svdpi_h_macros_and_c_linkage
:description: svdpi.h wraps its declarations in extern "C" for C++, gives DPI_DLLISPEC and DPI_DLLESPEC no expansion off Windows, keeps DPI_PROTOTYPES, XXTERN and EETERN only while it is processed, defines the scalar constants sv_0 to sv_x, and makes svScope and svOpenArrayHandle aliases of void* (IEEE 1800-2023 Section 35.3.2, I.3)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.3.2 I.3 H.10.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_svdpi_h_macros_and_c_linkage.c
:expected_stdout: @test_svdpi_h_macros_and_c_linkage.expected
*/
// IEEE 1800-2023 §35.3.2: the C layer of DPI is the one Annex I lists, and
// H.10.1 makes every implementation supply that same svdpi.h. I.3 puts the
// declarations inside extern "C" for a C++ translation unit, defines
// DPI_DLLISPEC as dllimport and DPI_DLLESPEC as dllexport only for the
// Microsoft and Cygwin tool chains and as nothing elsewhere, defines
// DPI_EXTERN and then XXTERN and EETERN from it and the two DLL macros under
// DPI_PROTOTYPES, gives sv_0, sv_1, sv_z and sv_x the values 0, 1, 2 and 3,
// and declares svScope and svOpenArrayHandle as aliases of void*.
//
// The C file, called once through an import, prints 1 for each check that
// holds. It asks the preprocessor whether the macros exist before, during and
// after the header, turns DPI_DLLISPEC and DPI_DLLESPEC into strings to see
// that they add nothing on this non-Windows platform, and compares sv_0 to
// sv_x and the two handle types with the values and types I.3 gives them
// (C11 _Generic in C, decltype in C++). The last line is printed after a
// block that declares three of the header's routines again inside extern "C":
// a header that did not give them C linkage would make that a conflicting
// declaration and this file would not compile.
//
// I.3 gives the two DLL macros a value only for the Microsoft, MinGW and
// Cygwin tool chains, and the empty expansion elsewhere, which is the branch
// this test builds.

module test_svdpi_h_macros_and_c_linkage;
  import "DPI-C" function void dpi_check_macros();

  initial dpi_check_macros();
endmodule

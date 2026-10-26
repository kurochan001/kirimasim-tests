/*
:name: test_svdpi_names_and_signed_bits_macro
:description: svdpi.h names its functions and types with the sv prefix and initial capitals, its constants with sv_ and its macros with SV_, and SV_GET_SIGNED_BITS sign-extends the low N bits for N other than 32 and returns the value unchanged for N equal to 32 (IEEE 1800-2023 Sections H.3 and H.10, H.10.1.2)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.3.2 H.3 H.10 H.10.1.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_svdpi_names_and_signed_bits_macro.c
:expected_stdout: @test_svdpi_names_and_signed_bits_macro.expected
*/
// IEEE 1800-2023 H.3: the interface uses the prefix sv for functions and
// types, written sv followed by words that start with a capital letter and
// have no separator, sv_ for symbolic constants and SV_ for macros in capital
// letters separated by underscores. H.10: svdpi.h is the one
// implementation-independent include file and defines those types, constants
// and macros. H.10.1.2: SV_MASK(N) has the N low bits set,
// SV_GET_UNSIGNED_BITS(VALUE, N) masks the value unless N is 32, and
// SV_GET_SIGNED_BITS(VALUE, N) tests bit N of VALUE and, when it is set,
// fills the upper bits with ones; for N equal to 32 it returns VALUE.
//
// The C function names the types svBit, svLogic, svScope and
// svOpenArrayHandle, the function svGetScope, the constants sv_0, sv_1, sv_z
// and sv_x, and the macros SV_PACKED_DATA_NELEMS, SV_MASK,
// SV_GET_UNSIGNED_BITS and SV_GET_SIGNED_BITS, all through svdpi.h. It prints
// the results of the macro for 8, 12 and 32 bits: 127, the unsigned word
// with the low 12 bits set, and the unchanged 32-bit value.

`timescale 1ns/1ns

module test_svdpi_names_and_signed_bits_macro;
  import "DPI-C" function void dpi_names();

  initial dpi_names();
endmodule

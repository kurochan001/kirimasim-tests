/*
:name: test_svdpi_h_declarations
:description: svdpi.h has the include guard, macros, scalar values, types and routine declarations that Annex I gives, and svDpiVersion returns one of its two version strings (IEEE 1800-2023 Section 35.3.2, H.10.1, I.3)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.3.2 H.10.1 I.2 I.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_svdpi_h_declarations.c
:expected_stdout: @test_svdpi_h_declarations.expected
*/
// IEEE 1800-2023 §35.3.2: the C layer of DPI is defined in Annex H, whose
// H.10.1 makes every simulator use the same svdpi.h, the one listed in I.3.
// I.3 fixes its include guard INCLUDED_SVDPI, the macros it removes at its
// end, the scalar values sv_0 to sv_x, the types svScalar, svBit, svLogic,
// svBitVecVal, svLogicVecVal, s_vpi_vecval and s_vpi_time and their fields,
// the macros SV_PACKED_DATA_NELEMS and SV_GET_UNSIGNED_BITS, the time
// constants and their sv_ names, and the declaration of every routine of the
// non-deprecated part; I.2 says that uint8_t and uint32_t come with it.
// svDpiVersion returns "1800-2005" or "SV3.1a".
//
// The C function, called once through an import, prints 1 for each check
// that holds: a type compared at compile time (C11 _Generic in C, decltype
// in C++) with the type I.3 gives, a field order compared with offsetof, a
// macro tested with #ifdef right after the header, the value of a macro for
// a few arguments, and the string svDpiVersion returns. A difference prints
// 0. The deprecated part of the header, which an implementation may leave
// out, is not checked, and SV_MASK is checked by test_svdpi_h_sv_mask.

module test_svdpi_h_declarations;
  import "DPI-C" function void dpi_check_svdpi();

  initial dpi_check_svdpi();
endmodule

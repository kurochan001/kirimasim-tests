/*
:name: test_svdpi_h_after_vpi_user_h
:description: after vpi_user.h, svdpi.h does not define t_vpi_time, t_vpi_vecval and the time constants again, because VPI_TIME and VPI_VECVAL are defined, and its svTimeVal and svLogicVecVal are the structures of vpi_user.h (IEEE 1800-2023 Section 35.3.2, I.3)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.3.2 I.3 K.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_svdpi_h_after_vpi_user_h.c
:expected_stdout: @test_svdpi_h_after_vpi_user_h.expected
*/
// IEEE 1800-2023 §35.3.2: the C layer of DPI uses svdpi.h, listed in I.3,
// which C code can include together with vpi_user.h (K.2). Both headers
// define struct t_vpi_vecval, guarded by VPI_VECVAL, and struct t_vpi_time
// with vpiScaledRealTime, vpiSimTime and vpiSuppressTime, guarded by
// VPI_TIME: the one included second sees the macro and leaves them out.
//
// The C file includes vpi_user.h and then svdpi.h. If svdpi.h defined either
// structure again, the file would not compile. The C function, called once
// through an import, prints 1 when svdpi.h's svTimeVal and svLogicVecVal are
// the structures that vpi_user.h defined, compared at compile time (C11
// _Generic in C, decltype in C++), and when the time constants have the
// values both headers give them.

module test_svdpi_h_after_vpi_user_h;
  import "DPI-C" function void dpi_check_after_vpi_user();

  initial dpi_check_after_vpi_user();
endmodule

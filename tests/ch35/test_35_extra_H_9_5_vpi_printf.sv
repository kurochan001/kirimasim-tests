/*
:name: test_35_extra_H_9_5_vpi_printf
:description: A noncontext import calls vpi_printf and vpi_flush, which are in the H.9.5 set of VPI routines that do not need DPI context, and the text reaches standard output (IEEE 1800-2023 Section H.9.5)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.3.2 H.9.5 H.6.5 35.5.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_35_extra_H_9_5_vpi_printf.c
:vpi_c: @test_35_extra_H_9_5_vpi_printf_vpi.c
:expected_stdout_verilator: @test_35_extra_H_9_5_vpi_printf.expected
*/
// IEEE 1800-2023 §H.9.5: VPI calls from an imported subroutine need DPI
// context, except for vpi_printf, vpi_vprintf and vpi_flush, the mcd_*
// routines, and the get_vlog_info routines, which do not access the model.
// The import below is not declared context and calls vpi_printf and
// vpi_flush; the text must still reach standard output. The model is built
// with VPI enabled, which 35.5.3 says is the implementation-defined way to
// make that interface available.
module test_35_extra_H_9_5_vpi_printf;
  import "DPI-C" function void c_vpi_printf();

  initial c_vpi_printf();
endmodule

/*
:name: test_dpi_vpi_systf_handle_in_import
:description: A context import can scan the top-level modules and read a variable through VPI without an error, but it is not a system task, so asking VPI for the system task call that it runs in is an error that vpi_chk_error reports (IEEE 1800-2023 Section H.9.5)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.3 H.9.5 38.2
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_vpi_systf_handle_in_import.c
:vpi_c: @test_dpi_vpi_systf_handle_in_import_vpi.c
:expected_stdout: @test_dpi_vpi_systf_handle_in_import.expected
*/
// IEEE 1800-2023 §35.5.3: a context import may read and write SystemVerilog
// data through VPI, once VPI is enabled by the tool's own means. §H.9.5:
// scanning the top-level modules with vpi_iterate(vpiModule, NULL) works
// from a context import, but an import is not a system task, so the call
// vpi_handle(vpiSysTfCall, NULL) made inside it is an error. §38.2:
// vpi_chk_error returns 0 when the previous VPI call succeeded and an error
// level, which is nonzero, when it failed.
//
// The context import c_probe checks three steps with vpi_chk_error.
// vpi_iterate(vpiModule, NULL) finds this module, the only
// top-level module, by its name. vpi_handle_by_name and vpi_get_value read
// the variable marker, which holds 42. vpi_handle(vpiSysTfCall, NULL) is
// then an error. The level of that error and the handle that the call
// returns are not fixed by the standard, so the C code passes back only
// whether vpi_chk_error gave 0. A tool that reported an error for every VPI
// call from an import would print 1 on the first two lines, and one that
// treated the import as a system task would print 0 on the last.
//
// The file test_dpi_vpi_systf_handle_in_import_vpi.c is empty; it is named
// in :vpi_c: so that tools/run_verilator.py builds the model with VPI.
// Icarus Verilog 13.0 has no DPI.

module test_dpi_vpi_systf_handle_in_import;
  int marker = 42;

  import "DPI-C" context function void c_probe(output int modules, output int iterate_error,
                                               output int marker_value, output int marker_error,
                                               output int systf_error);
  import "DPI-C" function string c_first_module();

  initial begin
    int modules, iterate_error, marker_value, marker_error, systf_error;
    c_probe(modules, iterate_error, marker_value, marker_error, systf_error);
    $display("vpi_iterate(vpiModule, NULL): %0d top-level module, %s, error %0d",
             modules, c_first_module(), iterate_error);
    $display("vpi_handle_by_name of marker and vpi_get_value: %0d, error %0d",
             marker_value, marker_error);
    $display("vpi_handle(vpiSysTfCall, NULL): error %0d", systf_error);
  end
endmodule

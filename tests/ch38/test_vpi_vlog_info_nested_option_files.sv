/*
:name: test_vpi_vlog_info_nested_option_files
:description: VPI reports parsed arrays for nested option files whose options both take effect in the design
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.17
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:args: +outside=31
:files: vlog_nested_files/outer.f vlog_nested_files/inner.f vlog_nested_files/nested.expected
:vpi_c: @test_vpi_vlog_info_nested_option_files.c
:expected_stdout: @test_vpi_vlog_info_nested_option_files.expected
*/
// The regular run is the control without an option file. Use
// tools/run_vpi_vlog_option_files.py to supply this design through the
// inner file only and check the nested representation in vpi_get_vlog_info.
`timescale 1ns/1ns
`ifndef VT_FROM_OUTER
  `define VT_FROM_OUTER 0
`endif
`ifndef VT_FROM_INNER
  `define VT_FROM_INNER 0
`endif

module test_vpi_vlog_info_nested_option_files;
  initial begin
    int supplied;
    if (!$value$plusargs("outside=%d", supplied))
      supplied = -1;
    $display("applied=%0d,%0d,%0d", `VT_FROM_OUTER, `VT_FROM_INNER, supplied);
  end
endmodule

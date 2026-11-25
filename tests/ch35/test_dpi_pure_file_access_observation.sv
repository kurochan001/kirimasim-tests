/*
:name: test_dpi_pure_file_access_observation
:description: Direct and indirect file operations require ordinary DPI imports
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_dpi_pure_file_access_observation
:dpi_c: @test_dpi_pure_file_access_observation.c
:expected_stdout: @test_dpi_pure_file_access_observation.expected
*/
`timescale 1ns/1ns
module test_dpi_pure_file_access_observation;
`ifdef PROBE_DIRECT
  import "DPI-C" pure function int dpi_file_direct(input int seed);
`else
  import "DPI-C" function int dpi_file_direct(input int seed);
`endif
`ifdef PROBE_INDIRECT
  import "DPI-C" pure function int dpi_file_indirect(input int seed);
`else
  import "DPI-C" function int dpi_file_indirect(input int seed);
`endif
  int a, b, c, d;
  initial begin
    $display("file probes entered");
`ifdef PROBE_DIRECT
    $display("direct declared pure");
`elsif PROBE_INDIRECT
    $display("indirect declared pure");
`endif
    a = dpi_file_direct(18);
    b = dpi_file_direct(18);
    c = dpi_file_indirect(36);
    d = dpi_file_indirect(36);
    $display("direct=%0d,%0d indirect=%0d,%0d", a, b, c, d);
    $finish(0);
  end
endmodule

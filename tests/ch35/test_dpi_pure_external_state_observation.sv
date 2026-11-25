/*
:name: test_dpi_pure_external_state_observation
:description: External state access requires ordinary DPI imports
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_dpi_pure_external_state_observation
:dpi_c: @test_dpi_pure_external_state_observation.c
:expected_stdout: @test_dpi_pure_external_state_observation.expected
*/
`timescale 1ns/1ns
module test_dpi_pure_external_state_observation;
`ifdef PROBE_DIRECT
  import "DPI-C" pure function int dpi_env_pid(input int seed);
`else
  import "DPI-C" function int dpi_env_pid(input int seed);
`endif
`ifdef PROBE_INDIRECT
  import "DPI-C" pure function int dpi_shared_socket(input int seed);
`else
  import "DPI-C" function int dpi_shared_socket(input int seed);
`endif
  int a, b, c, d;
  initial begin
    $display("external probes entered");
`ifdef PROBE_DIRECT
    $display("direct declared pure");
`elsif PROBE_INDIRECT
    $display("indirect declared pure");
`endif
    a = dpi_env_pid(18);
    b = dpi_env_pid(18);
    c = dpi_shared_socket(36);
    d = dpi_shared_socket(36);
    $display("env=%0d,%0d shared=%0d,%0d", a, b, c, d);
    $finish(0);
  end
endmodule

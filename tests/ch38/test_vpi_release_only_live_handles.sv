/*
:name: test_vpi_release_only_live_handles
:description: Release a live iterator and retain an unrelated net handle until the end of simulation
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.38 37.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_vpi_release_only_live_handles
:vpi_c: @test_vpi_release_only_live_handles.c
:expected_stdout: @test_vpi_release_only_live_handles.expected
*/
`timescale 1ns/1ns

module live_handle_child;
endmodule

module test_vpi_release_only_live_handles;
  reg [3:0] value = 1;
  wire [3:0] bus = value;
  live_handle_child a(), b();

  initial begin
    #1 value = 13;
    #1 $display("hdl bus=%0d", bus);
  end
endmodule

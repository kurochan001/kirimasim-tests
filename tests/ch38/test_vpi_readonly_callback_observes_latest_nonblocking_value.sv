/*
:name: test_vpi_readonly_callback_observes_latest_nonblocking_value
:description: A read only synchronization callback reads the value after two nonblocking updates in the same timestep
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.36.2 4.4.2.9
:oracle: spec iverilog@13.0 verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_readonly_callback_observes_latest_nonblocking_value.expected
:vpi_c: @test_vpi_readonly_callback_observes_latest_nonblocking_value.c
*/
`timescale 1ns/1ns
module test_vpi_readonly_callback_observes_latest_nonblocking_value;
  logic [7:0] sample = 0;

  initial begin
    #2;
    sample <= 8'd11;
    sample <= 8'd37;
    #1 $display("after=%0d", sample);
  end
endmodule

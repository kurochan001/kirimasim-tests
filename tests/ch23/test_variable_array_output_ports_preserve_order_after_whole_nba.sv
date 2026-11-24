/*
:name: test_variable_array_output_ports_preserve_order_after_whole_nba
:description: A whole nonblocking write to a variable array port propagates in element order to both orientations
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.3.2 7.6 10.4.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: variable_array_output_order.sv
:expected_stdout: @test_variable_array_output_ports_preserve_order_after_whole_nba.expected
*/
`timescale 1ns/1ns
module test_variable_array_output_ports_preserve_order_after_whole_nba;
  variable_array_harness #(1) dut();
endmodule

/*
:name: test_vpi_clocked_sequence_body
:description: The VPI sequence expression of each clocked sequence identifies the body associated with that clock
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.56 37.3.1 16.13.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_clocked_sequence_body.c
:expected_stdout: @test_vpi_clocked_sequence_body.expected
*/
// IEEE 1800-2023 37.56 models each segment's clocking event and body as
// separate one-to-one relations. Distinct clock edges, operand names and
// operations expose a swapped body or an event returned in its place.
`timescale 1ns/1ns
module test_vpi_clocked_sequence_body;
  logic clk_a, clk_b;
  logic data_a, enable_a, data_b, enable_b;

  sequence transfer;
    @(posedge clk_a) (data_a && enable_a) ##1 @(negedge clk_b) (data_b || enable_b);
  endsequence

  initial #1 $finish;
endmodule

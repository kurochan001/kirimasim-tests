/*
:name: test_checker_packed_rand_becomes_inactive_on_bit_assignment
:description: Assigning one bit of a packed free checker value makes the entire value inactive
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.7.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_checker_packed_rand_becomes_inactive_on_bit_assignment.expected
*/
`timescale 1ns/1ns
checker packed_free(input bit clock, output bit [3:0] observed);
  rand bit [3:0] flags = 4'b1010;

  // An assignment to one bit classifies the entire packed variable as
  // inactive. The other bits therefore retain their initialized values.
  always_ff @(posedge clock) flags[0] <= !flags[0];
  assign observed = flags;
endchecker

module test_checker_packed_rand_becomes_inactive_on_bit_assignment;
  bit clock;
  wire [3:0] observed;
  packed_free u(clock, observed);

  initial begin
    #1 $display("before=%b", observed);
    #1 clock = 1;
    #1 $display("first=%b", observed);
    #1 clock = 0;
    #1 clock = 1;
    #1 $display("second=%b", observed);
  end
endmodule

/*
:name: test_checker_free_variables_assigned
:description: A free checker variable that is assigned in an always_ff procedure is not randomized, so with an initial value it toggles deterministically, and an initialized constant free variable keeps its initial value (IEEE 1800-2023 Section 17.7)
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.7 17.7.1 17.7.2 17.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_checker_free_variables_assigned.expected
*/
// IEEE 1800-2023 §17.7: a checker variable declared rand is a free variable,
// and one declared rand const with an initial value keeps that value, so k
// stays 9. §17.7.1, §17.7.2: a free variable on the left-hand side of an
// assignment is inactive, so it is not randomized; t starts at its initial
// value 0 and the always_ff procedure inverts it at each rising clock. The
// outputs pass t and k to the module (17.3), which prints them at the
// falling clock.

checker toggler (event clk, output bit t_out, output bit [3:0] k_out);
  rand bit t = 1'b0;
  rand const bit [3:0] k = 4'd9;
  always_ff @clk t <= !t;
  assign t_out = t;
  assign k_out = k;
endchecker

module test_checker_free_variables_assigned;
  logic clk = 0;
  bit t;
  bit [3:0] k;

  always #5 clk = ~clk;

  toggler u (posedge clk, t, k);

  initial begin
    repeat (4) @(negedge clk) $display("t=%0d: t=%b k=%0d", $time, t, k);
    $finish;
  end
endmodule

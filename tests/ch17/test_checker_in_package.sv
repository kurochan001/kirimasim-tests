/*
:name: test_checker_in_package
:description: A checker declared in a package, with a function in its body, is instantiated by its package-qualified name and checks its assertion at each clock tick (IEEE 1800-2023 Section 17.2)
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.2 17.3 17.8 16.9.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_checker_in_package.expected
*/
// IEEE 1800-2023 §17.2: a checker may be declared in a package, and §17.3:
// an instance names it with the package scope. §17.8: the checker declares a
// function in its body and calls it in its assertion. The assertion requires
// exactly one bit of v to be 1 at each rising clock; v changes at the falling
// clock, and the action shows the sampled value (16.9.3) of the failing ticks
// at 15 and 35.

package chk_pkg;
  checker onehot_chk (logic [3:0] v, event clk);
    function automatic int ones(logic [3:0] x);
      return $countones(x);
    endfunction
    a1: assert property (@clk ones(v) == 1)
      else $display("t=%0d: %b is not one-hot", $time, $sampled(v));
  endchecker
endpackage

module test_checker_in_package;
  logic clk = 0;
  logic [3:0] v = 4'b0001;

  always #5 clk = ~clk;

  chk_pkg::onehot_chk c (v, posedge clk);

  initial begin
    #10 v = 4'b0011;
    #10 v = 4'b0100;
    #10 v = 4'b0000;
    #10 $finish;
  end
endmodule

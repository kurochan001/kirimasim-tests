/*
:name: test_checker_final_once
:description: each checker instance runs its final procedure once at the end of the simulation, whatever its instance context, and the final procedure may use the constructs that a non-checker final procedure allows (IEEE 1800-2023 Section 17.5)
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_checker_final_once.expected
*/
// IEEE 1800-2023 17.5: a final procedure of a checker runs once for each
// instance at the end of the simulation, independently of the context of the
// instance, and it may contain what a final procedure outside a checker may
// contain. One instance is written in the module and one in a generate block;
// each counts the three rising edges of clk in its own variable n. The final
// procedure declares a variable, adds 0 to n-1 in a for loop and prints only
// when the sum is the value 3 that the loop gives for n = 3. Both instances
// have the same value, so the two lines are identical and their order does
// not matter. A final procedure that ran twice or not at all changes the
// number of lines.

`timescale 1ns/1ns

checker final_once(logic clk);
  int n = 0;
  always_ff @(posedge clk) n <= n + 1'b1;
  final begin
    int sum;
    sum = 0;
    for (int i = 0; i < n; i++)
      sum = sum + i;
    if (sum == 3)
      $display("final_once n=%0d sum=%0d", n, sum);
  end
endchecker : final_once

module test_checker_final_once;
  logic clk = 1'b0;

  always #5 clk = ~clk;      // rising edges at 5, 15 and 25

  final_once c_direct(clk);

  for (genvar g = 0; g < 1; g++) begin : gen
    final_once c_generate(clk);
  end

  initial #30 $finish;
endmodule

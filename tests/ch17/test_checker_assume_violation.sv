/*
:name: test_checker_assume_violation
:description: Two checker assumptions that reference the same active free variable form one assume set with two clock events, and each is checked and reported at its own clock event (IEEE 1800-2023 Section 17.7.2)
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.7.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_checker_assume_violation.expected
*/
// IEEE 1800-2023 17.7.2: checker assume statements may be used by a simulator
// to constrain the random generation of free checker variable values, and they
// shall also be checked for violation during simulation (16.14.2). Solving is
// triggered by any of the clock events of the properties in the assume set, not
// by a procedural call. The two assumptions below both reference the free
// variable f, so both belong to the one assume set of the instance, and their
// properties are clocked by the two different clocks. Neither property can hold
// for any value of f, so no value of the active variable avoids the failure in
// a time step, and each failure appears in the Observed region of the time step
// of its own clock event: 5, 15 and 25 for clk_a, and 6, 18 and 30 for clk_b.
// The two clocks have no edge in a common time step.

`timescale 1ns/1ns

checker assume_unsat(input logic clk_a, input logic clk_b,
                     output int n_a, output int n_b);
  rand bit f;      // active: it is never assigned in the checker

  u_a: assume property (@(posedge clk_a) f == 1'b0 && f == 1'b1)
    else begin
      n_a = n_a + 1;
      $display("clk_a violation at %0d", $time);
    end

  u_b: assume property (@(posedge clk_b) f == 1'b0 && f == 1'b1)
    else begin
      n_b = n_b + 1;
      $display("clk_b violation at %0d", $time);
    end
endchecker : assume_unsat

module test_checker_assume_violation;
  logic clk_a = 1'b0, clk_b = 1'b0;
  int n_a, n_b;

  always #5 clk_a = ~clk_a;    // rising edges at 5, 15, 25
  always #6 clk_b = ~clk_b;    // rising edges at 6, 18, 30

  assume_unsat u(.clk_a(clk_a), .clk_b(clk_b), .n_a(n_a), .n_b(n_b));

  initial begin
    #31 $display("violations: clk_a=%0d clk_b=%0d", n_a, n_b);
    $finish;
  end
endmodule

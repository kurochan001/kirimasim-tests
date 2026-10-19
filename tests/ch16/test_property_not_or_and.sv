/*
:name: test_property_not_or_and
:description: not p is true when p is false, p1 or p2 when at least one of them is true and p1 and p2 when both are, each operand evaluated from the same start (IEEE 1800-2023 Sections 16.12.3, 16.12.4, 16.12.5)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.12.3 16.12.4 16.12.5 16.12.2 16.12.7 16.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_property_not_or_and.expected
*/
// IEEE 1800-2023 §16.12.3: not p evaluates to the opposite of p; here p is the
// sequence go ##1 p1, weak in an assertion (§16.12.2), so not fails when the
// sequence matches. §16.12.4: p1 or p2 is true if at least one is true.
// §16.12.5: p1 and p2 is true if both are. The operands are implications
// (§16.12.7) started at the same tick, so with go at T the or needs p1 or q
// at T+1, and the and needs p1 at T+1 and q at T+2. The fail actions count the
// failures of each phase (§16.14.1).

`timescale 1ns/1ns

module test_property_not_or_and;
  logic clk = 0, go = 0, p1 = 0, q = 0;
  int f_not = 0, f_or = 0, f_and = 0;

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  a_not: assert property (@(posedge clk) not (go ##1 p1)) else f_not++;
  a_or: assert property (@(posedge clk) (go |=> p1) or (go |=> q)) else f_or++;
  a_and: assert property (@(posedge clk) (go |=> p1) and (go |=> ##1 q)) else f_and++;

  // Runs one phase: go at T, then p1 and q at T+1 and T+2.
  task automatic phase(string name, logic p_1, logic q_1, logic p_2, logic q_2);
    go = 1; p1 = 0; q = 0; #10;
    go = 0; p1 = p_1; q = q_1; #10;
    p1 = p_2; q = q_2; #10;
    p1 = 0; q = 0; #20;
    $display("%s: not %0d, or %0d, and %0d", name, f_not, f_or, f_and);
    f_not = 0;
    f_or = 0;
    f_and = 0;
  endtask

  initial begin
    phase("p1 at T+1, q at T+2", 1, 0, 0, 1);
    phase("q at T+1", 0, 1, 0, 0);
    phase("p1 at T+1 only", 1, 0, 0, 0);
    phase("neither", 0, 0, 0, 0);
    $finish;
  end
endmodule

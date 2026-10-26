/*
:name: test_checker_procedural_deferred_assertion
:description: The static assertions of a checker instantiated in procedural code are queued only when the instance is reached, the concurrent one maturing in the Observed region and the deferred one at the end of the time step (IEEE 1800-2023 Section 17.3)
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.3 16.4.1 16.14.6.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_checker_procedural_deferred_assertion.expected
*/
// IEEE 1800-2023 §17.3: the static assertions of a checker instantiated inside
// procedural code are treated as if they were instantiated at the
// instantiation point. A static deferred assertion is added to the pending
// deferred assertion report when the process reaches the instance and matures
// at the end of that time step (16.4.1), unlike a static instance whose
// assertion is monitored whenever its expression changes. The checker holds
// only a deferred assertion that fails when b is 0. The always procedure
// instantiates it only while en is 1 and then prints the failure count in the
// Active region, before the deferred action runs. At t=5 the instance is
// reached with b=0, so the print shows 0 and the action makes it 1 before the
// next clock. The edge at 15 is not reached, and the edge at 25 is reached
// with b=1, so the count stays 1. Icarus Verilog 13.0 has no checkers and
// release 5.052 of Verilator does not support deferred assertions here, so
// expected output follows the clauses alone.

`timescale 1ns/1ns

checker cb_deferred (logic clk, logic b, output int fails, output int cfails);
  int f = 0;
  int c = 0;
  a1: assert #0 (b) else f = f + 1;
  a2: assert property (@(posedge clk) b) else c = c + 1;
  assign fails = f;
  assign cfails = c;
endchecker : cb_deferred

module test_checker_procedural_deferred_assertion;
  logic clk = 1'b0;
  logic en = 1'b1;
  logic b = 1'b0;
  int fails, cfails;

  always #5 clk = ~clk;

  always @(posedge clk) begin
    if (en) cb_deferred u_cb (clk, b, fails, cfails);
    $display("t=%0d active fails=%0d", $time, fails);
  end

  initial begin
    #8 en = 1'b0;
    #10 b = 1'b1; en = 1'b1;   // 18
    #8 en = 1'b0;              // 26
    #14 $display("final fails=%0d cfails=%0d", fails, cfails);
    $finish;
  end
endmodule

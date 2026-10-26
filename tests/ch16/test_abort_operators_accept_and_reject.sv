/*
:name: test_abort_operators_accept_and_reject
:description: accept_on and sync_accept_on turn a failing property into a pass and reject_on and sync_reject_on turn a passing property into a failure, each taking a parenthesized expression and then a property expression, and the asynchronous and synchronous forms both act at a clocking event (IEEE 1800-2023 Section 16.12.14, A.2.10)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.12.14 A.2.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_abort_operators_accept_and_reject.expected
*/
// IEEE 1800-2023 A.2.10: accept_on ( expression_or_dist ) property_expr,
// reject_on ( expression_or_dist ) property_expr, sync_accept_on (...)
// property_expr and sync_reject_on (...) property_expr each take a
// parenthesized expression and then a property expression. §16.12.14 gives
// their meaning: an accept_on property is accepted when its condition holds
// during the evaluation, and a reject_on property is rejected when its
// condition holds; the sync forms look at the condition at the clocking
// events.
//
// a_acc has the condition 1 and the property 0, so it is accepted at every
// tick and its fail action never runs. a_sacc is the same with the
// synchronous form. a_rej has the property 1 and the condition cyc == 0,
// true only at the first clock tick, time 5, so it is rejected once and
// prints its time. a_srej has property 1 and condition 1, so it is rejected
// at each of the two clock ticks, 5 and 15. The counts 0, 1, 0 and 2 show
// each operator's effect; ignoring accept_on would make acc and sacc 2, and
// ignoring reject_on would make rej 0 and srej 0.

`timescale 1ns/1ns

module test_abort_operators_accept_and_reject;
  logic clk = 1'b0;
  int cyc = 0;
  int acc = 0, rej = 0, sacc = 0, srej = 0;

  always @(posedge clk) cyc <= cyc + 1;

  a_acc: assert property (@(posedge clk) accept_on (1'b1) (1'b0))
    else acc++;
  a_rej: assert property (@(posedge clk) reject_on (cyc == 0) (1'b1))
    else begin rej++; $display("reject fail at %0t", $time); end
  a_sacc: assert property (@(posedge clk) sync_accept_on (1'b1) (1'b0))
    else sacc++;
  a_srej: assert property (@(posedge clk) sync_reject_on (1'b1) (1'b1))
    else srej++;

  initial begin
    repeat (4) #5 clk = ~clk;
    $display("acc=%0d rej=%0d sacc=%0d srej=%0d", acc, rej, sacc, srej);
    $finish;
  end
endmodule

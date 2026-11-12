/*
:name: test_31_extra_fullskew_active_flag
:description: The remain-active flag of $fullskew accepts a constant expression, including a specparam and both constant values, in the optional position after the notifier and the event-based flag (IEEE 1800-2023 Section 31.4.3)
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.4.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_31_extra_fullskew_active_flag.expected
*/
// IEEE 1800-2023 31.4.3, Syntax 31-11 and Table 31-9: the optional arguments
// of $fullskew after the two limits are the notifier, the event_based_flag
// and the remain_active_flag, and remain_active_flag is a
// constant_mintypmax_expression. The cell below gives the flag in its two
// constant values 0 and 1, the second through the specparam raf, and leaves
// the timer-based mode selected by the event_based_flag 0.
// 31.4.3: in the timer-based mode a reference or data event starts a window,
// and a violation is reported when its limit elapses without the other
// event. 31.6, Table 31-13: a violation changes a notifier from 0 to 1 and
// from 1 to 0. The posedge of clk at 5 starts a window of limit 2; clkn has
// no negedge by 7, so both checks report there. The negedge of clkn at 10
// starts a window of limit 3; clk has no posedge by 13, so both report
// again. Each notifier changes twice and reads 0 at 20.
// clkn starts at 1. If it started at 0, the input net of the cell would go
// from x to 0 at time zero, which 31.5 names as a negedge, and the result
// would depend on whether that change is a data event. The initial values
// 0 of clk and 1 of clkn give no posedge of clk and no negedge of clkn
// before 5. Only clk changes at 5 and only clkn at 10, so no two
// signals of a check change in the same time step.
// A simulator that does not run the timing check also prints 00; the test
// shows that the design with these flags builds and runs, which is what the
// requirement asks. A design in which the flag is not a constant expression
// is rejected by the rule; that direction is not exercised because this
// requirement is a normal case and the test must be a legal design.

`timescale 1ns/1ns

module tfa_cell(input wire clk, input wire clkn, input wire en);
  reg n0 = 0, n1 = 0;

  specify
    specparam raf = 1;
    $fullskew(posedge clk, negedge clkn, 2, 3, n0, 0, 0);
    $fullskew(posedge clk &&& en, negedge clkn, 2, 3, n1, 0, raf);
  endspecify
endmodule

module test_31_extra_fullskew_active_flag;
  reg clk = 0, clkn = 1, en = 1;
  tfa_cell u(clk, clkn, en);

  initial begin
    #5 clk = 1; clkn = 1;
    #5 clkn = 0;
    #5 en = 0;
    #5 $display("t=%0d n=%b%b", $time, u.n0, u.n1);
    $finish;
  end
endmodule

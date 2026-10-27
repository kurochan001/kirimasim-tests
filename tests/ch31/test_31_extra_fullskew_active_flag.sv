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
// the timer-based mode selected by the event_based_flag 0. The design builds
// and runs; the notifiers stay 0 because neither simulator calls the check.
// A design in which the flag is not a constant expression is rejected by the
// rule; that direction is not exercised because this requirement is a normal
// case and the test must be a legal design.

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
  reg clk = 0, clkn = 0, en = 1;
  tfa_cell u(clk, clkn, en);

  initial begin
    #5 clk = 1; clkn = 1;
    #5 clk = 0; clkn = 0;
    #5 en = 0;
    #5 $display("t=%0d n=%b%b", $time, u.n0, u.n1);
    $finish;
  end
endmodule

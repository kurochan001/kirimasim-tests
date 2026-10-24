/*
:name: test_timing_setuphold_as_setup_and_hold
:description: With limits that are not negative, $setuphold reports the same violations as a $setup and a $hold with the same limits on the same signals together, including a data change at the reference edge, which only $hold reports (IEEE 1800-2023 Section 31.3.3)
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.3.3 31.3.1 31.3.2 31.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timing_setuphold_as_setup_and_hold.expected
*/
// IEEE 1800-2023 §31.3.3: $setuphold(posedge clk, d, 3, 2) is equivalent to
// $setup(d, posedge clk, 3) together with $hold(posedge clk, d, 2) when the
// limits are not negative; a data event at the same time as the reference
// event is a violation of $setuphold. §31.3.1: $setup reports a d change
// strictly between 3 before an edge and the edge. §31.3.2: $hold reports a d
// change at an edge or less than 2 after it. §31.6: each violation toggles
// the notifier, which starts at 0.
//
// clk rises at 10, 20, 30, 40 and 60. d changes at 7 (exactly 3 before 10),
// 18 (2 before 20), 30 (with the edge), 32 (exactly 2 after 30), 41 (1 after
// 40), 58 (2 before 60) and 61 (1 after 60). $setup reports at the edges 20
// and 60, $hold at the changes 30, 41 and 61, and $setuphold at all five
// times, once each. The times at which each notifier changes are printed at
// the end.
//
// Icarus Verilog 13.0 skips timing checks, so the notifiers never change.

`timescale 1ns/1ns

module tsh_checks (input clk, d);
  reg n_sh = 0, n_s = 0, n_h = 0;
  specify
    $setuphold(posedge clk, d, 3, 2, n_sh);
    $setup(d, posedge clk, 3, n_s);
    $hold(posedge clk, d, 2, n_h);
  endspecify
endmodule

module test_timing_setuphold_as_setup_and_hold;
  reg clk = 0, d = 0;
  string lsh = "", ls = "", lh = "";

  tsh_checks u (clk, d);

  always @(u.n_sh) lsh = {lsh, $sformatf(" %0d", $time)};
  always @(u.n_s) ls = {ls, $sformatf(" %0d", $time)};
  always @(u.n_h) lh = {lh, $sformatf(" %0d", $time)};

  initial begin
    #7 d = 1;               // 7: exactly 3 before the edge
    #3 clk = 1;             // 10
    #5 clk = 0;
    #3 d = 0;               // 18: 2 before the edge
    #2 clk = 1;             // 20
    #5 clk = 0;
    #5 clk = 1; d = 1;      // 30: with the edge
    #2 d = 0;               // 32: exactly 2 after the edge
    #3 clk = 0;
    #5 clk = 1;             // 40
    #1 d = 1;               // 41: 1 after the edge
    #4 clk = 0;
    #13 d = 0;              // 58: 2 before the edge
    #2 clk = 1;             // 60
    #1 d = 1;               // 61: 1 after the edge
    #4 clk = 0;
    #10 $display("$setuphold:%s", lsh);
    $display("$setup:%s", ls);
    $display("$hold:%s", lh);
  end
endmodule

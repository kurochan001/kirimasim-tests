/*
:name: test_timing_setuphold_all_arguments
:description: A $setuphold with all nine arguments takes them in the order reference event, data event, setup limit, hold limit, notifier, timestamp condition, timecheck condition, delayed reference, delayed data; with positive limits the delayed signals are copies of their signals (IEEE 1800-2023 Section 31.3.3)
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.3.3 31.9.2 31.9.1 31.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timing_setuphold_all_arguments.expected
*/
// IEEE 1800-2023 §31.3.3: the arguments of $setuphold are, in this order, the
// reference event, the data event, the setup limit, the hold limit, and the
// optional notifier, timestamp condition, timecheck condition, delayed
// reference and delayed data. With positive limits a data change less than
// the setup limit before the reference edge, or at the edge or less than the
// hold limit after it, is a violation. §31.9.2: the timestamp condition goes
// with the event that comes first, the timecheck condition with the one that
// comes second, so $setuphold(posedge clk, d, 3, 5, n, es, en, dclk, dd)
// checks like $setup(d &&& es, posedge clk &&& en, 3) together with
// $hold(posedge clk &&& es, d &&& en, 5). §31.9.1: the delayed signals are
// delayed only when a limit is negative, so here dclk and dd follow clk and d
// at once. §31.6: each violation toggles the notifier.
//
// The clk edges are at 21, 40, 62, 82, 100 and 120.
//   d at 17, 4 before 21: no violation (it would be one if the setup limit
//     were 5).
//   d at 44, 4 after 40: violation (none if the hold limit were 3).
//   d at 60 with es = 1, then clk at 62 with en = 1: setup violation.
//   d at 80 with es = 0, then clk at 82 with en = 0: no violation.
//   clk at 100 with es = 1, then d at 102 with en = 1: hold violation.
//   clk at 120 with es = 0, then d at 122 with en = 0: no violation.
// In the last four cases the other condition has the opposite value, so the
// conditions taken in the other order give the opposite results. The
// conditions change one time unit before or after each event, never with it.
// So the notifier changes at 44, 62 and 102.
//
// Icarus Verilog 13.0 and Verilator 5.052 skip timing checks, so the notifier
// never changes.

`timescale 1ns/1ns

module tsa_cell (input clk, d, es, en);
  wire dclk, dd;
  reg n = 0;
  specify
    $setuphold(posedge clk, d, 3, 5, n, es, en, dclk, dd);
  endspecify
endmodule

module test_timing_setuphold_all_arguments;
  reg clk = 0, d = 0, es = 1, en = 1;
  string ln = "";

  tsa_cell u (clk, d, es, en);

  always @(u.n) ln = {ln, $sformatf(" %0d", $time)};

  task show;
    $display("%0d: clk=%b dclk=%b d=%b dd=%b", $time, clk, u.dclk, d, u.dd);
  endtask

  initial begin
    #17 d = 1;              // 17: 4 before the edge
    #4 clk = 1;             // 21
    #4 clk = 0;
    #5 show;                // 30
    #10 clk = 1;            // 40
    #4 d = 0;               // 44: 4 after the edge
    #1 clk = 0;
    #13 en = 0;             // 58: es = 1, en = 0
    #2 d = 1;               // 60
    #1 es = 0; en = 1;      // 61
    #1 clk = 1;             // 62
    #4 clk = 0;
    #14 d = 0;              // 80: es = 0, en = 1
    #1 es = 1; en = 0;      // 81
    #1 clk = 1;             // 82
    #2 show;                // 84
    #2 clk = 0;
    #14 clk = 1;            // 100: es = 1, en = 0
    #1 es = 0; en = 1;      // 101
    #1 d = 1;               // 102
    #3 clk = 0;
    #15 clk = 1;            // 120: es = 0, en = 1
    #1 es = 1; en = 0;      // 121
    #1 d = 0;               // 122
    #3 clk = 0;
    #10 $display("notifier:%s", ln);
  end
endmodule

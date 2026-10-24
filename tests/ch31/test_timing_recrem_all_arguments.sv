/*
:name: test_timing_recrem_all_arguments
:description: A $recrem with all nine arguments takes them in the order reference event, data event, recovery limit, removal limit, notifier, timestamp condition, timecheck condition, delayed reference, delayed data; with positive limits the delayed signals are copies of their signals (IEEE 1800-2023 Section 31.3.6)
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.3.6 31.9.2 31.9.1 31.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timing_recrem_all_arguments.expected
*/
// IEEE 1800-2023 §31.3.6: the arguments of $recrem are, in this order, the
// reference event, the data event, the recovery limit, the removal limit, and
// the optional notifier, timestamp condition, timecheck condition, delayed
// reference and delayed data. With positive limits a data event at the
// reference event or less than the recovery limit after it, or a data event
// less than the removal limit before the reference event, is a violation.
// §31.9.2 (which applies to $recrem as to $setuphold, 31.9): the timestamp
// condition goes with the event that comes first and the timecheck condition
// with the one that comes second, so
// $recrem(posedge rst_n, posedge clk, 3, 5, n, cs, cc, drst, dclk) checks like
// $recovery(posedge rst_n &&& cs, posedge clk &&& cc, 3) together with
// $removal(posedge rst_n &&& cc, posedge clk &&& cs, 5). §31.9.1: the delayed
// signals are delayed only when a limit is negative, so here drst and dclk
// follow rst_n and clk at once. §31.6: each violation toggles the notifier.
//
// rst_n rises at 20, 44, 60, 80, 102 and 122 and falls 10 later or less.
//   clk at 24, 4 after rst_n at 20: no violation (it would be one if the
//     recovery limit were 5).
//   clk at 40, 4 before rst_n at 44: violation (none if the removal limit
//     were 3).
//   rst_n at 60 with cs = 1, then clk at 62 with cc = 1: recovery violation.
//   rst_n at 80 with cs = 0, then clk at 82 with cc = 0: no violation.
//   clk at 100 with cs = 1, then rst_n at 102 with cc = 1: removal violation.
//   clk at 120 with cs = 0, then rst_n at 122 with cc = 0: no violation.
// In the last four cases the other condition has the opposite value, so the
// conditions taken in the other order give the opposite results. The
// conditions change one time unit before or after each event, never with it.
// So the notifier changes at 44, 62 and 102.
//
// Icarus Verilog 13.0 and Verilator 5.052 skip timing checks, so the notifier
// never changes; the latter also leaves drst and dclk undriven.

`timescale 1ns/1ns

module tra_cell (input clk, rst_n, cs, cc);
  wire drst, dclk;
  reg n = 0;
  specify
    $recrem(posedge rst_n, posedge clk, 3, 5, n, cs, cc, drst, dclk);
  endspecify
endmodule

module test_timing_recrem_all_arguments;
  reg clk = 0, rst_n = 0, cs = 1, cc = 1;
  string ln = "";

  tra_cell u (clk, rst_n, cs, cc);

  always @(u.n) ln = {ln, $sformatf(" %0d", $time)};

  task show;
    $display("%0d: rst_n=%b drst=%b clk=%b dclk=%b", $time, rst_n, u.drst, clk, u.dclk);
  endtask

  initial begin
    #20 rst_n = 1;          // 20
    #4 clk = 1;             // 24: 4 after rst_n
    #3 clk = 0;
    #3 rst_n = 0;           // 30
    #10 clk = 1;            // 40
    #2 show;                // 42
    #2 rst_n = 1;           // 44: 4 after clk
    #1 clk = 0;
    #1 show;                // 46
    #4 rst_n = 0;           // 50
    #8 cc = 0;              // 58: cs = 1, cc = 0
    #2 rst_n = 1;           // 60
    #1 cs = 0; cc = 1;      // 61
    #1 clk = 1;             // 62
    #4 clk = 0;
    #4 rst_n = 0;           // 70
    #10 rst_n = 1;          // 80: cs = 0, cc = 1
    #1 cs = 1; cc = 0;      // 81
    #1 clk = 1;             // 82
    #4 clk = 0;
    #4 rst_n = 0;           // 90
    #10 clk = 1;            // 100: cs = 1, cc = 0
    #1 cs = 0; cc = 1;      // 101
    #1 rst_n = 1;           // 102
    #3 clk = 0;
    #5 rst_n = 0;           // 110
    #10 clk = 1;            // 120: cs = 0, cc = 1
    #1 cs = 1; cc = 0;      // 121
    #1 rst_n = 1;           // 122
    #3 clk = 0;
    #10 $display("notifier:%s", ln);
  end
endmodule

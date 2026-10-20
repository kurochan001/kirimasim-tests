/*
:name: test_timing_edge_control_specifier
:description: A timing check with edge[01] on its reference signal reacts only to a change from 0 to 1, while posedge also covers the changes from 0 to x and from x to 1 (IEEE 1800-2023 Section 31.5)
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.5 31.3.1 31.6
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_timing_edge_control_specifier.expected
*/
// IEEE 1800-2023 §31.5: posedge clk stands for edge[01, 0x, x1] clk, so the
// $setup (31.3.1) with posedge takes clk going 0 to x at 10 and x to 1 at 20
// as reference events, and the data changes 2 time units before them are
// violations. The $setup with edge[01] takes only the change from 0 to 1 at
// 40. Each violation toggles its notifier (31.6); the changes of each
// notifier are recorded and printed at the end.

`timescale 1ns/1ns

module edge_checks (input clk, input d);
  reg n_01 = 0, n_pos = 0;
  specify
    $setup(d, edge[01] clk, 3, n_01);
    $setup(d, posedge clk, 3, n_pos);
  endspecify
endmodule

module test_timing_edge_control_specifier;
  reg clk = 0, d = 0;
  string log_01 = "", log_pos = "";

  edge_checks u (clk, d);

  always @(u.n_01) log_01 = {log_01, $sformatf(" %0d:%b", $time, u.n_01)};
  always @(u.n_pos) log_pos = {log_pos, $sformatf(" %0d:%b", $time, u.n_pos)};

  initial begin
    #8 d = 1;
    #2 clk = 1'bx;      // 10: 0 -> x
    #8 d = 0;
    #2 clk = 1;         // 20: x -> 1
    #10 clk = 0;        // 30
    #8 d = 1;
    #2 clk = 1;         // 40: 0 -> 1
    #10 $display("edge[01] notifier:%s", log_01);
    $display("posedge notifier:%s", log_pos);
  end
endmodule

/*
:name: test_timing_check_setup_hold_recovery_removal_skew
:description: The timing checks $setup, $hold, $recovery, $removal and $skew take their events and limit in the order of A.7.5.1, accept the notifier in the optional position after a comma, and toggle it at each violation of their windows (IEEE 1800-2023 Sections 31.3.1, 31.3.2, 31.3.4, 31.3.5, 31.4.1 and 31.6)
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.3.1 31.3.2 31.3.4 31.3.5 31.4.1 31.6 A.7.5.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timing_check_setup_hold_recovery_removal_skew.expected
*/
// IEEE 1800-2023 A.7.5.1, Syntax 31-1: $setup takes a data event, a reference
// event and a limit; $hold, $recovery, $removal and $skew take a reference
// event, a data event and a limit. Each has an optional notifier after a comma,
// which may also be left empty, and $setup also accepts the call without the
// comma and notifier. §31.3.1: $setup violates when the data changes strictly
// between the limit before the clock edge and the edge. §31.3.2: $hold violates
// when the data changes at the edge or less than the limit after it. §31.3.5:
// $recovery violates when the clock edge is less than the limit after the
// control edge. §31.3.4: $removal violates when the clock edge is strictly less
// than the limit before the control edge. §31.4.1: $skew violates when a data
// event is more than the limit after a reference event. §31.6: each violation
// toggles the notifier; the notifiers start at 0 and the test prints all of
// them at each change.
//
// The stimulus makes one violation of each check, then a second one for each,
// at times 11, 12, 15, 20, 24, 31, 40, 45, 60 and 65, so every printed line
// changes exactly one notifier.

`timescale 1ns/1ns

module tc_setup (input wire clk, input wire d);
  reg n = 1'b0;
  specify
    $setup(d, posedge clk, 3, n);
    $setup(d, posedge clk, 3);
  endspecify
endmodule

module tc_hold (input wire clk, input wire d);
  reg n = 1'b0;
  specify
    $hold(posedge clk, d, 2, n);
    $hold(posedge clk, d, 2, );
  endspecify
endmodule

module tc_recovery (input wire rst, input wire clk);
  reg n = 1'b0;
  specify
    $recovery(posedge rst, posedge clk, 3, n);
  endspecify
endmodule

module tc_removal (input wire rst, input wire clk);
  reg n = 1'b0;
  specify
    $removal(posedge rst, posedge clk, 2, n);
  endspecify
endmodule

module tc_skew (input wire clk, input wire clk2);
  reg n = 1'b0;
  specify
    $skew(posedge clk, posedge clk2, 3, n);
  endspecify
endmodule

module test_timing_check_setup_hold_recovery_removal_skew;
  reg c_s = 1'b0, d_s = 1'b0;
  reg c_h = 1'b0, d_h = 1'b0;
  reg r_rec = 1'b0, c_rec = 1'b0;
  reg r_rem = 1'b0, c_rem = 1'b0;
  reg c_k = 1'b0, c_k2 = 1'b0;

  tc_setup u_setup (c_s, d_s);
  tc_hold u_hold (c_h, d_h);
  tc_recovery u_rec (r_rec, c_rec);
  tc_removal u_rem (r_rem, c_rem);
  tc_skew u_skew (c_k, c_k2);

  always @(u_setup.n or u_hold.n or u_rec.n or u_rem.n or u_skew.n)
    if ($time > 0)
      $display("%0d: setup=%b hold=%b recovery=%b removal=%b skew=%b",
               $time, u_setup.n, u_hold.n, u_rec.n, u_rem.n, u_skew.n);

  initial begin
    #10 c_s = 1'b1;
    #2  c_s = 1'b0;
    #6  d_s = 1'b1;
    #2  c_s = 1'b1;
    #2  c_s = 1'b0;
    #2  d_s = 1'b0;
    #6  c_s = 1'b1;
    #2  c_s = 1'b0;
    #6  d_s = 1'b1;
    #2  c_s = 1'b1;
  end

  initial begin
    #10 c_h = 1'b1;
    #1  d_h = 1'b1;
    #9  c_h = 1'b0;
    #5  d_h = 1'b0;
    #5  c_h = 1'b1;
    #10 c_h = 1'b0;
    #20 c_h = 1'b1; d_h = 1'b1;
  end

  initial begin
    #13 r_rec = 1'b1;
    #2  c_rec = 1'b1;
    #3  r_rec = 1'b0;
    #2  c_rec = 1'b0;
    #43 r_rec = 1'b1;
    #2  c_rec = 1'b1;
  end

  initial begin
    #11 c_rem = 1'b1;
    #1  r_rem = 1'b1;
    #4  c_rem = 1'b0;
    #3  r_rem = 1'b0;
    #11 c_rem = 1'b1;
    #1  r_rem = 1'b1;
  end

  initial begin
    #10 c_k = 1'b1;
    #2  c_k2 = 1'b1;
    #4  c_k = 1'b0;
    #2  c_k2 = 1'b0;
    #2  c_k = 1'b1;
    #4  c_k2 = 1'b1;
    #2  c_k = 1'b0;
    #3  c_k2 = 1'b0;
    #1  c_k = 1'b1; c_k2 = 1'b1;
    #5  c_k = 1'b0;
    #1  c_k2 = 1'b0;
    #4  c_k = 1'b1;
    #5  c_k2 = 1'b1;
  end

  initial #100 $finish;
endmodule

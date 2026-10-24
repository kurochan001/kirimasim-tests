/*
:name: test_timing_check_conditions_timestamps_and_notifiers
:description: Timing checks see a conditioned reference or data event only while its condition is true, judge a violation at the timecheck event from the stored time of the timestamp event, and toggle a notifier from 0 to 1 and back while a z notifier stays z (IEEE 1800-2023 Section 31.2)
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.2 31.3.1 31.3.2 31.6
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_timing_check_conditions_timestamps_and_notifiers.expected
*/
// IEEE 1800-2023 §31.2: reference and data events are detected only when their
// conditions are true; a transition of the timestamp event records its time,
// and a transition of the timecheck event evaluates the check from the stored
// time; an optional notifier changes on each violation and can drive the
// model. For $setup the data event is the timestamp event and the violation
// window is the limit before the timecheck time, ends excluded (31.3.1); for
// $hold the reference event is the timestamp event and the window starts at
// it (31.3.2). Notifiers toggle 0 to 1 and 1 to 0, and stay z (31.6).
//
// $setup(d &&& en, posedge clk, 5): d changes at 10, 20 and 30, clk rises at
// 12, 22, 33 and 50. The change at 20 has en 0 and is not stamped, so the edge
// at 22 still sees 10 and passes; the edge at 50 sees 40, also outside.
// $hold(posedge clk &&& en2, d2, 3): the edges at 12 and 33 have en2 1, the
// edge at 22 has en2 0; d2 changes 2 after each of the three edges. ns and nh
// start at 0, nz at z. The model counts the changes of ns.
// Neither Icarus Verilog 13.0 nor the 5.052 release of Verilator performs
// timing checks; the expected output is the one the cited clauses give.

`timescale 1ns/1ns

module tcn_cell(input wire clk, input wire d, input wire en, input wire d2, input wire en2);
  reg ns = 1'b0, nh = 1'b0, nz = 1'bz;
  int changes = 0;
  always @(ns) changes = changes + 1;
  specify
    $setup(d &&& en, posedge clk, 5, ns);
    $hold(posedge clk &&& en2, d2, 3, nh);
    $setup(d &&& en, posedge clk, 5, nz);
  endspecify
endmodule

module test_timing_check_conditions_timestamps_and_notifiers;
  logic clk = 1'b0, d = 1'b0, en = 1'b1, d2 = 1'b0, en2 = 1'b1;
  tcn_cell u (.clk(clk), .d(d), .en(en), .d2(d2), .en2(en2));
  initial begin
    #10 d = 1'b1;                         // 10, stamped
    #2 clk = 1'b1;                        // 12: setup violation, hold stamp
    #2 d2 = 1'b1;                         // 14: hold violation
    #2 $display("t=16 setup=%b hold=%b z=%b", u.ns, u.nh, u.nz);
    #1 clk = 1'b0;                        // 17
    #2 en = 1'b0; en2 = 1'b0;             // 19
    #1 d = 1'b0;                          // 20, not stamped
    #2 clk = 1'b1;                        // 22: no violation, no hold stamp
    #2 d2 = 1'b0;                         // 24: no violation
    #2 $display("t=26 setup=%b hold=%b z=%b", u.ns, u.nh, u.nz);
    #1 clk = 1'b0;                        // 27
    #2 en = 1'b1; en2 = 1'b1;             // 29
    #1 d = 1'b1;                          // 30, stamped
    #3 clk = 1'b1;                        // 33: setup violation, hold stamp
    #2 d2 = 1'b1;                         // 35: hold violation
    #2 $display("t=37 setup=%b hold=%b z=%b", u.ns, u.nh, u.nz);
    #1 clk = 1'b0;                        // 38
    #2 d = 1'b0;                          // 40, stamped
    #10 clk = 1'b1;                       // 50: no violation
    #1 $display("t=51 setup=%b hold=%b z=%b changes=%0d", u.ns, u.nh, u.nz, u.changes);
  end
endmodule

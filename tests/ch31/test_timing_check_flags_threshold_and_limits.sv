/*
:name: test_timing_check_flags_threshold_and_limits
:description: The event-based flag of $timeskew and $fullskew changes when a violation is reported, the remain-active flag keeps a check active after a false-conditioned reference event, the threshold of $width is a constant expression, and a timing check limit is an expression (IEEE 1800-2023 Sections 31.4.2, 31.4.3, 31.4.4 and A.7.5.2)
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.4.2 31.4.3 31.4.4 31.6 A.7.5.1 A.7.5.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timing_check_flags_threshold_and_limits.expected
*/
// IEEE 1800-2023 A.7.5.2: event_based_flag is a constant_expression,
// remain_active_flag is a constant_mintypmax_expression, threshold is a
// constant_expression and timing_check_limit is an expression. §31.4.2: the
// default $timeskew is timer-based and reports a violation when the limit
// elapses after a reference event; with the event_based_flag set it reports
// one when a data event occurs after the limit, like $skew. With the
// remain_active_flag set, a reference event whose condition is false does not
// make the check dormant. §31.4.3: $fullskew has two limits, the first when
// the reference event precedes the data event and the second when it follows
// it; it is timer-based by default. §31.4.4: $width reports a pulse whose
// width is greater than the threshold and less than the limit.
//
// The cell tc_timer has $timeskew(posedge clk, posedge clk2, 3, n, 0, 0):
// its reference at 10 with no data event reports at 13. The cell tc_event has
// the same check with the event_based_flag 1: the data event at 16 reports at
// 16. The cell tc_remain has two checks with the same events and the
// remain_active_flag 1:1:1 and 0:0:0: a reference at 10 and a second reference
// at 12 whose condition en is false leave the first check active, so it
// reports at 13, while the second becomes dormant and never reports. The cell
// tc_hold has $hold(posedge clk, d, 2+1, n), whose data change 2 after the
// edge is inside the window of the expression 2+1 and reports at 12. The cell
// tc_full has $fullskew(posedge clk, negedge clk2, 4, 5, n, 0, 0): its
// reference at 10 with no data event reports at 14, and its data event at 20
// with no reference reports at 25. The cell tc_width has
// $width(posedge clk, 5, 1+1, n): a pulse of width 2 is not reported because
// the threshold 1+1 is 2, a pulse of width 4 reports at 24 and one of width 3
// reports at 53.

`timescale 1ns/1ns

module tc_timer (input wire clk, input wire clk2);
  reg n = 1'b0;
  specify
    $timeskew(posedge clk, posedge clk2, 3, n, 0, 0);
  endspecify
endmodule

module tc_event (input wire clk, input wire clk2);
  reg n = 1'b0;
  specify
    $timeskew(posedge clk, posedge clk2, 3, n, 1, 0);
  endspecify
endmodule

module tc_remain (input wire clk, input wire clk2, input wire en);
  reg n_on = 1'b0, n_off = 1'b0;
  specify
    $timeskew(posedge clk &&& en, posedge clk2, 3, n_on, 0, 1:1:1);
    $timeskew(posedge clk &&& en, posedge clk2, 3, n_off, 0, 0:0:0);
  endspecify
endmodule

module tc_hold (input wire clk, input wire d);
  reg n = 1'b0;
  specify
    $hold(posedge clk, d, 2 + 1, n);
  endspecify
endmodule

module tc_full (input wire clk, input wire clk2);
  reg n = 1'b0;
  specify
    $fullskew(posedge clk, negedge clk2, 4, 5, n, 0, 0);
  endspecify
endmodule

module tc_width (input wire clk);
  reg n = 1'b0;
  specify
    $width(posedge clk, 5, 1 + 1, n);
  endspecify
endmodule

module test_timing_check_flags_threshold_and_limits;
  reg c_t = 1'b0, c_t2 = 1'b0;
  reg c_e = 1'b0, c_e2 = 1'b0;
  reg c_r = 1'b0, c_r2 = 1'b0, en_r = 1'b1;
  reg c_h = 1'b0, d_h = 1'b0;
  reg c_f = 1'b0, c_f2 = 1'b1;
  reg c_w = 1'b0;

  tc_timer u_timer (c_t, c_t2);
  tc_event u_event (c_e, c_e2);
  tc_remain u_remain (c_r, c_r2, en_r);
  tc_hold u_hold (c_h, d_h);
  tc_full u_full (c_f, c_f2);
  tc_width u_width (c_w);

  initial begin
    #10 c_t = 1'b1; c_e = 1'b1; c_r = 1'b1; c_h = 1'b1; c_f = 1'b1;
    #1  c_r = 1'b0; en_r = 1'b0;
    #1  c_r = 1'b1; c_h = 1'b0; d_h = 1'b1;
    #4  c_e2 = 1'b1;
    #4  c_f2 = 1'b0;
    #2;
    $display("t=%0t timer=%b event=%b remain_on=%b remain_off=%b hold=%b full=%b width=%b",
             $time, u_timer.n, u_event.n, u_remain.n_on, u_remain.n_off, u_hold.n,
             u_full.n, u_width.n);
    #9;
    $display("t=%0t timer=%b event=%b remain_on=%b remain_off=%b hold=%b full=%b width=%b",
             $time, u_timer.n, u_event.n, u_remain.n_on, u_remain.n_off, u_hold.n,
             u_full.n, u_width.n);
    #28;
    $display("t=%0t timer=%b event=%b remain_on=%b remain_off=%b hold=%b full=%b width=%b",
             $time, u_timer.n, u_event.n, u_remain.n_on, u_remain.n_off, u_hold.n,
             u_full.n, u_width.n);
    $finish;
  end

  initial begin
    // The width pulses: 2 at 10, 4 at 20, 5 at 30 and 3 at 50.
    #10 c_w = 1'b1;
    #2  c_w = 1'b0;
    #8  c_w = 1'b1;
    #4  c_w = 1'b0;
    #6  c_w = 1'b1;
    #5  c_w = 1'b0;
    #10 c_w = 1'b1;
    #1  c_w = 1'b0;
    #9  c_w = 1'b1;
    #3  c_w = 1'b0;
  end
endmodule

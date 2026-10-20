/*
:name: test_timing_timeskew_flags
:description: $timeskew reports when the limit expires after the reference event by default, at a late data event with the event-based flag, and at every late data event like $skew with both flags (IEEE 1800-2023 Section 31.4.2)
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.4.2 31.4.1 31.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timing_timeskew_flags.expected
*/
// IEEE 1800-2023 §31.4.2: by default $timeskew is timer-based: it reports a
// violation as soon as the limit has passed after the reference event without
// a data event, and then stays dormant until the next reference event; a data
// event in time makes it dormant without a report. With the event_based_flag
// it reports at a data event that comes too late and then stays dormant; with
// the remain_active_flag as well it behaves like $skew (31.4.1) and reports
// every late data event. The limit is 5; r rises at 10, 20 and 40, d at 13,
// 30, 32 and 42. Each violation toggles its notifier (31.6), and the times of
// the changes are printed at the end.

`timescale 1ns/1ns

module test_timing_timeskew_flags_dut(input r, input d);
  reg n_timer = 0, n_event = 0, n_both = 0;

  specify
    $timeskew(posedge r, posedge d, 5, n_timer);
    $timeskew(posedge r, posedge d, 5, n_event, 1);
    $timeskew(posedge r, posedge d, 5, n_both, 1, 1);
  endspecify
endmodule

module test_timing_timeskew_flags;
  reg r = 0, d = 0;
  string log_timer = "", log_event = "", log_both = "";

  test_timing_timeskew_flags_dut u(r, d);

  always @(u.n_timer) log_timer = {log_timer, $sformatf(" %0d", $time)};
  always @(u.n_event) log_event = {log_event, $sformatf(" %0d", $time)};
  always @(u.n_both) log_both = {log_both, $sformatf(" %0d", $time)};

  initial begin
    #10 r = 1;
    #2 r = 0;
    #1 d = 1;           // 13
    #2 d = 0;
    #5 r = 1;           // 20
    #2 r = 0;
    #8 d = 1;           // 30
    #1 d = 0;
    #1 d = 1;           // 32
    #1 d = 0;
    #7 r = 1;           // 40
    #1 r = 0;
    #1 d = 1;           // 42
    #1 d = 0;
    #20;
    $display("timer-based:%s", log_timer);
    $display("event-based:%s", log_event);
    $display("event-based, remain active:%s", log_both);
  end
endmodule

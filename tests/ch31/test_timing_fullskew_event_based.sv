/*
:name: test_timing_fullskew_event_based
:description: Timer-based $fullskew reports when a limit expires after the event that came first, event-based $fullskew at the late event, which then starts a new window (IEEE 1800-2023 Section 31.4.3)
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.4.3 31.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timing_fullskew_event_based.expected
*/
// IEEE 1800-2023 §31.4.3: $fullskew takes the first of the reference and data
// events as timestamp; the other has to follow within limit 1 (5) when r comes
// first and within limit 2 (8) when d comes first. Timer-based, the default,
// it reports as soon as the limit has passed and turns dormant; an event in
// time also turns it dormant, and an event while it is dormant starts a new
// window. Event-based, it reports at the late event, which ends the window and
// starts the next one as its timestamp. r rises at 10, 25 and 50, d at 20, 40
// and 53. Timer-based: reports at 15 and 48, and d at 20 and r at 50 start
// windows that r at 25 and d at 53 close in time. Event-based: reports at 20
// and 50, which start windows closed in time at 25 and 53.

`timescale 1ns/1ns

module test_timing_fullskew_event_based_dut(input r, input d);
  reg n_timer = 0, n_event = 0;

  specify
    $fullskew(posedge r, posedge d, 5, 8, n_timer);
    $fullskew(posedge r, posedge d, 5, 8, n_event, 1);
  endspecify
endmodule

module test_timing_fullskew_event_based;
  reg r = 0, d = 0;
  string log_timer = "", log_event = "";

  test_timing_fullskew_event_based_dut u(r, d);

  always @(u.n_timer) log_timer = {log_timer, $sformatf(" %0d", $time)};
  always @(u.n_event) log_event = {log_event, $sformatf(" %0d", $time)};

  initial begin
    #10 r = 1;          // 10
    #2 r = 0;
    #8 d = 1;           // 20
    #2 d = 0;
    #3 r = 1;           // 25
    #2 r = 0;
    #13 d = 1;          // 40
    #2 d = 0;
    #8 r = 1;           // 50
    #2 r = 0;
    #1 d = 1;           // 53
    #2 d = 0;
    #20;
    $display("timer-based:%s", log_timer);
    $display("event-based:%s", log_event);
  end
endmodule

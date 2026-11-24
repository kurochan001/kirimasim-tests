/*
:name: test_delayed_nonblocking_event_preserves_large_integer_tick
:description: A delayed nonblocking named event leaves its caller unblocked and triggers at the exact large integral tick
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.5.1 3.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_delayed_nonblocking_event_preserves_large_integer_tick.expected
*/
`timescale 1ps/1ps

module test_delayed_nonblocking_event_preserves_large_integer_tick;
  localparam time BASE = 64'd9007199254740992;
  localparam time DELAY = 64'd9007199254740993;
  event later;
  int events_seen;
  time scheduled_at = 0, event_at = 0;

  initial begin
    #5;
    ->> #(DELAY) later;
    scheduled_at = $time;
  end

  always @(later) begin
    events_seen++;
    event_at = $time;
  end

  initial begin
    #(BASE);
    repeat (4) #1;
    $display("before events=%0d", events_seen);
    repeat (4) #1;
    $display("after events=%0d scheduled=%0d triggered=%0d",
             events_seen, scheduled_at, event_at);
  end
endmodule

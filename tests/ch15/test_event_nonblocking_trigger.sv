/*
:name: test_event_nonblocking_trigger
:description: ->> triggers an event in the NBA region without blocking, so a process woken by it sees blocking assignments made after the trigger; with a delay or an event control it triggers the event when that expires or occurs (IEEE 1800-2023 Section 15.5.1)
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.5.1 4.4.2.4 9.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_event_nonblocking_trigger.expected
*/
// IEEE 1800-2023 §15.5.1: ->> does not block; it creates a nonblocking update
// event that triggers the event in the NBA region (4.4.2.4) of the time step
// in which its delay or event control, if any, expires or occurs. At 1, ->> e1
// is followed by v = 1 in the same process; e1 is triggered only after that,
// so the process waiting on e1 prints 1. ->> #10 e2 triggers e2 at 11, and
// ->> @(posedge clk) e3 triggers e3 at the next rising edge, 5 (9.4).

`timescale 1ns/1ns

module test_event_nonblocking_trigger;
  event e1, e2, e3;
  logic clk = 0;
  int v = 0;

  always #5 clk = ~clk;   // rising edges at 5, 15, ...

  always @(e1) $display("%0d: e1, v = %0d", $time, v);
  always @(e2) $display("%0d: e2", $time);
  always @(e3) $display("%0d: e3", $time);

  initial begin
    #1;
    ->> e1;
    v = 1;
    ->> #10 e2;
    ->> @(posedge clk) e3;
    #20 $finish;
  end
endmodule

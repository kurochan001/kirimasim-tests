/*
:name: test_vpi_assertion_kill_keeps_past_sampling
:description: vpiAssertionKill discards only the attempt that started at the given time, leaves the assertion enabled, and keeps the sampling state of $past, so another running attempt still sees the value of the tick before (IEEE 1800-2023 Section 39.5.2)
:tags: ch39
:type: simulation
:lrm: 1800-2023 39.5.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_assertion_kill_keeps_past_sampling.c
:expected_stdout: @test_vpi_assertion_kill_keeps_past_sampling.expected
*/
// IEEE 1800-2023 §39.5.2: vpi_control(vpiAssertionKill, assertion, start)
// discards the attempt of the assertion that started at the given time; the
// assertion stays enabled, and no state that it uses, such as the sampling for
// $past, is reset.
// The clock rises at 5, 15, 25 and so on, and d is 0, 1, 0, 1, ... at these
// ticks. a1 needs $past(d) to differ from d two ticks after a. a is 1 at 5, 15
// and 45. At 20, $vt_kill(15) kills the attempt of 15, which would pass at 35.
// The attempt of 5 still passes at 25, where $past(d) is d of the tick 15, 1,
// and d is 0; if the kill had reset the sampling of $past, $past(d) would give
// the default sampled value 0 of d and the attempt would fail (16.9.3, 16.5.1).
// The attempt of 45 passes at 65. $vt_watch places cbAssertionSuccess,
// cbAssertionFailure and cbAssertionKill callbacks on a1 at 1 (39.4.2);
// cbAssertionSuccess is for nonvacuous success only, so the ticks where a is 0
// give no callback. They record the time and the start of the attempt, which
// are printed at the end, sorted. No simulator here runs the application: the
// expected output is derived from §39.5.2.

`timescale 1ns/1ns

module test_vpi_assertion_kill_keeps_past_sampling;
  logic clk = 0, a = 0;
  bit d = 0;

  always #5 clk = ~clk;

  // d changes at 10, 20, ..., so that it is 1 at the ticks 15, 35, 55, ...
  always #10 d = ~d;

  a1: assert property (@(posedge clk) a |-> ##2 ($past(d) != d)) else ;

  initial begin
    a = 1;                      // sampled at 5 and 15
    #1 $vt_watch;               // 1
    #19 a = 0;                  // 20
    $vt_kill(15);
    #20 a = 1;                  // 40, sampled at 45
    #10 a = 0;                  // 50
    #30 $vt_report;             // 80
    $finish;
  end
endmodule

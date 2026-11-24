/*
:name: test_nonblocking_event_zero_repeat_enqueues_in_current_nba
:description: A nonpositive repeat event control adds no delay to a nonblocking event trigger
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.5.1 9.4.5 4.4.2.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nonblocking_event_zero_repeat_enqueues_in_current_nba.expected
*/
`timescale 1ns/1ns
module test_nonblocking_event_zero_repeat_enqueues_in_current_nba;
  bit clock;
  event zero, negative, one;
  int count_zero = 0, count_negative = -2;
  time when_zero = 0, when_negative = 0, when_one = 0;

  initial @(zero) when_zero = $time;
  initial @(negative) when_negative = $time;
  initial @(one) when_one = $time;

  initial begin
    #2;
    ->> repeat (count_zero) @(posedge clock) zero;
    ->> repeat (count_negative) @(posedge clock) negative;
    ->> repeat (1) @(posedge clock) one;
    #0 $display("before NBA=%0d/%0d/%0d", when_zero, when_negative, when_one);
    #1 $display("later=%0d/%0d/%0d", when_zero, when_negative, when_one);
    #3 clock = 1;
    #1 $display("after clock=%0d/%0d/%0d", when_zero, when_negative, when_one);
    $finish(0);
  end
endmodule

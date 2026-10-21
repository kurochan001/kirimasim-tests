/*
:name: test_wait_order_first_triggered
:description: The first event of wait_order counts when it was already triggered in the current time step, the completion status can be stored by the pass and fail statements, and without an else statement a failure calls $error and the process goes on (IEEE 1800-2023 Section 15.5.4)
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.5.4 15.5.3 15.5.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_wait_order_first_triggered.expected
*/
// IEEE 1800-2023 §15.5.4: wait_order waits until its events are triggered in
// the listed order and fails as soon as one is triggered out of order; the
// first event alone can be satisfied by its persistent triggered state
// (15.5.3), which lasts for the rest of the time step. a is triggered at 1
// just before wait_order(a, b) starts in the same time step, so a counts and
// b at 2 completes the order: the pass statement stores 1. If a did not count,
// b would come first and the else statement would store 0. In the second
// phase c comes after a but before b; there is no else statement, so the
// failure calls $error, whose message is not compared, and the process goes
// on with its next statement at 9, when c is triggered.

`timescale 1ns/1ns

module test_wait_order_first_triggered;
  event a, b, c;
  bit ok = 0;
  int t_first = -1, t_second = -1;

  initial begin
    #1 -> a;
    fork
      begin
        wait_order(a, b) ok = 1; else ok = 0;
        t_first = $time;
      end
      #1 -> b;
    join
    #5;
    fork
      begin
        wait_order(a, b, c);
        t_second = $time;
      end
      begin
        #1 -> a;
        #1 -> c;
        #1 -> b;
      end
    join
    $display("first phase: status %0d at %0d", ok, t_first);
    $display("second phase: went on at %0d", t_second);
  end
endmodule

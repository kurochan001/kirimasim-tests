/*
:name: test_wait_order
:description: wait_order succeeds when its events are triggered in the given order, even when an earlier event is triggered again, and runs its else statement when a later event is triggered too early (IEEE 1800-2023 Section 15.5.4)
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.5.4 15.5.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_wait_order.expected
*/
// IEEE 1800-2023 §15.5.4: wait_order(a, b, c) waits until a, b and c are
// triggered in that order and then runs its pass statement; an event that has
// already occurred in order may be triggered again without failing, so the
// second a in the first phase is allowed. If an event is triggered before the
// events that precede it, the construct fails at once and runs its else
// statement, as when c comes right after a in the second phase. Each phase
// starts one time unit after the previous one ends, so no event triggered in
// one phase is still triggered when the next begins (15.5.1).

`timescale 1ns/1ns

module test_wait_order;
  event a, b, c;

  initial begin
    fork
      wait_order(a, b, c)
        $display("%0d: in order", $time);
      else
        $display("%0d: out of order", $time);
      begin
        #1 -> a;
        #1 -> b;
        #1 -> a;
        #1 -> c;
      end
    join
    #1;
    fork
      wait_order(a, b, c)
        $display("%0d: in order", $time);
      else
        $display("%0d: out of order", $time);
      begin
        #1 -> a;
        #1 -> c;
        #1 -> b;
      end
    join
  end
endmodule

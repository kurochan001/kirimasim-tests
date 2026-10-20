/*
:name: test_event_merge
:description: After one event variable is assigned to another, triggering either wakes the processes that wait on either, but a process already waiting on the assigned variable stays on its old event and never wakes (IEEE 1800-2023 Section 15.5.5.1)
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.5.5.1 15.5.5 15.5.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_event_merge.expected
*/
// IEEE 1800-2023 §15.5.5, §15.5.5.1: a = b, done before any process waits,
// makes a and b share one synchronization queue, so -> a and -> b each wake
// the waiters of both. c is separate until c = a at 35. The waiter of c is
// then blocked on the old event of c, which nothing can trigger any more:
// the -> c at 40 wakes the waiters of a and b, and the waiter of c never
// counts again. Each waiter counts its wake-ups; one process prints them.

module test_event_merge;
  event a, b, c;
  int na = 0, nb = 0, nc = 0;

  initial begin
    a = b;
    fork
      forever begin @a; na++; end
      forever begin @b; nb++; end
      forever begin @c; nc++; end
    join_none
    #10 -> a;
    #10 -> b;
    #10 -> c;
    #5 c = a;
    #5 -> c;
    #10 -> a;
  end

  initial begin
    #15;
    repeat (5) begin
      $display("t=%0d: a woke %0d, b woke %0d, c woke %0d", $time, na, nb, nc);
      #10;
    end
  end
endmodule

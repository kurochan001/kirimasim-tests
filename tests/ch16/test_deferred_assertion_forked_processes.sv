/*
:name: test_deferred_assertion_forked_processes
:description: a deferred assertion in a function called by forked processes queues its reports per process; resuming one process from an event control flushes only its own queue, a #0 delay is not a flush point, and two failures in one pass are both reported (IEEE 1800-2023 Section 16.4.5)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.4.5 16.4.2 16.4.1 9.3.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_deferred_assertion_forked_processes.expected
*/
// IEEE 1800-2023 §16.4.5: a deferred assertion belongs to the process that
// executes it, so each process that calls a function containing one has its own
// reports. §16.4.1: a report and the values of the arguments of its action are
// queued on that process, and unless flushed they mature in the Observed
// region. §16.4.2: a process that resumes after waiting at an event control or
// a wait statement reaches a flush point; a delay control is not listed as one.
// At 10 the fork (§9.3.2) starts four processes, all in the same time step.
// Process 1 fails twice; both reports stay. Process 2 fails, waits at @ev and
// is resumed by process 4 after two #0, which flushes its first report; it then
// fails again. Process 3 fails, passes a #0 and fails again; both reports stay.
// The fail action counts each report under the process and the value, and the
// counts are printed at 20. Verilator 5.052 also reports the first failure of
// process 2, as it runs the action of a deferred assertion at once, so the
// flush cannot cancel it.

`timescale 1ns/1ns

module test_deferred_assertion_forked_processes;
  event ev;
  int n[string];

  function automatic void note(int who, int v);
    n[$sformatf("process %0d, v=%0d", who, v)]++;
  endfunction

  function automatic void check(int v, int who);
    a1: assert #0 (v > 0) else note(who, v);
  endfunction

  initial begin
    #10;
    fork
      begin
        check(0, 1);
        check(-1, 1);
      end
      begin
        check(-2, 2);
        @ev;
        check(-3, 2);
      end
      begin
        check(-4, 3);
        #0;
        check(-5, 3);
      end
      begin
        #0;
        #0;
        ->ev;
      end
    join
    #10;
    foreach (n[k]) $display("%s: %0d", k, n[k]);
  end
endmodule

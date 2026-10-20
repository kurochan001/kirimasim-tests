/*
:name: test_deferred_assertion_per_process
:description: A deferred assertion in a function called by two processes is reported separately for each process, and a rerun of one process flushes only its report (IEEE 1800-2023 Section 16.4.5)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.4.5 16.4.2 16.4.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_deferred_assertion_per_process.expected
*/
// IEEE 1800-2023 §16.4.5: a deferred assertion belongs to the process that
// executes it, also when it sits in a function that two always_comb
// procedures call. §16.4.2: when a process runs again in the same time step,
// its pending reports are flushed. At 10 both processes call the function
// with unequal values, so the failure is reported twice. At 20 b1 first sees
// unequal values and then, after y changes behind #0, equal ones: its
// pending report is flushed. At 30 b1 fails again while b2 now passes. The
// fail action is a single call (16.4.1) that counts per process.

module test_deferred_assertion_per_process;
  logic [3:0] x = 0, y = 0, z = 0, w = 0;
  logic r1, r2;
  int fails_b1 = 0, fails_b2 = 0;

  function void report_fail(int who);
    if (who == 1) fails_b1++;
    else fails_b2++;
  endfunction

  function automatic bit same(logic [3:0] a, logic [3:0] b, int who);
    a1: assert #0 (a == b) else report_fail(who);
    return a == b;
  endfunction

  always_comb begin : b1
    r1 = same(x, y, 1);
  end

  always_comb begin : b2
    r2 = same(z, w, 2);
  end

  initial begin
    #10;
    x = 1;
    z = 1;
    #5 $display("t=%0d failures: b1 %0d, b2 %0d", $time, fails_b1, fails_b2);
    #5 x = 2;
    #0 y = 2;
    #5 $display("t=%0d failures: b1 %0d, b2 %0d", $time, fails_b1, fails_b2);
    #5;
    x = 3;
    w = 1;
    #5 $display("t=%0d failures: b1 %0d, b2 %0d", $time, fails_b1, fails_b2);
  end
endmodule

/*
:name: test_deferred_assertion_per_process
:description: A deferred assertion in a function called by two processes is reported separately for each process, and a rerun of one process flushes only its own pending report (IEEE 1800-2023 Section 16.4.5)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.4.5 16.4.2 16.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_deferred_assertion_per_process.expected
*/
// IEEE 1800-2023 §16.4.5: a deferred assertion belongs to the process that
// executes it, also when it sits in a function that two always_comb
// procedures call. §16.4.2: when a process runs again in the same time step,
// its pending reports are flushed, but not those of the other process. The
// fail action is a single call whose arguments are evaluated when the
// assertion is (16.4), so it reports the process that failed. b1 fails at 10
// and b2 at 20. At 30 both fail first; then y changes behind #0, and b1 runs
// again and passes, which flushes only its report. At 40 b1 fails again
// while b2 now passes.

module test_deferred_assertion_per_process;
  logic [3:0] x = 0, y = 0, z = 0, w = 0;
  logic r1, r2;

  function automatic bit same(logic [3:0] a, logic [3:0] b, int who);
    a1: assert #0 (a == b) else $display("t=%0d a1 failed in b%0d", $time, who);
    return a == b;
  endfunction

  always_comb begin : b1
    r1 = same(x, y, 1);
  end

  always_comb begin : b2
    r2 = same(z, w, 2);
  end

  initial begin
    #10 x = 1;
    #10 z = 1;
    #10;
    x = 2;
    z = 2;
    #0 y = 2;
    #10;
    x = 3;
    w = 2;
    #10 $finish;
  end
endmodule

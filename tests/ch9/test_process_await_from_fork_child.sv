/*
:name: test_process_await_from_fork_child
:description: await() called in a process started by fork returns when the awaited process ends, or at once if it has already ended (IEEE 1800-2023 Section 9.7)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.7 9.3.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_process_await_from_fork_child.expected
*/
// IEEE 1800-2023 §9.7: await() waits until another process has ended. It
// can be called from a process created by a fork (9.3.2), a join_none child
// or a branch of fork...join, as from an initial procedure. Each awaited
// process here ends at 5, so the waits that start at 1 return at 5; a wait
// that starts at 3 on a process that ended at 1 returns at 3.

module test_process_await_from_fork_child;
  process pa, pc, pf;
  int ta = -1, tc = -1, tf = -1;

  initial begin
    fork
      begin
        pa = process::self();
        #5;
      end
    join_none
  end

  initial begin
    fork
      begin
        #1 pa.await();
        ta = $time;
      end
    join_none
  end

  initial begin
    fork
      begin
        pc = process::self();
        #5;
      end
      begin
        #1 pc.await();
        tc = $time;
      end
    join
  end

  initial begin
    fork
      begin
        pf = process::self();
        #1;
      end
    join_none
  end

  initial begin
    fork
      begin
        #3 pf.await();
        tf = $time;
      end
    join_none
  end

  initial #30 $display("join_none child: %0d, fork...join branch: %0d, already ended: %0d",
                       ta, tc, tf);
endmodule

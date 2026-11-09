/*
:name: test_ref_static_const_waits_after_return
:description: a const ref static argument can be waited on with an event control and a wait statement in processes spawned by fork-join_none, which see the caller's later changes after the task has returned (IEEE 1800-2023 Sections 13.5.2, 9.3.2)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.5.2 13.3 9.3.2 9.4.2 9.4.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ref_static_const_waits_after_return.expected
*/
// IEEE 1800-2023 §13.3: the ref direction takes the qualifiers const and
// static together (const ref static). §13.5.2: const makes the argument
// read-only; static lets it be used where an automatic variable may not, and
// §9.3.2 lets processes of fork-join_none refer to it. Because it may be
// passed only static variables, it stays valid after the task returns, and
// it always shows the caller's current value.
// watch forks two processes on its argument r, bound to level: one waits for
// any change of r (@, §9.4.2), the other until r equals target (wait,
// §9.4.3). The task returns at once, and the initial process prints
// "returned". At time 1 level becomes 1, which wakes the first process
// ("changed: 1"); at time 2 it becomes 3, which ends the wait
// ("reached: 3"); at time 3 the initial process prints "done: 3". Each
// line is printed alone at its time.
// The expected output follows the standard alone: Icarus Verilog 13.0 does
// not support ref arguments, and the 5.052 release of Verilator does not
// support ref static ones.

module test_ref_static_const_waits_after_return;
  int level;

  task automatic watch(const ref static int r, input int target);
    fork
      begin
        @(r);
        $display("changed: %0d", r);
      end
      begin
        wait (r == target);
        $display("reached: %0d", r);
      end
    join_none
  endtask

  initial begin
    level = 0;
    watch(level, 3);
    $display("returned");
    #1 level = 1;
    #1 level = 3;
    #1 $display("done: %0d", level);
  end
endmodule

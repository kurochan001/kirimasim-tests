/*
:name: test_sched_disable_fork_ends_grandchildren
:description: disable fork also ends the processes spawned by the children of the calling process, even by a child that has ended (IEEE 1800-2023 Section 4.4.2.2)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.4.2.2 9.6.3 9.3.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sched_disable_fork_ends_grandchildren.expected
*/
// IEEE 1800-2023 §9.6.3: disable fork terminates all descendants of the calling
// process, not only its immediate children, including descendants of
// subprocesses that have already ended. The child ends at once after spawning a
// grandchild; disable fork at 1 still ends the grandchild, which would print at
// 3, while the process of the second initial procedure prints at 5.

`timescale 1ns/1ns

module test_sched_disable_fork_ends_grandchildren;
  initial begin
    fork
      begin
        fork
          #3 $display("grandchild at %0t", $time);
        join_none
      end
    join
    #1 disable fork;
  end
  initial #5 $display("other process at %0t", $time);
endmodule

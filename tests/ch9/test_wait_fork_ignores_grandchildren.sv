/*
:name: test_wait_fork_ignores_grandchildren
:description: wait fork waits only for the immediate children of the process, not for the processes those children started (IEEE 1800-2023 Section 9.6.1)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.6.1 9.3.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_wait_fork_ignores_grandchildren.expected
*/
// IEEE 1800-2023 §9.6.1: wait fork blocks until the immediate child processes
// of the current process have ended, excluding their descendants. The child
// starts a grandchild with fork-join_none (9.3.2) and ends at time 2, so wait
// fork returns at 2 although the grandchild runs until 5. The child prints
// before it ends, so it comes first at time 2.

`timescale 1ns/1ns

module test_wait_fork_ignores_grandchildren;
  initial begin
    fork
      begin
        fork
          #5 $display("t=%0d grandchild ends", $time);
        join_none
        #2 $display("t=%0d child ends", $time);
      end
    join_none
    wait fork;
    $display("t=%0d wait fork returned", $time);
  end
endmodule

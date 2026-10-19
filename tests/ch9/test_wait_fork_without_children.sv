/*
:name: test_wait_fork_without_children
:description: wait fork in a process without child processes continues at once, even while other processes have children running (IEEE 1800-2023 Section 9.6.1)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.6.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_wait_fork_without_children.expected
*/
// IEEE 1800-2023 §9.6.1: wait fork waits for the immediate child processes
// of the process that runs it, and for nothing else. A process that has
// started no processes continues at once, even while a child of another
// process is still running; after it forks a child of its own, wait fork
// waits for that child only.

module test_wait_fork_without_children;
  initial begin
    fork
      #50 $display("t=%0d the child of the first process ends", $time);
    join_none
  end

  initial begin
    #1 wait fork;
    $display("t=%0d wait fork without children returns", $time);
    fork
      #3;
    join_none
    wait fork;
    $display("t=%0d wait fork returns after the process's own child", $time);
  end
endmodule

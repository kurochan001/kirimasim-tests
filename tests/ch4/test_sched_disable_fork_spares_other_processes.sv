/*
:name: test_sched_disable_fork_spares_other_processes
:description: disable fork ends the processes spawned by the calling process and not those spawned by another process (IEEE 1800-2023 Section 4.4.2.2)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.4.2.2 9.6.3 9.3.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sched_disable_fork_spares_other_processes.expected
*/
// IEEE 1800-2023 §9.6.3: disable fork terminates the descendant subprocesses of
// the process that calls it. The first initial procedure disables its own child
// at time 1; the child of the second procedure is not its descendant and prints
// at 3.

`timescale 1ns/1ns

module test_sched_disable_fork_spares_other_processes;
  initial begin
    fork
      #3 $display("child of the first procedure at %0t", $time);
    join_none
    #1 disable fork;
  end
  initial begin
    fork
      #3 $display("child of the second procedure at %0t", $time);
    join_none
  end
endmodule

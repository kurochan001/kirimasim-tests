/*
:name: test_wait_fork_disable_fork
:description: wait fork waits for immediate child processes only, and disable fork ends all descendants, also those of children that have finished (IEEE 1800-2023 Section 9.6.1)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.6.1 9.6.3 9.3.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_wait_fork_disable_fork.expected
*/
// IEEE 1800-2023 §9.6.1: wait fork blocks until every immediate child process
// of the calling process has ended; processes started by those children are
// not waited for. §9.6.3: disable fork ends every descendant of the calling
// process, including the processes started by a child that has already ended.
// Icarus Verilog 13.0 stops with an internal assertion on this test.

`timescale 1ns/1ns

module test_wait_fork_disable_fork;
  int grandchild_done = 0;
  int long_done = 0;
  int desc_done = 0;

  task automatic start_grandchild();
    fork
      #20 grandchild_done = 1;
    join_none
  endtask

  task automatic start_descendant();
    fork
      #20 desc_done = 1;
    join_none
  endtask

  initial begin
    fork
      #5;
      begin
        start_grandchild();
        #2;
      end
    join_none
    wait fork;
    $display("%0d: wait fork returned, grandchild_done=%0d", $time, grandchild_done);
    #20;
    $display("%0d: grandchild_done=%0d", $time, grandchild_done);
    fork
      #10 long_done = 1;
      start_descendant();
    join_none
    #1;
    disable fork;
    #30;
    $display("%0d: long_done=%0d desc_done=%0d", $time, long_done, desc_done);
  end
endmodule

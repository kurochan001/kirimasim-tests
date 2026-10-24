/*
:name: test_lifetime_fork_keeps_automatic_scope
:description: the automatic variables of a fork block and of the task that encloses it stay alive while the processes spawned by the fork run, even after the task has returned (IEEE 1800-2023 Section 6.21)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.21 9.3.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_lifetime_fork_keeps_automatic_scope.expected
*/
// IEEE 1800-2023 §6.21: the lifetime of a fork-join block covers the
// execution of all processes it spawns, and the lifetime of a scope that
// encloses the fork block covers that of the fork block. The automatic task
// spawn starts two processes with join_none (§9.3.2) and returns at once.
// The processes read and write the argument id, the task variable tv and
// the fork block variable fv several time units later, so these variables
// still exist then. The two calls, at times 0 and 1, have their own copies.
// The processes print at the distinct times 5, 6, 7 and 8.
// Icarus Verilog 13.0 aborts at run time (assertion in vthread.cc,
// of_JOIN_DETACH) before printing anything.

`timescale 1ns/1ns
module test_lifetime_fork_keeps_automatic_scope;
  task automatic spawn(int id);
    int tv = id * 10;
    fork
      int fv = id + 100;
      begin
        #5 $display("t=%0t id=%0d tv=%0d fv=%0d", $time, id, tv, fv);
        tv++;
        fv++;
      end
      begin
        #7 $display("t=%0t id=%0d tv=%0d fv=%0d", $time, id, tv, fv);
      end
    join_none
  endtask

  initial begin
    spawn(1);
    #1 spawn(2);
    $display("t=%0t both calls returned", $time);
  end
endmodule

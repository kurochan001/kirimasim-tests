/*
:name: test_disable_fork_dynamic_vs_named_static
:description: disable fork ends only the processes the calling process spawned, even when another process runs the same code, while disable of a named block ends that block in every process executing it, whoever spawned them (IEEE 1800-2023 Section 9.6.3)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.6.3 9.6.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_disable_fork_dynamic_vs_named_static.expected
*/
// IEEE 1800-2023 §9.6.3: disable fork follows the dynamic parent-child
// relation: it ends the processes spawned by the calling process (and their
// descendants) only. A disable of a named block (9.6.2) uses the static
// block: it ends that block in every process that is executing it, whether
// the disabling process spawned them or not.
//
// Part 1: processes a and b each fork a child that calls the task job, whose
// named block blk waits #10 and then counts. At time 2, a runs disable fork:
// only a's child ends; b's child still counts at 10, so blk_done is 1.
// Part 2: processes c and d each fork a child that calls the task job2, whose
// block blk2 does the same. At time 2, process e, which forked neither, runs
// disable job2.blk2: both children leave blk2 at time 2 (each counts once
// after the block), and blk2_done stays 0. The counts are printed at 20.

`timescale 1ns/1ns
module test_disable_fork_dynamic_vs_named_static;
  int blk_done = 0, blk2_done = 0, blk2_left = 0, blk2_left_time = -1;

  task job;
    begin : blk
      #10;
      blk_done++;
    end
  endtask

  task job2;
    begin : blk2
      #10;
      blk2_done++;
    end
    blk2_left++;
    blk2_left_time = $time;
  endtask

  initial begin : a
    fork
      job;
    join_none
    #2 disable fork;
  end

  initial begin : b
    fork
      job;
    join_none
  end

  initial begin : c
    fork
      job2;
    join_none
  end

  initial begin : d
    fork
      job2;
    join_none
  end

  initial begin : e
    #2 disable job2.blk2;
  end

  initial begin
    #20;
    $display("disable fork: blk_done=%0d", blk_done);
    $display("named disable: blk2_done=%0d blk2_left=%0d at t=%0d", blk2_done, blk2_left,
             blk2_left_time);
  end
endmodule

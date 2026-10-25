/*
:name: test_disable_block_not_executing_no_effect
:description: disabling a named block before it starts, or between two runs of it, has no effect: the next run still goes to its end, and the disabling process goes on with its next statement (IEEE 1800-2023 Section 9.6.2)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.6.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_disable_block_not_executing_no_effect.expected
*/
// IEEE 1800-2023 §9.6.2: disabling a named block that is currently executing
// makes it jump to the statement after the block; if the block is not
// executing, the disable has no effect.
//
// The block work is the body of a loop that runs twice; each run counts
// once, waits #2 and counts again. Run 1 is from 5 to 7, run 2 from 12. A
// second process disables work at time 1 (before run 1) and at time 10
// (between the runs), printing after each disable: run 1 still counts to 2,
// and run 2 starts normally. The disable at time 13, during run 2, is the
// contrast: run 2 ends there with count 3.

`timescale 1ns/1ns
module test_disable_block_not_executing_no_effect;
  int count = 0, run;

  initial begin
    for (run = 1; run <= 2; run++) begin
      #5;
      begin : work
        count++;
        #2;
        count++;
      end
      $display("t=%0t run %0d of work over, count=%0d", $time, run, count);
    end
  end

  initial begin
    #1 disable test_disable_block_not_executing_no_effect.work;
    $display("t=%0t disabled work before it started", $time);
    #9 disable test_disable_block_not_executing_no_effect.work;
    $display("t=%0t disabled work between its runs", $time);
    #3 disable test_disable_block_not_executing_no_effect.work;
  end
endmodule

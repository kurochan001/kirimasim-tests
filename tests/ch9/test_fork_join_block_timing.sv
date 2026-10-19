/*
:name: test_fork_join_block_timing
:description: Start and finish times of nested sequential and parallel blocks with join, join_any and join_none (IEEE 1800-2023 Section 9.3.2)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.3.2 9.3.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_fork_join_block_timing.expected
*/
// IEEE 1800-2023 §9.3.2: every statement of a fork-join block starts when the
// block is entered, and its delays count from that time. join resumes the
// parent when all of them have finished, join_any when one has, and join_none
// at once; the other statements keep running. §9.3.3: a sequential block
// inside a parallel one finishes when its last statement has executed, and the
// statement after a block runs only when the block has finished.

`timescale 1ns/1ns

module test_fork_join_block_timing;
  initial begin
    fork
      #30 $display("%0d: fork 1, #30", $time);
      #10 $display("%0d: fork 1, #10", $time);
      begin
        #5 $display("%0d: fork 1, inner block, first", $time);
        #10 $display("%0d: fork 1, inner block, second", $time);
      end
    join
    $display("%0d: after join", $time);
    fork
      #10 $display("%0d: fork 2, #10", $time);
      #2 $display("%0d: fork 2, #2", $time);
    join_any
    $display("%0d: after join_any", $time);
    fork
      #1 $display("%0d: fork 3, #1", $time);
    join_none
    $display("%0d: after join_none", $time);
    #20 $display("%0d: end", $time);
  end
endmodule

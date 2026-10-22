/*
:name: test_always_parallel_block_finish
:description: Always repeats with elapsed time while a nested parallel block waits for its slowest branch (IEEE 1800-2023 Section 9.2.2.1)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.2.1 9.3.3 9.5
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_always_parallel_block_finish.expected
*/
// IEEE 1800-2023 9.2.2.1 9.3.3 9.5: Independent initial threads and timed
// always processes advance separately; join completes only after both branches
// have completed.

`timescale 1ns/1ns
module test_always_parallel_block_finish;
  int ticks;
  bit fast_done, slow_done;
  always #2 ticks++;
  initial begin
    fork
      begin #1; #2 fast_done = 1; end
      begin #5 slow_done = 1; end
    join
    $display("joined=%0d ticks=%0d done=%0d,%0d", $time, ticks, fast_done, slow_done);
    #2 $display("later=%0d ticks=%0d", $time, ticks);
    $finish;
  end
endmodule

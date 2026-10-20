/*
:name: test_join_none_children_start_after_parent_blocks
:description: Processes spawned by fork-join_none do not start until the parent blocks, so they see the value a static loop variable has by then (IEEE 1800-2023 Section 9.3.2)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.3.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_join_none_children_start_after_parent_blocks.expected
*/
// IEEE 1800-2023 §9.3.2 (Table 9-1): with join_none the parent goes on, and
// the spawned processes start only when the parent executes a blocking
// statement or ends. The loop spawns three processes that print the static
// variable i; the parent finishes the loop and prints first, then blocks at
// #1, and all three see i=3. The three lines are the same, so their order
// does not matter.

`timescale 1ns/1ns

module test_join_none_children_start_after_parent_blocks;
  int i;

  initial begin
    for (i = 0; i < 3; i++)
      fork
        $display("t=%0d child sees i=%0d", $time, i);
      join_none
    $display("t=%0d parent after the loop, i=%0d", $time, i);
    #1 $display("t=%0d parent after #1", $time);
  end
endmodule

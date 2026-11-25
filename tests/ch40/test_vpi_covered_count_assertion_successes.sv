/*
:name: test_vpi_covered_count_assertion_successes
:description: The generic assertion hit count agrees with independently observed nonvacuous successes on each assertion handle
:tags: ch40
:type: simulation
:lrm: 1800-2023 40.5.2 16.14.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_covered_count_assertion_successes.c
:expected_stdout: @test_vpi_covered_count_assertion_successes.expected
*/
// The first assertion succeeds on all three edges. The second is
// disabled for the first two edges and succeeds on the third.
`timescale 1ns/1ns
module test_vpi_covered_count_assertion_successes;
  bit tick;
  bit selected;
  int all_passes = 0, selected_passes = 0;

  all_edges: assert property (@(posedge tick) 1'b1) all_passes++;
  selected_edges: assert property (@(posedge tick) disable iff (!selected) 1'b1) selected_passes++;

  initial begin
    #1 tick = 1;
    #1 tick = 0;
    #1 tick = 1;
    #1 tick = 0;
    selected = 1;
    #1 tick = 1;
    #1 $display("hdl passes=%0d,%0d", all_passes, selected_passes);
  end
endmodule

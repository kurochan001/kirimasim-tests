/*
:name: test_A_extra_nochange_offsets
:description: The third and fourth arguments of $nochange are the start-edge offset and the end-edge offset, each a mintypmax expression, and a stable data signal keeps the check quiet (IEEE 1800-2023 Sections 31.2 and 31.3.6, A.7.5.2)
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.2 31.4.6 A.7.5.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_A_extra_nochange_offsets.expected
*/
// IEEE 1800-2023 A.7.5.2, system timing check command arguments: start_edge_
// offset and end_edge_offset are each a mintypmax_expression, and Syntax 31-14
// gives them as the third and fourth arguments of $nochange. §31.4.6 forms the
// time window from the reference edge minus the start offset to the edge plus
// the end offset. The three values of each mintypmax expression are the same,
// so the selected value does not depend on the tool.
//
// The data input d does not change, so no $nochange violation occurs and the
// notifier keeps its initial value. The test prints done after one time unit.

`timescale 1ns/1ns
module nc_cell(input wire clk, input wire d);
  reg n = 1'b0;
  specify
    $nochange(posedge clk, d, 1:2:3, 4:5:6, n);
  endspecify
endmodule

module test_A_extra_nochange_offsets;
  logic clk = 0, d = 0;
  nc_cell u (.clk(clk), .d(d));

  initial begin
    #1 $display("done");
    $finish;
  end
endmodule

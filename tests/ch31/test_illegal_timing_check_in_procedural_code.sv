/*
:name: test_illegal_timing_check_in_procedural_code
:description: A timing check cannot appear in procedural code, so $setup as a statement of an initial procedure is illegal, while the same check in a specify block is legal (IEEE 1800-2023 Section 31.2)
:tags: ch31
:type: elaboration
:lrm: 1800-2023 31.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the initial procedure of tcp_cell contains the timing check $setup as a statement
:expected_stderr_regex: test_illegal_timing_check_in_procedural_code\.sv:26:
*/
// IEEE 1800-2023 §31.2: timing checks are not system tasks, and no timing
// check can appear in procedural code. tcp_cell has $setup(d, posedge clk, 2)
// in its specify block, which is legal, and the same check as a statement of
// an initial procedure.

`timescale 1ns/1ns

module tcp_cell(input wire clk, input wire d);
  specify
    $setup(d, posedge clk, 2);
  endspecify
  initial begin
    $setup(d, posedge clk, 2);   // illegal: a timing check in procedural code
  end
endmodule

module test_illegal_timing_check_in_procedural_code;
  logic clk = 1'b0, d = 1'b0;
  tcp_cell u (.clk(clk), .d(d));
  initial #1 $display("built");
endmodule

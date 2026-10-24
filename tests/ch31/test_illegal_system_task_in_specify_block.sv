/*
:name: test_illegal_system_task_in_specify_block
:description: Timing checks are not system tasks, and no system task can appear in a specify block, so a $display among the timing checks of a specify block is illegal (IEEE 1800-2023 Section 31.2)
:tags: ch31
:type: elaboration
:lrm: 1800-2023 31.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the specify block of sts_cell contains the system task call $display
:expected_stderr_regex: test_illegal_system_task_in_specify_block\.sv:27:
*/
// IEEE 1800-2023 §31.2: although their names begin with $, timing checks are
// not system tasks; no system task can appear in a specify block, and no
// timing check can appear in procedural code. The specify block of sts_cell
// has a specparam and a $setup check, which are legal, and a call of
// $display.
// The 5.052 release of Verilator accepts the design.

`timescale 1ns/1ns

module sts_cell(input wire clk, input wire d);
  specify
    specparam tsu = 2;
    $setup(d, posedge clk, tsu);
    $display("in specify");   // illegal: a system task in a specify block
  endspecify
endmodule

module test_illegal_system_task_in_specify_block;
  logic clk = 1'b0, d = 1'b0;
  sts_cell u (.clk(clk), .d(d));
  initial #1 $display("built");
endmodule

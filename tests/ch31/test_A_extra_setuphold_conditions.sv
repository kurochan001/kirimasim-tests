/*
:name: test_A_extra_setuphold_conditions
:description: The timestamp condition and the timecheck condition of $setuphold are mintypmax expressions, and its delayed reference and delayed data are terminal identifiers, which the check accepts and leaves quiet when no window is violated (IEEE 1800-2023 Sections 31.3.3 and 31.5, A.7.5.2)
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.3.3 31.9.2 A.7.5.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_A_extra_setuphold_conditions.expected
*/
// IEEE 1800-2023 A.7.5.2, system timing check command arguments: the
// timestamp_condition and the timecheck_condition are each a
// mintypmax_expression, and delayed_reference and delayed_data are each a
// terminal_identifier, optionally followed by a bracketed constant
// mintypmax_expression. Syntax 31-5 orders the nine arguments of $setuphold as
// the two events, the setup and hold limits, the notifier, the timestamp
// condition, the timecheck condition, the delayed reference and the delayed
// data.
//
// The conditions 7:8:9 and 10:11:12 have equal values in each triplet, so the
// selected values do not depend on the tool. dr and dd are the delayed
// terminals. The inputs do not change, so no setup or hold violation occurs
// and the notifier keeps its value; the test prints done. The bracketed
// mintypmax index of a delayed terminal is not written because both Icarus
// Verilog 13.0 and the 5.052 release of Verilator reject it.
//
// Icarus Verilog 13.0 does not accept the condition and delayed arguments of
// $setuphold, so the expected output is recorded with the 5.052 release of
// the other simulator.

`timescale 1ns/1ns
module sh_cell(input wire clk, input wire d);
  reg n = 1'b0;
  reg [7:0] dr;
  reg [7:0] dd;
  specify
    $setuphold(posedge clk, d, 1:2:3, 4:5:6, n, 7:8:9, 10:11:12, dr, dd);
  endspecify
endmodule

module test_A_extra_setuphold_conditions;
  logic clk = 0, d = 0;
  sh_cell u (.clk(clk), .d(d));

  initial begin
    #1 $display("done");
    $finish;
  end
endmodule

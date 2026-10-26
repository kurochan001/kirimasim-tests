/*
:name: test_illegal_checker_hierarchical_read_write
:description: A checker variable cannot be read or written through a hierarchical name in an assignment, including a read as the operand of the same assignment (IEEE 1800-2023 Section 17.7.1)
:tags: ch17
:type: elaboration
:lrm: 1800-2023 17.7.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the module assignment reads and writes the checker variable armed through the hierarchical name c.armed
:expected_stderr_regex: test_illegal_checker_hierarchical_read_write\.sv:(35):
*/
// IEEE 1800-2023 §17.7.1: a checker variable shall not be referenced by a
// hierarchical name in an assignment, including reading it as an assignment
// operand. The assignment c.armed = c.armed + 1 both reads armed on the right
// and writes it on the left through the instance c, so one statement shows
// both directions of the prohibition. No procedure of the checker assigns
// armed, and the rest of the design is legal. Icarus Verilog 13.0 has no
// checkers and Verilator 5.052 accepts the hierarchical write, so the
// expected rejection follows the clause alone.

`timescale 1ns/1ns

checker cb_hier (input logic clk);
  int armed = 0;
endchecker : cb_hier

module test_illegal_checker_hierarchical_read_write;
  logic clk = 1'b0;

  cb_hier c (clk);

  initial begin
    #1 c.armed = c.armed + 1;   // illegal: read and write by hierarchy
  end
endmodule

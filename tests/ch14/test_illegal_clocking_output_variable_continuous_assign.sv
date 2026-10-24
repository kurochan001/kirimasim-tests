/*
:name: test_illegal_clocking_output_variable_continuous_assign
:description: a variable of a clocking output cannot also be written by a continuous assignment (IEEE 1800-2023 Section 14.16.2)
:tags: ch14
:type: elaboration
:lrm: 1800-2023 14.16.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the variable y, associated with the output clockvar cb.y, is written by a continuous assignment
:expected_stderr_regex: test_illegal_clocking_output_variable_continuous_assign\.sv:31:
*/
// IEEE 1800-2023 §14.16.2: it shall be illegal to write a variable with a
// continuous assignment, a procedural continuous assignment or a primitive
// when the variable is associated with an output clockvar. y is the signal of
// the output cb.y; the clockvar is never driven, so no procedural write meets
// the continuous assignment, which breaks only this rule. w is not in the
// clocking block, and its continuous assignment is legal.
// Icarus Verilog 13.0 does not support clocking blocks and reports syntax
// errors on other lines.
// The 5.052 release of Verilator accepts the design with a warning.

module test_illegal_clocking_output_variable_continuous_assign;
  logic clk = 0, a = 1;
  logic y, w;
  clocking cb @(posedge clk);
    output y;
  endclocking
  assign w = a;
  assign y = a;   // illegal
endmodule

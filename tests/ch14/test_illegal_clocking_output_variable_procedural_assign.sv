/*
:name: test_illegal_clocking_output_variable_procedural_assign
:description: a variable of a clocking output cannot also be written by a procedural continuous assignment (IEEE 1800-2023 Section 14.16.2)
:tags: ch14
:type: elaboration
:lrm: 1800-2023 14.16.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the variable y, associated with the output clockvar cb.y, is the target of a procedural continuous assign
:expected_stderr_regex: test_illegal_clocking_output_variable_procedural_assign\.sv:31:
*/
// IEEE 1800-2023 §14.16.2: it shall be illegal to write a variable with a
// continuous assignment, a procedural continuous assignment or a primitive
// when the variable is associated with an output clockvar. y is the signal of
// the output cb.y and is the target of an assign statement in the initial
// procedure; w is not in the clocking block, and its assign is legal.
// Icarus Verilog 13.0 does not support clocking blocks and reports syntax
// errors on other lines.
// The 5.052 release of Verilator accepts the design.

module test_illegal_clocking_output_variable_procedural_assign;
  logic clk = 0, a = 1;
  logic y, w;
  clocking cb @(posedge clk);
    output y;
  endclocking
  initial begin
    assign w = a;
    assign y = a;   // illegal
  end
endmodule

/*
:name: test_illegal_clocking_output_variable_primitive_output
:description: a variable of a clocking output cannot also be written by a primitive (IEEE 1800-2023 Section 14.16.2)
:tags: ch14
:type: elaboration
:lrm: 1800-2023 14.16.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the variable y, associated with the output clockvar cb.y, is the output of a buf primitive
:expected_stderr_regex: test_illegal_clocking_output_variable_primitive_output\.sv:33:
*/
// IEEE 1800-2023 §14.16.2: it shall be illegal to write a variable with a
// continuous assignment, a procedural continuous assignment or a primitive
// when the variable is associated with an output clockvar. y is the signal of
// the output cb.y and the output of the buf b2. A variable may otherwise be
// the output of a primitive: 6.5 lists gate outputs that write members of a
// structure variable among its legal assignments, and this rule names
// primitives among the writers of a variable. So w, which is not in the
// clocking block, may be the output of b1.
// Icarus Verilog 13.0 does not support clocking blocks and reports syntax
// errors on other lines.
// The 5.052 release of Verilator accepts the design with a warning.

module test_illegal_clocking_output_variable_primitive_output;
  logic clk = 0, a = 1;
  logic y, w;
  clocking cb @(posedge clk);
    output y;
  endclocking
  buf b1 (w, a);
  buf b2 (y, a);   // illegal
endmodule

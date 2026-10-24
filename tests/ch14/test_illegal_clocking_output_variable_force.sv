/*
:name: test_illegal_clocking_output_variable_force
:description: a variable of a clocking output cannot also be written by a force statement (IEEE 1800-2023 Section 14.16.2)
:tags: ch14
:type: elaboration
:lrm: 1800-2023 14.16.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the variable y, associated with the output clockvar cb.y, is the target of a force statement
:expected_stderr_regex: test_illegal_clocking_output_variable_force\.sv:32:
*/
// IEEE 1800-2023 §14.16.2: it shall be illegal to write a variable with a
// continuous assignment, a procedural continuous assignment or a primitive
// when the variable is associated with an output clockvar. force is the second
// form of procedural continuous assignment (10.6.2), besides assign. y is the
// signal of the output cb.y and is forced in the initial procedure; w is not
// in the clocking block, and forcing it is legal.
// Icarus Verilog 13.0 does not support clocking blocks; the syntax errors it
// reports, one of them on this line, do not count. Verilator 5.052 accepts the
// design.

module test_illegal_clocking_output_variable_force;
  logic clk = 0, a = 1;
  logic y, w;
  clocking cb @(posedge clk);
    output y;
  endclocking
  initial begin
    force w = a;
    force y = a;   // illegal
  end
endmodule

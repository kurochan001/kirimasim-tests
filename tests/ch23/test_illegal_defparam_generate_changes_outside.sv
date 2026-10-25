/*
:name: test_illegal_defparam_generate_changes_outside
:description: A defparam statement inside a generate block cannot change a parameter of an instance outside the hierarchy of that block (IEEE 1800-2023 Section 23.10.1)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.10.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the defparam in the generate block g names the parameter P of the instance outside, which is not inside g
:expected_stderr_regex: test_illegal_defparam_generate_changes_outside\.sv:28:
*/
// IEEE 1800-2023 §23.10.1: a defparam statement in or under a generate
// block instance shall not change a parameter outside that hierarchy. The
// instance outside is declared in the top module, beside the generate block
// g, so the defparam inside g may not set its parameter P. The design is
// otherwise legal: the same defparam placed in the top module would be.
// Icarus Verilog 13.0 and Verilator 5.052 accept this design.

module defparam_generate_outside_leaf;
  parameter int P = 0;
endmodule

module test_illegal_defparam_generate_changes_outside;
  defparam_generate_outside_leaf outside();
  if (1) begin : g
    defparam outside.P = 5;   // illegal
  end
endmodule

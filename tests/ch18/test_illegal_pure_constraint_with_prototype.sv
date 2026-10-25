/*
:name: test_illegal_pure_constraint_with_prototype
:description: A class that has a pure constraint and a constraint prototype of the same name is an error (IEEE 1800-2023 Section 18.5.2)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the abstract class pwp_abstract declares the pure constraint c_a and a constraint prototype c_a
:expected_stderr_regex: test_illegal_pure_constraint_with_prototype\.sv:(25|26):
*/
// IEEE 1800-2023 §18.5.2: it is an error if a class that contains a pure
// constraint also has a constraint prototype of the same name. pwp_abstract
// declares c_a as pure and also as an implicit prototype, which is not
// completed (alone, such a prototype would only be an empty constraint).
// pwp_concrete gives c_a by a block. A tool can report the error at either
// declaration in pwp_abstract.
// Icarus Verilog 13.0 does not support pure constraints, so the syntax error it
// reports does not count; Verilator 5.052 accepts the design.

virtual class pwp_abstract;
  rand int v;
  pure constraint c_a;
  constraint c_a;   // illegal: same name as the pure constraint
endclass

class pwp_concrete extends pwp_abstract;
  constraint c_a { v > 5; }
endclass

module test_illegal_pure_constraint_with_prototype;
  pwp_concrete o = new;
  initial $display("ok=%0d", o.randomize());
endmodule

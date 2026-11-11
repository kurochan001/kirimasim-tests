/*
:name: test_illegal_pure_constraint_with_external
:description: An external constraint block for a pure constraint of the same class is an error (IEEE 1800-2023 Section 18.5.2)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5.2 18.5.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: an external constraint block pwe_abstract::c_a is given for the pure constraint c_a of pwe_abstract
:expected_stderr_regex: test_illegal_pure_constraint_with_external\.sv:(27|34):
*/
// IEEE 1800-2023 §18.5.2: it is an error if a class that contains a pure
// constraint also has an external constraint block (18.5.1) of the same name.
// pwe_abstract declares c_a pure, and a block pwe_abstract::c_a follows the
// class. pwe_concrete gives c_a by a block of its own, which is legal. A tool
// can report the error at the external block or at the pure constraint.
// In the syntax a pure constraint is a constraint prototype (18.5), so the
// block does have a prototype; the error comes from the rule of 18.5.2. Icarus
// Verilog 13.0 does not support pure constraints, so the syntax error it
// reports does not count; Verilator 5.052 reports, besides a duplicate
// declaration, that the block has no prototype.

virtual class pwe_abstract;
  rand int v;
  pure constraint c_a;
endclass

class pwe_concrete extends pwe_abstract;
  constraint c_a { v > 5; }
endclass

constraint pwe_abstract::c_a { v > 0; }   // illegal: c_a is pure in pwe_abstract

module test_illegal_pure_constraint_with_external;
  pwe_concrete o = new;
  initial $display("ok=%0d", o.randomize());
endmodule

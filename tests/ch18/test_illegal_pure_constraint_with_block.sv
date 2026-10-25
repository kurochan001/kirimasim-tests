/*
:name: test_illegal_pure_constraint_with_block
:description: A class that has a pure constraint and a constraint block of the same name is an error (IEEE 1800-2023 Section 18.5.2)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the abstract class pwb_abstract declares the pure constraint c_a and a constraint block c_a
:expected_stderr_regex: test_illegal_pure_constraint_with_block\.sv:(24|25):
*/
// IEEE 1800-2023 §18.5.2: it is an error if a class that contains a pure
// constraint also has a constraint block of the same name. (A derived class
// may give a block for a pure constraint it inherits, as pwb_concrete does.)
// pwb_abstract declares c_a both as pure and as a block. A tool can report
// the error at either declaration.
// Icarus Verilog 13.0 does not support pure constraints, so the syntax error it
// reports does not count.

virtual class pwb_abstract;
  rand int v;
  pure constraint c_a;
  constraint c_a { v > 0; }   // illegal: same name as the pure constraint
endclass

class pwb_concrete extends pwb_abstract;
  constraint c_a { v > 5; }
endclass

module test_illegal_pure_constraint_with_block;
  pwb_concrete o = new;
  initial $display("ok=%0d", o.randomize());
endmodule

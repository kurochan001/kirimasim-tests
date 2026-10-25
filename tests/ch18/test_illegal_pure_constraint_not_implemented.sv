/*
:name: test_illegal_pure_constraint_not_implemented
:description: A non-abstract class that does not implement an inherited pure constraint is an error (IEEE 1800-2023 Section 18.5.2)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5.2 8.21
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the non-abstract class pni_concrete inherits the pure constraint c_need and gives no constraint of that name
:expected_stderr_regex: test_illegal_pure_constraint_not_implemented\.sv:(25|32):
*/
// IEEE 1800-2023 §18.5.2: a pure constraint of an abstract class (8.21) is an
// obligation on every non-abstract derived class, and it is an error if such
// a class has no implementation of a pure constraint it inherits. pni_mid is
// abstract, so it may leave c_need pure; pni_concrete is not abstract and
// gives only c_other. A tool can report the error at the class that lacks the
// implementation or at the pure constraint.
// Icarus Verilog 13.0 does not support pure constraints, so the syntax error it
// reports does not count.

virtual class pni_abstract;
  rand int v;
  pure constraint c_need;
endclass

virtual class pni_mid extends pni_abstract;
  constraint c_mid { v < 100; }
endclass

class pni_concrete extends pni_mid;   // illegal: c_need is not implemented
  constraint c_other { v > 0; }
endclass

module test_illegal_pure_constraint_not_implemented;
  pni_concrete o = new;
  initial $display("ok=%0d", o.randomize());
endmodule

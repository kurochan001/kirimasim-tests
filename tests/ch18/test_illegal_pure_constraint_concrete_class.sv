/*
:name: test_illegal_pure_constraint_concrete_class
:description: A pure constraint can be declared only in an abstract class (IEEE 1800-2023 Section 18.5.2)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5.2 8.21
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the pure constraint c_more is declared in a class that is not virtual
:expected_stderr_regex: test_illegal_pure_constraint_concrete_class\.sv:29:
*/
// IEEE 1800-2023 §18.5.2: a pure constraint is an obligation on the
// non-abstract classes derived from an abstract class (8.21) to give a
// constraint of its name, and declaring one in a class that is not declared
// virtual is an error. pcn_abstract may declare c_need as pure; pcn_concrete,
// a class that is not virtual, may not declare c_more as pure. Icarus
// Verilog 13.0 does not support pure constraints, so the syntax error it
// reports on that line does not count.

virtual class pcn_abstract;
  rand bit [3:0] v;
  pure constraint c_need;
endclass

class pcn_concrete extends pcn_abstract;
  constraint c_need { v < 4'd8; }
  pure constraint c_more;   // illegal: pcn_concrete is not abstract
endclass

module test_illegal_pure_constraint_concrete_class;
  pcn_concrete o = new;
  initial $display("ok=%0d", o.randomize());
endmodule

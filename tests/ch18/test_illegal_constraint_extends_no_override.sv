/*
:name: test_illegal_constraint_extends_no_override
:description: A constraint declared with :extends that does not replace a constraint of a base class is an error (IEEE 1800-2023 Section 18.5.2)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: c_new is declared with :extends, but no base class has a constraint named c_new
:expected_stderr_regex: test_illegal_constraint_extends_no_override\.sv:29:
*/
// IEEE 1800-2023 §18.5.2: the extends specifier says that a constraint
// replaces a constraint of a base class, and using it on a constraint that
// replaces nothing is an error. In ceo_derived, c_a with :extends replaces
// c_a of ceo_base and is legal; c_new with :extends has no constraint of its
// name in ceo_base.
// Icarus Verilog 13.0 does not support override specifiers, so the syntax error
// it reports does not count; Verilator 5.052 accepts the design.

class ceo_base;
  rand int v;
  constraint c_a { v > 0; }
endclass

class ceo_derived extends ceo_base;
  constraint :extends c_a { v > 5; }
  constraint :extends c_new { v < 10; }   // illegal: replaces nothing
endclass

module test_illegal_constraint_extends_no_override;
  ceo_derived o = new;
  initial $display("ok=%0d", o.randomize());
endmodule

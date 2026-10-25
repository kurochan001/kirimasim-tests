/*
:name: test_illegal_constraint_initial_override
:description: A constraint declared with :initial that replaces a constraint of a base class is an error (IEEE 1800-2023 Section 18.5.2)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: c_a of cio2_derived is declared :initial, but it replaces c_a of cio2_base
:expected_stderr_regex: test_illegal_constraint_initial_override\.sv:28:
*/
// IEEE 1800-2023 §18.5.2: the initial specifier says that a constraint is not
// an override, and specifying it on a constraint that replaces a constraint
// of a base class is an error. In cio2_derived, c_b with :initial has no
// constraint of its name in cio2_base and is legal; c_a with :initial
// replaces c_a of cio2_base.
// Icarus Verilog 13.0 does not support override specifiers, so the syntax error
// it reports on that line does not count; Verilator 5.052 accepts the design.

class cio2_base;
  rand int v;
  constraint c_a { v > 0; }
endclass

class cio2_derived extends cio2_base;
  constraint :initial c_a { v > 5; }   // illegal: replaces c_a of the base
  constraint :initial c_b { v < 10; }
endclass

module test_illegal_constraint_initial_override;
  cio2_derived o = new;
  initial $display("ok=%0d", o.randomize());
endmodule

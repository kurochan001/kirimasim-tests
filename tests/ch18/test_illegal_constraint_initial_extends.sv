/*
:name: test_illegal_constraint_initial_extends
:description: The initial and extends specifiers are mutually exclusive, so a constraint written with both is an error (IEEE 1800-2023 Section 18.5.2)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: c of cie_derived has both the initial and the extends specifier
:expected_stderr_regex: test_illegal_constraint_initial_extends\.sv:28:
*/
// IEEE 1800-2023 §18.5.2: initial says that a constraint shall not be an
// override, and extends says that it shall be an override; specifying both in
// one constraint declaration is an error. c_ok in cie_derived has only
// extends and replaces c_ok of the base class, so it is legal; c has both
// specifiers and is illegal.

class cie_base;
  rand int v;

  constraint c { v > 0; }
  constraint c_ok { v < 100; }
endclass

class cie_derived extends cie_base;
  constraint : initial : extends c { v < 10; }   // illegal: both specifiers
  constraint : extends c_ok { v < 50; }
endclass

module test_illegal_constraint_initial_extends;
  cie_derived o = new;

  initial begin
    $display("randomize=%0d", o.randomize());
  end
endmodule

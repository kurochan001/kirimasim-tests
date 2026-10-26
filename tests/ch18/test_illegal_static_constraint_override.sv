/*
:name: test_illegal_static_constraint_override
:description: A static constraint shall not use a dynamic override specifier, so a static constraint with the initial specifier is an error (IEEE 1800-2023 Sections 18.5 and 18.5.10)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5 18.5.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: c of sco_derived is static and also has the initial specifier
:expected_stderr_regex: test_illegal_static_constraint_override\.sv:29:
*/
// IEEE 1800-2023 §18.5.10: it shall be illegal to use a dynamic override
// specifier with a static constraint; the specifiers are initial, extends and
// final (§18.5.2). The plain static constraint s_ok and the non-static
// constraint : final d_ok are legal; c is static and has initial, so it is
// illegal.

class sco_base;
  rand int v;

  constraint c { v > 0; }
endclass

class sco_derived extends sco_base;
  static constraint s_ok { v > -100; }
  constraint : final d_ok { v < 100; }
  static constraint : initial c { v < 10; }   // illegal: static with initial
endclass

module test_illegal_static_constraint_override;
  sco_derived o = new;

  initial begin
    $display("randomize=%0d", o.randomize());
  end
endmodule

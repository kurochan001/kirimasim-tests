/*
:name: test_illegal_bind_defparam_outside_bound_hierarchy
:description: A defparam inside a bound instantiation cannot change a parameter outside the hierarchy of that instantiation (IEEE 1800-2023 Section 23.11)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.11
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the defparam in the bound module bdo_chk changes the parameter P of the instance leaf of the target, outside the hierarchy of the bound instance
:expected_stderr_regex: test_illegal_bind_defparam_outside_bound_hierarchy\.sv:29:
*/
// IEEE 1800-2023 §23.11: a defparam statement located in the hierarchy of a
// bind instantiation shall not extend its influence outside that local
// hierarchy, as for defparams in generated hierarchy. The bound instance c of
// bdo_chk changes the parameter of its own instance inner, which is legal,
// and that of leaf, which is part of the target instance t and not of c.
// Oracle checks: Icarus Verilog 13.0 does not support bind and reports a syntax
// error on every bind statement, which is not counted; the 5.052 release
// of Verilator accepts the design.

module bdo_leaf #(parameter int P = 1) ();
endmodule

module bdo_chk;
  bdo_leaf inner ();
  defparam inner.P = 3;
  defparam test_illegal_bind_defparam_outside_bound_hierarchy.t.leaf.P = 5;   // illegal
endmodule

module bdo_target;
  bdo_leaf leaf ();
endmodule

module test_illegal_bind_defparam_outside_bound_hierarchy;
  bdo_target t ();
  bind bdo_target bdo_chk c ();
endmodule

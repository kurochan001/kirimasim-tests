/*
:name: test_illegal_interface_extends_forward_typedef
:description: An interface class cannot extend an interface class known only through a forward typedef (IEEE 1800-2023 Section 8.26.4)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.26.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the interface class derived_if extends base_if, which at that point is declared only by a forward typedef
:expected_stderr_regex: test_illegal_interface_extends_forward_typedef\.sv:24:
*/
// IEEE 1800-2023 §8.26.4: an interface class shall not extend from a
// forward typedef of an interface class; the interface class has to be
// declared before it is extended. base_if is declared after derived_if,
// which extends it. Icarus Verilog 13.0 does not support interface
// classes, so the syntax errors it reports do not count.
// The 5.052 release of Verilator accepts the design.

module test_illegal_interface_extends_forward_typedef;
  typedef interface class base_if;

  interface class derived_if extends base_if;   // illegal: base_if not declared yet
    pure virtual function int g();
  endclass

  interface class base_if;
    pure virtual function int f();
  endclass
endmodule

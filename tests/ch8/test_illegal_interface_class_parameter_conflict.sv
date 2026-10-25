/*
:name: test_illegal_interface_class_parameter_conflict
:description: An interface class that inherits a parameter of the same name from two interface classes must declare it itself (IEEE 1800-2023 Section 8.26.6.2)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.26.6.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the parameter W is inherited from both a_if and b_if and c_if does not declare W
:expected_stderr_regex: test_illegal_interface_class_parameter_conflict\.sv:32:
*/
// IEEE 1800-2023 §8.26.6.2: a name collision occurs when the same name is
// inherited from different interface classes, also for parameters, even
// when both have the same value and the name is never used; the extending
// interface class shall declare the name to resolve it. a_if and b_if both
// have the parameter W; c_if extends both and does not. Icarus Verilog 13.0
// does not support interface classes, so the syntax errors it reports do
// not count.
// The 5.052 release of Verilator accepts the design.

module test_illegal_interface_class_parameter_conflict;
  interface class a_if #(int W = 8);
    pure virtual function void a();
  endclass

  interface class b_if #(int W = 8);
    pure virtual function void b();
  endclass

  interface class c_if extends a_if, b_if;   // illegal: W collides
  endclass
endmodule

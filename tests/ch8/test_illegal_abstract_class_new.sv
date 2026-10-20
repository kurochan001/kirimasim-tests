/*
:name: test_illegal_abstract_class_new
:description: An object of an abstract (virtual) class cannot be constructed (IEEE 1800-2023 Section 8.21)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.21
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: new is called for the abstract class shape
:expected_stderr_regex: test_illegal_abstract_class_new\.sv:24:
*/
// IEEE 1800-2023 §8.21: a class declared virtual is abstract, and an object of
// it cannot be constructed directly; only subclasses that are not abstract can
// be.

module test_illegal_abstract_class_new;
  virtual class shape;
    int sides;
  endclass

  shape s;
  initial s = new;     // illegal: shape is abstract
endmodule

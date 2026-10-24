/*
:name: test_illegal_force_class_property
:description: A non-static class property cannot be written by a procedural continuous assignment such as force (IEEE 1800-2023 Section 6.21)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.21 8.4 10.6.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the force statement writes h.value, a non-static property of a class object
:expected_stderr_regex: test_illegal_force_class_property\.sv:28:
*/
// IEEE 1800-2023 §6.21: non-static class properties shall not be written
// with continuous or procedural continuous assignments. force (§10.6.2) is
// a procedural continuous assignment, and it targets the property value of
// the object of h (§8.4).
// On this line Verilator 5.052 stops with an internal error for an
// unsupported force target, and Icarus Verilog 13.0 aborts in its code
// generator; neither is a diagnosis of the rule.

module test_illegal_force_class_property;
  class box_c;
    int value;
  endclass
  box_c h = new;
  initial begin
    force h.value = 5;    // illegal: procedural continuous assignment to a property
  end
endmodule

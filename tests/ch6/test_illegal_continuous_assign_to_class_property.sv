/*
:name: test_illegal_continuous_assign_to_class_property
:description: A non-static class property cannot be written by a continuous assignment (IEEE 1800-2023 Section 6.21)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.21 8.4 10.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the continuous assignment writes h.value, a non-static property of a class object
:expected_stderr_regex: test_illegal_continuous_assign_to_class_property\.sv:28:
*/
// IEEE 1800-2023 §6.21: non-static class properties shall not be written
// with continuous or procedural continuous assignments. value is a property
// of the object of h (§8.4), and the continuous assignment (§10.3) drives
// it.
// No object is created, so that nothing else writes h.
// Icarus Verilog 13.0 rejects this line for another reason (it says the
// type of src does not match the context type).

module test_illegal_continuous_assign_to_class_property;
  class box_c;
    int value;
  endclass
  box_c h;
  int src = 5;
  assign h.value = src;    // illegal: continuous assignment to a class property
endmodule

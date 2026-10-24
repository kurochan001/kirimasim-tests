/*
:name: test_illegal_attribute_instance_nested
:description: An attribute instance written inside another attribute instance is rejected (IEEE 1800-2023 Section 5.12)
:tags: ch5
:type: elaboration
:lrm: 1800-2023 5.12
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the attribute instance (* inner *) is nested inside the attribute instance that sets outer
:expected_stderr_regex: test_illegal_attribute_instance_nested\.sv:23:
*/
// IEEE 1800-2023 §5.12: nesting of attribute instances is disallowed; an
// attribute instance is a list of attribute names, each with an optional
// constant value. Several attribute instances can be written one after
// another before a declaration, which is legal. On the marked line an
// attribute instance is written inside the other one, an error. The test of
// an attribute value with an attribute checks the case inside a value.

module test_illegal_attribute_instance_nested;
  (* first *) (* second = 2 *) int a = 3;
  (* (* inner *) outer *) int b = 4;   // illegal: nested attribute instance

  initial $display("%0d %0d", a, b);
endmodule

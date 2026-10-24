/*
:name: test_illegal_attribute_value_contains_attribute
:description: An attribute whose value expression contains an attribute instance is rejected (IEEE 1800-2023 Section 5.12)
:tags: ch5
:type: elaboration
:lrm: 1800-2023 5.12
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the value of the attribute outer is a constant expression that contains the attribute instance (* inner *)
:expected_stderr_regex: test_illegal_attribute_value_contains_attribute\.sv:24:
*/
// IEEE 1800-2023 §5.12: an attribute value is a constant expression, and it
// shall be illegal for that expression to contain an attribute instance;
// attribute instances cannot be nested. An attribute on an operator in an
// ordinary expression is legal, as is the attribute with the value 1 + 2.
// On the marked line the + inside the value of outer carries (* inner *),
// an error. Icarus Verilog 13.0 accepts the declaration, which the clause
// does not allow.

module test_illegal_attribute_value_contains_attribute;
  (* outer = 1 + 2 *) int a = 3;
  (* outer = 1 + (* inner *) 2 *) int b = 4;   // illegal: an attribute in the value

  initial $display("%0d", a + (* mode = "fast" *) b);
endmodule

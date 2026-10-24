/*
:name: test_illegal_type_reference_compared_with_value
:description: a type reference in an equality comparison shall only be compared with another type reference, not with a value (IEEE 1800-2023 Section 6.23)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.23
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the initializer of BAD compares the type reference type(a) with the value 32
:expected_stderr_regex: test_illegal_type_reference_compared_with_value\.sv:27:
*/
// IEEE 1800-2023 §6.23: a type reference may appear in ==, !=, === and !==,
// but only with another type reference as the other operand. The value of
// SAME compares two type references and is legal; the value of BAD compares
// the type reference type(a) with the number 32.
// The 5.052 release of Verilator rejects the line because it expects a
// type after ==.
// Icarus Verilog 13.0 does not parse type references and reports syntax
// errors on both localparams, an unsupported construct that is not this
// rule.

module test_illegal_type_reference_compared_with_value;
  int a;
  localparam bit SAME = (type(a) == type(int));
  localparam bit BAD = (type(a) == 32);   // illegal: type reference vs value
  initial $display("%0d %0d", SAME, BAD);
endmodule

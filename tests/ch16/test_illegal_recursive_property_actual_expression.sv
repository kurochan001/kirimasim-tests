/*
:name: test_illegal_recursive_property_actual_expression
:description: an actual argument of a recursive instance that uses a formal argument of the property has to be that formal itself or be bound to a local variable formal argument (IEEE 1800-2023 Section 16.12.17)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.12.17 16.12.19
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the actual n - 1 of the recursive instance of p_count uses the formal n, is not a formal itself, and is not bound to a local variable formal argument
:expected_stderr_regex: test_illegal_recursive_property_actual_expression\.sv:(31|32|35):
*/
// IEEE 1800-2023 §16.12.17, restriction 4: in a recursive instance, each
// actual argument shall be a formal argument of the declaring property,
// contain none of its formal arguments, or be bound to a local variable
// formal argument. In p_count the actual n - 1 contains the formal n, is not
// itself a formal, and n is an ordinary untyped formal, not a local variable
// formal argument (with local input int n it would be legal, §16.12.19). The
// actual p is the formal p itself, which is allowed. The rule is on the
// declaration, so a tool can report it there or where the assertion
// instantiates p_count.
// Icarus Verilog 13.0 does not support property declarations and reports
// syntax errors from their lines on, also on the line of the assertion; the
// 5.052 release of Verilator does not support recursive properties and
// rejects the line of the property declaration. Their errors do not count.

module test_illegal_recursive_property_actual_expression;
  logic clk = 0, go = 0, x = 0;

  property p_count(n, p);  // also reportable
    (n == 0) or (p and (1'b1 |=> p_count(n - 1, p)));  // illegal
  endproperty

  a_count: assert property (@(posedge clk) go |-> p_count(3, x));  // also reportable
endmodule

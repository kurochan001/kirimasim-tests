/*
:name: test_illegal_unpacked_concat_as_equality_operand
:description: an unpacked array concatenation can only be the source of an assignment-like context, so it cannot be an operand of an equality operator (IEEE 1800-2023 Section 10.10)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the braces {a2, b}, which would be an unpacked array concatenation only in an assignment-like context, are an operand of ==, where they are a vector concatenation with the unpacked array a2 as an operand
:expected_stderr_regex: test_illegal_unpacked_concat_as_equality_operand\.sv:32:
*/
// IEEE 1800-2023 §10.10: an unpacked array concatenation may appear as the
// source expression in an assignment-like context and shall not appear in
// any other context. The operands of == are not an assignment-like context
// (10.8), so there the braces are a concatenation of integral values, which
// cannot contain the unpacked array a2. a3 = {a2, b} and the comparison of a3
// with the array a3_ref are legal; the comparison of a3 with {a2, b} is not.
// Icarus Verilog 13.0 also rejects the legal assignment and comparison of
// whole unpacked arrays, so its error does not count.

module test_illegal_unpacked_concat_as_equality_operand;
  int a2 [2] = '{1, 2};
  int a3 [3];
  int a3_ref [3] = '{1, 2, 3};
  int b = 3;

  initial begin
    a3 = {a2, b};
    if (a3 == a3_ref) $display("equal");
    if (a3 == {a2, b}) $display("equal again");   // illegal: not an assignment-like context
  end
endmodule

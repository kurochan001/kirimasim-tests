/*
:name: test_illegal_unpacked_concat_with_type_prefix
:description: an unpacked array concatenation cannot be given an explicit type, which an array assignment pattern can (IEEE 1800-2023 Section 10.10.1)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.10.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the type name trio_t is put before the braces of the concatenation {b, c, b}
:expected_stderr_regex: test_illegal_unpacked_concat_with_type_prefix\.sv:29:
*/
// IEEE 1800-2023 §10.10.1: an array assignment pattern can be prefixed with a
// type name to form an assignment pattern expression of self-determined type,
// but unpacked array concatenations forbid explicit typing. trio_t'{b, c, b}
// and the concatenation {b, c, b} are legal; trio_t{b, c, b} is not.
// Icarus Verilog 13.0 gives a syntax error also on the legal assignment
// pattern expression trio_t'{b, c, b}, so its error does not count.

module test_illegal_unpacked_concat_with_type_prefix;
  typedef int trio_t [3];
  int a3 [3];
  int b = 2, c = 3;

  initial begin
    a3 = trio_t'{b, c, b};
    a3 = {b, c, b};
    a3 = trio_t{b, c, b};   // illegal: a type prefix on an unpacked array concatenation
    $display("%p", a3);
  end
endmodule

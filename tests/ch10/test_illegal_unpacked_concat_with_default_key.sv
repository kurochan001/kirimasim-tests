/*
:name: test_illegal_unpacked_concat_with_default_key
:description: an unpacked array concatenation does not support the default key, which an array assignment pattern does (IEEE 1800-2023 Section 10.10.1)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.10.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the braces {default: b} use a default key without the apostrophe of an assignment pattern
:expected_stderr_regex: test_illegal_unpacked_concat_with_default_key\.sv:29:
*/
// IEEE 1800-2023 §10.10.1: elements of an array assignment pattern can be
// defaulted with default:, but unpacked array concatenations forbid
// defaulting. '{default: b} and the concatenation {a1, b, b} are legal;
// {default: b} is not.
// Icarus Verilog 13.0 gives a syntax error also on the legal pattern with a
// default key, so its error does not count.

module test_illegal_unpacked_concat_with_default_key;
  int a1 [1] = '{1};
  int a3 [3];
  int b = 2;

  initial begin
    a3 = '{default: b};
    a3 = {a1, b, b};
    a3 = {default: b};   // illegal: no default key in an unpacked array concatenation
    $display("%p", a3);
  end
endmodule

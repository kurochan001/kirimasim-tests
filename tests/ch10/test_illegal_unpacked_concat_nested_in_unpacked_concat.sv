/*
:name: test_illegal_unpacked_concat_nested_in_unpacked_concat
:description: an unpacked array concatenation cannot be an item of another unpacked array concatenation, while a vector or string concatenation can (IEEE 1800-2023 Section 10.10.3)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.10.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the item {a1, b} inside the unpacked array concatenation for a4 would have to be an unpacked array concatenation itself
:expected_stderr_regex: test_illegal_unpacked_concat_nested_in_unpacked_concat\.sv:35:
*/
// IEEE 1800-2023 §10.10.3: each item of an unpacked array concatenation needs a
// self-determined type, which an unpacked array concatenation does not have,
// so one cannot be an item of another; braces inside are a vector or string
// concatenation. {c} as an item is the 32-bit vector of c and {"ab", s2} is a
// string, which is legal; {a1, b} as an item would contain the unpacked array
// a1.
// Icarus Verilog 13.0 cannot elaborate the legal unpacked array
// concatenations either; the 5.052 release of Verilator reports too few
// elements, taking {a1, b} as one element, so neither error counts.

module test_illegal_unpacked_concat_nested_in_unpacked_concat;
  int a1 [1] = '{1};
  int a2 [2] = '{2, 3};
  int a4 [4];
  int b = 4, c = 5;
  string s1 = "x", s2 = "y";
  string sq [$];

  initial begin
    a4 = {a2, {c}, b};
    sq = {s1, {"ab", s2}};
    a4 = {a2, {a1, b}};   // illegal: an unpacked array concatenation as an item
    $display("%p %p", a4, sq);
  end
endmodule

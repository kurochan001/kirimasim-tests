/*
:name: test_illegal_unpacked_concat_in_default_pattern_item
:description: a non-default item of an assignment pattern is an assignment-like context and can be an unpacked array concatenation, but a default item cannot (IEEE 1800-2023 Section 10.10.3)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.10.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the default item of the pattern for m is {a1, b}, which would have to be an unpacked array concatenation with the unpacked array a1
:expected_stderr_regex: test_illegal_unpacked_concat_in_default_pattern_item\.sv:30:
*/
// IEEE 1800-2023 §10.10.3: except for default: items, each item of an
// assignment pattern is in an assignment-like context (10.8), so it may be an
// unpacked array concatenation. The rows of m given as {b, c} and {a1, b} in
// a positional pattern are legal. A default item is not an assignment-like
// context, so its braces {a1, b} are a concatenation of integral values,
// which cannot contain the unpacked array a1.
// Icarus Verilog 13.0 does not support default keys, so its syntax error does
// not count; the design is accepted by the 5.052 release of Verilator.

module test_illegal_unpacked_concat_in_default_pattern_item;
  int a1 [1] = '{1};
  int m [2][2];
  int b = 2, c = 3;

  initial begin
    m = '{{b, c}, {a1, b}};
    m = '{default: {a1, b}};   // illegal: a default item is not assignment-like
    $display("%p", m);
  end
endmodule

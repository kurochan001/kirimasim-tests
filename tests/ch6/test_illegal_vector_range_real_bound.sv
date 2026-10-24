/*
:name: test_illegal_vector_range_real_bound
:description: a bound of a vector range has to be a constant integer expression; a real parameter is illegal (IEEE 1800-2023 Section 6.9.1)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.9.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the msb of the range of bad is the real parameter R, which is not an integer expression
:expected_stderr_regex: test_illegal_vector_range_real_bound\.sv:33:
*/
// IEEE 1800-2023 §6.9.1: the msb and lsb of a vector range shall be constant
// integer expressions; they can be any integer value, positive, negative or
// zero, the lsb can be greater than, equal to or less than the msb, and it
// is illegal for them to contain x or z bits. The legal vectors use a
// negative bound, a zero bound, an lsb above the msb, equal bounds and
// bounds computed from a parameter; their widths are printed.
// The msb of bad is a real parameter, a constant that is not an integer.
// Icarus Verilog 13.0 accepts the design. The 5.052 release rejects the
// line with a message about the width of the value 3.0 rather than its type,
// which is not counted.

module test_illegal_vector_range_real_bound;
  parameter int P = 2;
  parameter real R = 3.0;
  logic [-1:4] neg;
  bit [0:3] up;
  logic [5:5] one;
  logic [P*2:P-1] calc;
  initial $display("%0d %0d %0d %0d", $bits(neg), $bits(up), $bits(one), $bits(calc));
  logic [R:0] bad;   // illegal: a real msb
endmodule

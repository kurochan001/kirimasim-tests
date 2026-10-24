/*
:name: test_illegal_vector_range_x_bound
:description: a bound of a vector range cannot contain an x bit (IEEE 1800-2023 Section 6.9.1)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.9.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:should_fail_because: the msb of the range of bad contains an x bit
:expected_stderr_regex: test_illegal_vector_range_x_bound\.sv:30:
*/
// IEEE 1800-2023 §6.9.1: the msb and lsb of a vector range shall be constant
// integer expressions; they can be any integer value, positive, negative or
// zero, the lsb can be greater than, equal to or less than the msb, and it
// is illegal for them to contain x or z bits. The legal vectors use a
// negative bound, a zero bound, an lsb above the msb, equal bounds and
// bounds computed from a parameter; their widths are printed.
// The msb of bad is a constant with an x bit.
// Icarus Verilog 13.0 accepts the design.

module test_illegal_vector_range_x_bound;
  parameter int P = 2;
  logic [-1:4] neg;
  bit [0:3] up;
  logic [5:5] one;
  logic [P*2:P-1] calc;
  initial $display("%0d %0d %0d %0d", $bits(neg), $bits(up), $bits(one), $bits(calc));
  logic [4'b01x1:0] bad;   // illegal: x bit in the msb
endmodule

/*
:name: test_illegal_bit_select_of_scalar_net
:description: a bit-select of a scalar net is illegal (IEEE 1800-2023 Section 11.5.1)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.5.1
:oracle: spec iverilog@13.0 verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a bit-select is applied to the scalar net w, which has no packed dimension
:expected_stderr_regex: test_illegal_bit_select_of_scalar_net\.sv:25:
*/
// IEEE 1800-2023 §11.5.1: a bit-select or a part-select of a scalar is
// illegal. The net w is declared without a packed dimension, so it is a
// scalar, and w[0] selects a bit of it. The same select of the one-bit
// vector net v, declared [0:0], is legal.

module test_illegal_bit_select_of_scalar_net;
  wire w = 1'b1;
  wire [0:0] v = 1'b1;
  wire a, b;

  assign a = v[0];
  assign b = w[0];   // illegal: bit-select of a scalar net
endmodule

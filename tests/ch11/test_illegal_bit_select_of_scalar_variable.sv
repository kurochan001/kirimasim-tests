/*
:name: test_illegal_bit_select_of_scalar_variable
:description: a bit-select of a scalar variable is illegal (IEEE 1800-2023 Section 11.5.1)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.5.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a bit-select is applied to the scalar variable s
:expected_stderr_regex: test_illegal_bit_select_of_scalar_variable\.sv:25:
*/
// IEEE 1800-2023 §11.5.1: a bit-select or a part-select of a scalar is
// illegal. s is a 1-bit logic declared without a packed dimension, and s[0]
// selects a bit of it; the select of the one-bit vector w[0:0] is legal.

module test_illegal_bit_select_of_scalar_variable;
  logic s = 1'b1;
  logic [0:0] w = 1'b1;
  logic b, c;

  initial begin
    c = w[0];
    b = s[0];   // illegal: bit-select of a scalar
  end
endmodule

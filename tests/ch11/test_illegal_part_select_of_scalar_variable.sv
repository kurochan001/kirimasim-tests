/*
:name: test_illegal_part_select_of_scalar_variable
:description: a part-select of a scalar variable is illegal (IEEE 1800-2023 Section 11.5.1)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.5.1
:oracle: spec iverilog@13.0 verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a part-select is applied to the scalar variable s, which has no packed dimension
:expected_stderr_regex: test_illegal_part_select_of_scalar_variable\.sv:26:
*/
// IEEE 1800-2023 §11.5.1: a bit-select or a part-select of a scalar is
// illegal. The variable s is a logic declared without a packed dimension, so
// it is a scalar, and s[0:0] is a part-select of it. The same part-select of
// the one-bit vector v, declared [0:0], is legal.

module test_illegal_part_select_of_scalar_variable;
  logic s = 1'b1;
  logic [0:0] v = 1'b1;
  logic [0:0] a, b;

  initial begin
    a = v[0:0];
    b = s[0:0];   // illegal: part-select of a scalar variable
  end
endmodule

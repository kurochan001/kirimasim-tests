/*
:name: test_illegal_bit_select_of_real_variable
:description: a bit-select of a real variable is illegal (IEEE 1800-2023 Section 11.5.1)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.5.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a bit-select is applied to the real variable r
:expected_stderr_regex: test_illegal_bit_select_of_real_variable\.sv:25:
*/
// IEEE 1800-2023 §11.5.1: a bit-select or a part-select of a real variable
// or real parameter is illegal. r[0] selects a bit of the real r; the same
// select of the logic vector v is legal.

module test_illegal_bit_select_of_real_variable;
  real r = 1.0;
  logic [7:0] v = 8'h01;
  logic b, c;

  initial begin
    c = v[0];
    b = r[0];   // illegal: bit-select of a real variable
  end
endmodule

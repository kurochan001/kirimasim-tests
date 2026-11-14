/*
:name: test_illegal_part_select_of_real_variable
:description: a part-select of a real variable is illegal (IEEE 1800-2023 Section 11.5.1)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.5.1
:oracle: spec iverilog@13.0 verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a part-select is applied to the real variable r
:expected_stderr_regex: test_illegal_part_select_of_real_variable\.sv:25:
*/
// IEEE 1800-2023 §11.5.1: a bit-select or a part-select of a real variable
// or of a real parameter is illegal. r[3:0] is a part-select of the real
// variable r; the same part-select of the logic vector v is legal.

module test_illegal_part_select_of_real_variable;
  real r = 3.0;
  logic [7:0] v = 8'h5a;
  logic [3:0] a, b;

  initial begin
    a = v[3:0];
    b = r[3:0];   // illegal: part-select of a real variable
  end
endmodule

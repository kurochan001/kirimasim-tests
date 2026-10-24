/*
:name: test_illegal_indexed_part_select_nonconstant_width
:description: the width of an indexed part-select that is not a constant expression is illegal (IEEE 1800-2023 Section 11.5.1)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.5.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the width of the indexed part-select v[0 +: w] is the variable w
:expected_stderr_regex: test_illegal_indexed_part_select_nonconstant_width\.sv:27:
*/
// IEEE 1800-2023 §11.5.1: the width of an indexed part-select [base +: width]
// shall be a positive constant integer expression, while its base can vary
// at run time. v[b +: 4] has a variable base and is legal; v[0 +: w] has a
// variable width.

module test_illegal_indexed_part_select_nonconstant_width;
  logic [7:0] v = 8'h5a;
  logic [3:0] r, q;
  int b = 2;
  int w = 4;

  initial begin
    q = v[b +: 4];
    r = v[0 +: w];   // illegal: variable width
  end
endmodule

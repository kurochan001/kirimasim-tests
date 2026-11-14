/*
:name: test_illegal_part_select_nonconstant_lsb
:description: the second bound of a non-indexed part-select has to be a constant expression (IEEE 1800-2023 Section 11.5.1)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.5.1
:oracle: spec iverilog@13.0 verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the second bound of the non-indexed part-select v[7:k] is the variable k
:expected_stderr_regex: test_illegal_part_select_nonconstant_lsb\.sv:28:
*/
// IEEE 1800-2023 §11.5.1: both bounds of a non-indexed part-select
// [msb_expr:lsb_expr] shall be constant integer expressions. v[7:L] has the
// localparam L as its second bound, which is legal; v[7:k] has the variable
// k there, which is not a constant expression. The first bound is a
// constant in both selects.

module test_illegal_part_select_nonconstant_lsb;
  localparam int L = 4;
  logic [7:0] v = 8'h5a;
  int k = 4;
  logic [3:0] a, b;

  initial begin
    a = v[7:L];
    b = v[7:k];   // illegal: the second bound is not a constant expression
  end
endmodule

/*
:name: test_illegal_part_select_nonconstant_bound
:description: a non-indexed part-select with a bound that is not a constant expression is illegal (IEEE 1800-2023 Section 11.5.1)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.5.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the most significant bound of the non-indexed part-select v[i:0] is the variable i
:expected_stderr_regex: test_illegal_part_select_nonconstant_bound\.sv:27:
*/
// IEEE 1800-2023 §11.5.1: both bounds of a non-indexed part-select [msb:lsb]
// shall be constant integer expressions. v[i:0] uses the variable i as its
// first bound; the indexed part-select v[i -: 2], whose base may vary at run
// time, is legal.

module test_illegal_part_select_nonconstant_bound;
  logic [7:0] v = 8'h5a;
  logic [3:0] r;
  logic [1:0] q;
  int i = 3;

  initial begin
    q = v[i -: 2];
    r = v[i:0];   // illegal: variable bound in a non-indexed part-select
  end
endmodule

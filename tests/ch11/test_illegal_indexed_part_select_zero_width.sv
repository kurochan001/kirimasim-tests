/*
:name: test_illegal_indexed_part_select_zero_width
:description: an indexed part-select with a width of zero is illegal (IEEE 1800-2023 Section 11.5.1)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.5.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the width of the indexed part-select v[2 +: 0] is the constant 0, which is not positive
:expected_stderr_regex: test_illegal_indexed_part_select_zero_width\.sv:25:
*/
// IEEE 1800-2023 §11.5.1: the width of an indexed part-select shall be a
// positive constant integer expression. v[2 +: 1] is legal; v[2 +: 0] has
// the constant width 0.

module test_illegal_indexed_part_select_zero_width;
  logic [7:0] v = 8'h5a;
  logic [0:0] q;
  logic r;

  initial begin
    q = v[2 +: 1];
    r = v[2 +: 0];   // illegal: width 0
  end
endmodule

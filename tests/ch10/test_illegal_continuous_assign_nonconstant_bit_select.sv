/*
:name: test_illegal_continuous_assign_nonconstant_bit_select
:description: the left-hand side of a continuous assignment can be a net or variable, a constant bit-select or part-select of one, or a concatenation of these, but not a bit-select with a nonconstant index (IEEE 1800-2023 Section 10.2)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the continuous assignment writes sel_w[idx], a bit-select of a net whose index is the variable idx
:expected_stderr_regex: test_illegal_continuous_assign_nonconstant_bit_select\.sv:41:
*/
// IEEE 1800-2023 §10.2, Table 10-1: the left-hand side of a continuous
// assignment is a net or variable (scalar or vector), a constant bit-select or
// a constant part-select of a vector net or packed variable, or a
// concatenation or nested concatenation of these. The module uses each of
// these forms; the last continuous assignment selects a bit of sel_w with the
// variable idx, which is not a constant.
// The design is accepted by Verilator 5.052.

module test_illegal_continuous_assign_nonconstant_bit_select;
  logic a = 1'b1;
  int idx = 1;
  wire w;
  logic v;
  wire [3:0] wv;
  logic [7:0] pv;
  logic [7:0] pq;
  wire [1:0] cc;
  logic [3:0] lo, hi;
  wire [3:0] sel_w;

  assign w = a;
  assign v = a;
  assign wv[0] = a;
  assign wv[3:1] = 3'b101;
  assign pv[7] = a;
  assign pq[3:0] = 4'h9;
  assign {cc, {lo, hi}} = 10'h2a5;
  assign sel_w[idx] = a;   // illegal: the index of the bit-select is not constant

  initial #1 $display("%b %b %b %b %h", w, v, wv, cc, {lo, hi});
endmodule

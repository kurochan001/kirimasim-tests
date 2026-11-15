/*
:name: test_illegal_cg_matches_negative
:description: a cross bin matches clause uses a negative constant as its policy (IEEE 1800-2023 Section 19.6.1.2)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.6.1.2
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the matches clause of the cross bin neg gives -1, but its expression shall be a positive integer or $
:expected_stderr_regex: test_illegal_cg_matches_negative\.sv:35:
*/
// IEEE 1800-2023 §19.6.1.2: the expression of a matches clause shall give a
// positive integer, the least number of value tuples that have to satisfy
// the with expression, or $ for all of them. The bins one and all of the
// cross x use 1 and $, which are allowed; the bin neg uses the constant -1,
// which is below 1, and is the one error. With 2 in place of -1 the design
// is legal.
//
// Oracle check: the 5.054 release of Verilator reports on the named line
// that the matches count is below 1, and accepts the design with 2 in place
// of -1. Icarus Verilog 13.0 does not implement covergroups; its syntax
// errors are no evidence for the rule.

module test_illegal_cg_matches_negative;
  bit [1:0] a, b;

  covergroup cg;
    ca: coverpoint a { bins lo = {[0:1]}; bins hi = {[2:3]}; }
    cb: coverpoint b { bins lo = {[0:1]}; bins hi = {[2:3]}; }
    x: cross ca, cb {
      bins one = x with (ca == cb) matches 1;
      bins all = x with (ca <= cb) matches $;
      bins neg = x with (ca >= cb) matches -1;   // illegal: not positive
    }
  endgroup

  cg g = new;

  initial $display("not reached");
endmodule

/*
:name: test_illegal_cg_cross_bin_ref_formal
:description: a cross bin uses a ref argument of the covergroup in its intersect list (IEEE 1800-2023 Section 19.6)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.6
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the intersect list of the cross bin bad uses r, a ref argument of the covergroup
:expected_stderr_regex: test_illegal_cg_cross_bin_ref_formal\.sv:37:
*/
// IEEE 1800-2023 §19.6: identifiers and function calls in a cross obey the
// same restrictions as in a coverpoint (19.5). A covergroup_expression, such
// as a value in the intersect list of a cross bin (Syntax 19-4), may use as
// variables only constant expressions, class constants and non-ref
// arguments of the covergroup. The bin ok of the cross x uses the input
// argument k, which is allowed; the bin bad uses the ref argument r, which
// is the one error. With k in place of r in bad, or with r made an input,
// the design is legal.
//
// Oracle check: the 5.054 release of Verilator reports on the named line
// that the ref argument r may not be used in a covergroup expression, and
// accepts the design with k in place of r. Icarus Verilog 13.0 does not
// implement covergroups; its syntax errors are no evidence for the rule.

module test_illegal_cg_cross_bin_ref_formal;
  bit [1:0] a, b;
  int store = 2;

  covergroup cg (ref int r, input int k);
    ca: coverpoint a;
    cb: coverpoint b;
    x: cross ca, cb {
      bins ok = binsof(ca) intersect {k};
      bins bad = binsof(cb) intersect {r};   // illegal: ref argument
    }
  endgroup

  cg g = new(store, 1);

  initial $display("not reached");
endmodule

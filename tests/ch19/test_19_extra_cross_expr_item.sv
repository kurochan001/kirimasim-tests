/*
:name: test_19_extra_cross_expr_item
:description: An expression is not a cross item; it needs an explicit coverpoint, so crossing cp with a + 1 is an error (IEEE 1800-2023 Section 19.6)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the second cross item is a + 1, an expression that has no explicit coverpoint
:expected_stderr_regex: test_19_extra_cross_expr_item\.sv:26:
*/
// IEEE 1800-2023 §19.6: the items of a cross are coverpoints. An integral
// variable used directly becomes an implicit coverpoint, but any other
// expression must first be given an explicit coverpoint and that coverpoint
// used as the item. So cross cp, a + 1 is illegal. Verilator 5.052 reports a
// syntax error at the +, which is where the expression stands where a cross
// item is required.

module test_19_extra_cross_expr_item;
  bit [1:0] a;

  covergroup cg;
    cp: coverpoint a { bins v[] = {[0:3]}; }
    cr: cross cp, a + 1;   // illegal: an expression needs a coverpoint
  endgroup
endmodule

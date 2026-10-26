/*
:name: test_illegal_cg_cross_one_item
:description: a cross declares only one item (IEEE 1800-2023 Section 19.6)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the cross cr has a single item, cp, but a cross needs at least two
:expected_stderr_regex: test_illegal_cg_cross_one_item\.sv:25:
*/
// A cross specifies cross coverage between two or more coverage points,
// so its list of cross items holds at least two items.
//
// Icarus Verilog 13.0 does not implement covergroups; its cascading
// syntax errors fall on every line of the construct, including the line
// named below, so they are no evidence for the rule there. The cited
// clause alone decides this test.

module test_illegal_cg_cross_one_item;
  covergroup cg(input int a);
    cp: coverpoint a;
    cr: cross cp;   // illegal: a cross needs two items
  endgroup
endmodule

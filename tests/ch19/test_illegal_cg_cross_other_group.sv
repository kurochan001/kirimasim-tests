/*
:name: test_illegal_cg_cross_other_group
:description: a cross names a coverpoint that belongs to another covergroup (IEEE 1800-2023 Section 19.6)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the cross cr of g2 crosses pa, a coverpoint of the other covergroup g1
:expected_stderr_regex: test_illegal_cg_cross_other_group\.sv:25:
*/
// Crossed coverpoints shall belong to the covergroup that contains the
// cross. The cross cr of g2 names pa, which is a coverpoint of the other
// embedded covergroup g1.

module test_illegal_cg_cross_other_group;
  class c;
    covergroup g1(input int a);
      pa: coverpoint a;
    endgroup
    covergroup g2(input int b);
      pb: coverpoint b;
      cr: cross pa, pb;   // illegal: pa is not a coverpoint of g2
    endgroup
  endclass
endmodule

/*
:name: test_illegal_cg_self_point_range
:description: the name of the containing coverpoint may stand for all its values in a bin, while the name of another coverpoint shall not (IEEE 1800-2023 Section 19.5.1.1)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.5.1.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the bin bad of coverpoint pb names pa, a different coverpoint
:expected_stderr_regex: test_illegal_cg_self_point_range\.sv:30:
*/
// IEEE 1800-2023 §19.5.1.1: the name of the coverpoint whose bin is being
// defined may be used in place of the covergroup_range_list to denote all
// values of that coverpoint, and no other coverpoint name is permitted. In
// coverpoint pa, the bins all and odd use pa itself, which is allowed. In
// coverpoint pb, the bin bad names pa, which is another coverpoint and is the
// one error.

module test_illegal_cg_self_point_range;
  bit [1:0] a, b;

  covergroup cg;
    pa: coverpoint a {
      bins all[] = pa with (item >= 0);
      bins odd[] = pa with (item % 2 == 1);
    }
    pb: coverpoint b {
      bins bad[] = pa with (item >= 0);   // illegal: another coverpoint
    }
  endgroup

  cg g = new;

  initial begin
    $display("not reached");
  end
endmodule

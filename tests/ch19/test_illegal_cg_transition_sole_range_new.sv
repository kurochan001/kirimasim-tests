/*
:name: test_illegal_cg_transition_sole_range_new
:description: a transition bin whose trans_set is a single value range, with no transition, is of length zero and illegal (IEEE 1800-2023 Section 19.5.2)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.5.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the bin span is a single range [0:1] with no transition, a transition set of length zero
:expected_stderr_regex: test_illegal_cg_transition_sole_range_new\.sv:27:
*/
// IEEE 1800-2023 §19.5.2: a transition bin specification of length 0 is
// illegal, and a trans_set that is only a single covergroup_value_range is
// such a specification. The bin range uses [0:1] as the first range of a
// transition to 2, which is a length-1 transition, and rep uses 0[*2]; both
// are legal. The bin span is only the range [0:1], which is the one error.

module test_illegal_cg_transition_sole_range_new;
  bit [2:0] a;

  covergroup cg;
    cp: coverpoint a {
      bins range = ([0:1] => 2);
      bins rep = (0 [* 2]);
      bins span = ([0:1]);   // illegal: a single range with no transition
    }
  endgroup

  cg g = new;

  initial begin
    $display("not reached");
  end
endmodule

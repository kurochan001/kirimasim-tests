/*
:name: test_illegal_cg_transition_repeat_one
:description: a transition bin specification of length zero is illegal, including a single value with a repeat range that evaluates to one (IEEE 1800-2023 Section 19.5.2)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.5.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the bin once is the single value 0 repeated one time, a transition of length zero
:expected_stderr_regex: test_illegal_cg_transition_repeat_one\.sv:28:
*/
// IEEE 1800-2023 §19.5.2: a transition bin specification of length 0 is
// illegal. These are a trans_set of a single covergroup_value_range, such as
// (0) or ([0:1]), and a single value range with a repeat range that
// evaluates to 1, such as (0[*1]) or ([0:1][*1]). The bin twice uses 0[*2],
// a transition of length 1, and the bin step uses 0=>1; both are legal. The
// bin once uses 0[*1] and is the one error.

module test_illegal_cg_transition_repeat_one;
  bit [2:0] a;

  covergroup cg;
    cp: coverpoint a {
      bins twice = (0 [* 2]);
      bins step = (0 => 1);
      bins once = (0 [* 1]);   // illegal: length zero
    }
  endgroup

  cg g = new;

  initial begin
    $display("not reached");
  end
endmodule

/*
:name: test_illegal_cg_real_transition_domain
:description: a coverpoint of a real expression may use sampled value bins and crosses but not a transition bin, because transition bins take integral values only (IEEE 1800-2023 Sections 19.5, 19.5.2)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.5 19.5.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the real coverpoint bad defines the transition bin t, and transitions of real values are not allowed
:expected_stderr_regex: test_illegal_cg_real_transition_domain\.sv:(36|37):
*/
// IEEE 1800-2023 §19.5: a coverpoint specifies an integral or real
// expression; coverage of a real expression is limited to sampled value bins
// and their crosses. §19.5.2: a transition bin specifies ordered integral
// value transitions; transitions of real values are not allowed. The real
// coverpoint rv has two value bins and takes part in cross rx with the
// integral transition coverpoint iv, and iv has an integral transition bin,
// so all the permitted forms are present. The transition bin of the real
// coverpoint bad is the one error.

module test_illegal_cg_real_transition_domain;
  real r;
  bit [2:0] v;

  covergroup cg;
    rv: coverpoint r {
      bins lo = {[0.0:1.0]};
      bins hi = {[2.0:3.0]};
    }
    iv: coverpoint v {
      bins t = (1 => 2);
    }
    rx: cross rv, iv;
    bad: coverpoint r {
      bins t = (1.0 => 2.0);   // illegal: transition of a real value
    }
  endgroup

  initial begin
    $display("not reached");
  end
endmodule

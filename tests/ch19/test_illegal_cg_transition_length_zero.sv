/*
:name: test_illegal_cg_transition_length_zero
:description: A transition bin whose transition is a single value, of length 0, is illegal (IEEE 1800-2023 Section 19.5.2)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.5.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the transition bin once has a transition of length 0
:expected_stderr_regex: test_illegal_cg_transition_length_zero\.sv:25:
*/
// IEEE 1800-2023 §19.5.2: a transition bin specification of length 0 is
// illegal: a transition set made of a single value range, as (4) here, or of a
// single value range with a repetition that evaluates to 1, which describes no
// transition between two samples. Icarus Verilog 13.0 does not support
// covergroups, so the syntax error it reports on that line does not count.

module test_illegal_cg_transition_length_zero;
  bit [2:0] v;

  covergroup cg;
    cp: coverpoint v {
      bins once = (4);   // illegal: a transition of length 0
      bins pair = (4 => 5);
    }
  endgroup

  cg inst = new();

  initial begin
    v = 4;
    inst.sample();
    v = 5;
    inst.sample();
    $display("%.2f", inst.get_inst_coverage());
  end
endmodule

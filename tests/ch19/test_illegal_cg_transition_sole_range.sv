/*
:name: test_illegal_cg_transition_sole_range
:description: A transition bin whose transition set is a single value range, of length 0, is illegal (IEEE 1800-2023 Section 19.5.2)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.5.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the transition bin span is a single range with no transition, of length 0
:expected_stderr_regex: test_illegal_cg_transition_sole_range\.sv:26:
*/
// IEEE 1800-2023 §19.5.2: transition bin specifications of length 0 are
// illegal; such a trans_set is a single covergroup_value_range, which can be a
// range of values as well as a single value. The bin span is ([1:2]), a single
// range with no =>; the bin pair is legal. Icarus Verilog 13.0 does not
// support covergroups, so the syntax error it reports on that line does not
// count.

module test_illegal_cg_transition_sole_range;
  bit [2:0] v;

  covergroup cg;
    cp: coverpoint v {
      bins span = ([1:2]);   // illegal: a transition of length 0
      bins pair = (1 => 2);
    }
  endgroup

  cg inst = new();

  initial begin
    v = 1;
    inst.sample();
    v = 2;
    inst.sample();
    $display("%.2f", inst.get_inst_coverage());
  end
endmodule

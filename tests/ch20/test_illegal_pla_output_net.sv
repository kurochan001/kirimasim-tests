/*
:name: test_illegal_pla_output_net
:description: a PLA task is given nets as its output terms (IEEE 1800-2023 Section 20.16)
:tags: ch20
:type: elaboration
:lrm: 1800-2023 20.16
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the output terms of $async$and$array are wire b1 and wire b2
:expected_stderr_regex: test_illegal_pla_output_net\.sv:22:
*/
// PLA input terms may be nets or variables, but the output terms shall
// be variable lvalues. The terms b1 and b2 here are wire nets.

module test_illegal_pla_output_net;
  logic [1:2] mem [1:2];
  logic a1, a2;
  wire b1, b2;
  initial begin
    $async$and$array(mem, {a1, a2}, {b1, b2});   // illegal: nets as outputs
  end
endmodule

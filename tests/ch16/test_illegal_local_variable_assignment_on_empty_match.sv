/*
:name: test_illegal_local_variable_assignment_on_empty_match
:description: a local variable assignment cannot be attached to a subsequence that admits an empty match (IEEE 1800-2023 Sections 16.10 and 16.11)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.10 16.11
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the assignment k = d in p_bad is attached to b[*0:2], which admits an empty match
:expected_stderr_regex: test_illegal_local_variable_assignment_on_empty_match\.sv:(32|35):
*/
// IEEE 1800-2023 §16.10 and §16.11: the subsequence to which a local variable
// assignment, or any sequence match item, is attached shall not admit an
// empty match. In p_ok the assignment is attached to a ##1 b[*0:2], whose
// matches are at least one cycle long; in p_bad it is attached to b[*0:2],
// which matches with zero repetitions.
// A tool can report the error in p_bad or at its assertion a_bad.
// Icarus Verilog 13.0 does not support concurrent assertions, and Verilator
// 5.052 rejects the legal p_ok for another reason; neither error counts.

module test_illegal_local_variable_assignment_on_empty_match;
  logic clk = 0, a = 0, b = 0, c = 0;
  int d = 0;
  property p_ok;
    int k;
    (a ##1 b[*0:2], k = d) ##1 (c == k);
  endproperty
  property p_bad;
    int k;
    a ##1 (b[*0:2], k = d) ##1 (c == k);   // illegal
  endproperty
  a_ok: assert property (@(posedge clk) p_ok);
  a_bad: assert property (@(posedge clk) p_bad);
endmodule

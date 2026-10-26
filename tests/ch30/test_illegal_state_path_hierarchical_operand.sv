/*
:name: test_illegal_state_path_hierarchical_operand
:description: a state-dependent path condition uses a hierarchical reference (IEEE 1800-2023 Section 30.4.4.1)
:tags: ch30
:type: elaboration
:lrm: 1800-2023 30.4.4.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the conditional path expression uses the hierarchical reference u.c
:expected_stderr_regex: test_illegal_state_path_hierarchical_operand\.sv:24:
*/
// The operands of a state-dependent path conditional expression are
// scalar or vector module input or inout ports, local variables or nets,
// and constants. The operand u.c is a hierarchical reference.

module other;
  logic c;
endmodule
module t(input logic a, output logic b);
  other u();
  specify
    if (u.c) (a => b) = 5;   // illegal: hierarchical operand
  endspecify
endmodule

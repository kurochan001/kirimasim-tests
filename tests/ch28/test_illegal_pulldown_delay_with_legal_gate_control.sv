/*
:name: test_illegal_pulldown_delay_with_legal_gate_control
:description: A pulldown cannot specify a delay even beside a gate that accepts three delays
:tags: ch28
:type: elaboration
:lrm: 1800-2023 28.3.3 28.10
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the pulldown source specifies a propagation delay
:expected_stderr_regex: test_illegal_pulldown_delay_with_legal_gate_control\.sv:20:(?:\d+:)?[^\n]*(?i:(?:delay|syntax error|unexpected).*)
*/
// The three delays are legal on a three-state buffer. The pulldown has
// no delay form and must be rejected at its declaration.
module test_illegal_pulldown_delay_with_legal_gate_control;
  wire immediate, delayed, low;
  buf (immediate, 1'b1);
  bufif1 #(2, 3, 5) delayed_gate(delayed, 1'b1, 1'b0);
  pulldown #2 source(low); // illegal
endmodule

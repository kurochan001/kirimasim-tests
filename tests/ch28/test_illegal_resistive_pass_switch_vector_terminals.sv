/*
:name: test_illegal_resistive_pass_switch_vector_terminals
:description: A scalar resistive pass switch requires scalar nets or vector bit selects
:tags: ch28
:type: elaboration
:lrm: 1800-2023 28.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the bad switch connects whole vectors to single bidirectional terminals
:expected_stderr_regex: test_illegal_resistive_pass_switch_vector_terminals\.sv:18:(?:\d+:)?[^\n]*(?i:(?:width|scalar|bits|cannot connect|expects))
*/
module test_illegal_resistive_pass_switch_vector_terminals;
  wire [1:0] left, right;
  // A bit select is a legal terminal in the same design.
  rtranif1 good(left[0], right[0], 1'b1);
  rtranif1 bad(left, right, 1'b0); // illegal
endmodule

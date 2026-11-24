/*
:name: test_illegal_three_state_gate_swapped_highz_strengths
:description: A three state gate rejects both high impedance strengths with highz1 written first
:tags: ch28
:type: elaboration
:lrm: 1800-2023 28.3.2 28.11
:oracle: spec iverilog@13.0 verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: both output strengths of the invalid buffer are high impedance
:expected_stderr_regex: test_illegal_three_state_gate_swapped_highz_strengths\.sv:19:(?:\d+:)?[^\n]*(?i:(?:syntax error|highz|drive strength|unexpected).*)
*/
module test_illegal_three_state_gate_swapped_highz_strengths;
  wire zero_path, one_path, invalid_path;
  // The first two gates suppress only one logic value.
  bufif1 (highz1, strong0) suppress_one(zero_path, 1'b0, 1'b1);
  bufif1 (highz0, strong1) suppress_zero(one_path, 1'b1, 1'b1);
  bufif1 (highz1, highz0) invalid(invalid_path, 1'b1, 1'b1); // illegal
endmodule

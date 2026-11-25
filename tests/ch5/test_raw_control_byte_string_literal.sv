/*
:name: test_raw_control_byte_string_literal
:description: An implementation that supports literal vertical-tab bytes preserves the same string bytes as the escaped form
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.9 5.9.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_raw_control_byte_string_literal.expected
*/
// The first quoted literal contains an actual 0x0B byte between L and R.
// Keep that byte in the source. Support for raw nonprintable ASCII is
// implementation-dependent under 5.9. The escaped literal is a control.
module test_raw_control_byte_string_literal;
  localparam using_raw = "LR";
  localparam escaped = "L\vR";

  initial $display("raw=%06h escaped=%06h", using_raw, escaped);
endmodule

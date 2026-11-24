/*
:name: test_illegal_stream_with_real_base_for_integral_range
:description: A streaming with range requires an integral index even if a real value is exactly representable
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.4.14.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the base of the streaming range has real type rather than integral type
:expected_stderr_regex: test_illegal_stream_with_real_base_for_integral_range\.sv:18:(?:\d+:)?[^\n]*(?i:(?:\breal\b[^\n]*(?:integral|select|range|index)|(?:integral|select|range|index)[^\n]*\breal\b|requires an integral))
*/
module test_illegal_stream_with_real_base_for_integral_range;
  byte first_bytes [4];
  real base_index = 1.0;
  initial begin
    {>>{first_bytes with [base_index +: 2]}} = 16'ha1b2; // illegal
    $display("unexpected assignment");
  end
endmodule

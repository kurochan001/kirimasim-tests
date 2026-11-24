/*
:name: test_illegal_interconnect_two_equal_delay_values
:description: An interconnect cannot specify two delay values even when they are equal
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.7.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: two delay values are supplied in the interconnect declaration
:expected_stderr_regex: test_illegal_interconnect_two_equal_delay_values\.sv:24:(?:\d+:)?[^\n]*(?i:(?:interconnect[^\n]*(?:one|single|multiple|delay)|delay[^\n]*interconnect))
*/
`timescale 1ns/1ns
module interconnect_source(input bit drive, output wire signal_value);
  assign signal_value = drive;
endmodule
module interconnect_sink(input wire signal_value, output wire observed);
  assign observed = signal_value;
endmodule
module test_illegal_interconnect_two_equal_delay_values;
  bit drive;
  wire observed;
  interconnect #(2, 2) link_value; // illegal
  interconnect_source source(drive, link_value);
  interconnect_sink sink(link_value, observed);
  initial #10 $display("observed=%b", observed);
endmodule

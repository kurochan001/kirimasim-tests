/*
:name: test_illegal_timeformat_unit_out_of_range
:description: the $timeformat unit exponent is -16, outside -15 through 2 (IEEE 1800-2023 Section 20.4.3)
:tags: ch20
:type: elaboration
:lrm: 1800-2023 20.4.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the unit argument of $timeformat is -16, below the allowed -15
:expected_stderr_regex: test_illegal_timeformat_unit_out_of_range\.sv:21:
*/
// The unit exponent of $timeformat is an integer from -15 through 2 and
// names one of the time units of Table 20-2. The call here uses -16.

`timescale 1ns/1ns

module test_illegal_timeformat_unit_out_of_range;
  initial begin
    $timeformat(-16, 2, "ns", 10);   // illegal: unit below -15
    $display("built");
  end
endmodule

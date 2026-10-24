/*
:name: test_illegal_timescale_factor_not_allowed
:description: The integers of `timescale can only be 1, 10 or 100, so a time unit of 1000 ps is an error (IEEE 1800-2023 Section 22.7)
:tags: ch22
:type: elaboration
:lrm: 1800-2023 22.7
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the time unit of the `timescale directive uses the factor 1000, which is not 1, 10 or 100
:expected_stderr_regex: test_illegal_timescale_factor_not_allowed\.sv:19:
*/
// IEEE 1800-2023 §22.7: the integers in the time_unit and time_precision
// arguments of `timescale give an order of magnitude, and only 1, 10 and
// 100 are valid. The unit 1000 ps names a valid length of time (1 ns), but
// its factor is 1000, which is not one of the valid integers.

`timescale 1000ps / 1ps  // illegal: 1000 is not a valid factor

module test_illegal_timescale_factor_not_allowed;
  initial #1 $display("done");
endmodule

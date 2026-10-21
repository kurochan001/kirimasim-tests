/*
:name: test_illegal_timescale_precision_coarse
:description: A `timescale whose time precision is coarser than its time unit is illegal (IEEE 1800-2023 Section 3.14.2.1)
:tags: ch3
:type: elaboration
:lrm: 1800-2023 3.14.2.1 3.14.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the time precision 10ns of the `timescale is coarser than its time unit 1ns
:expected_stderr_regex: test_illegal_timescale_precision_coarse\.sv:20:
*/
// IEEE 1800-2023 §3.14.2.1: the time precision of a `timescale shall be at
// least as fine as its time unit, since a delay is expressed as a multiple of
// the precision within the unit (§3.14.1). The directive below gives a unit
// of 1ns and a precision of 10ns, which is an error. Both releases reject the
// design on the line of the directive.

`timescale 1ns / 10ns

module test_illegal_timescale_precision_coarse;
  initial #1 $display("$time=%0d", $time);
endmodule

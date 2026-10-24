/*
:name: test_illegal_timescale_precision_coarser_than_unit
:description: The time precision of `timescale has to be at least as precise as its time unit, so a precision of 1 ns with a unit of 100 ps is an error (IEEE 1800-2023 Section 22.7)
:tags: ch22
:type: elaboration
:lrm: 1800-2023 22.7
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the time precision 1 ns is a longer time than the time unit 100 ps
:expected_stderr_regex: test_illegal_timescale_precision_coarser_than_unit\.sv:20:
*/
// IEEE 1800-2023 §22.7: the time_precision argument of `timescale shall be
// at least as precise as the time_unit argument and cannot name a longer
// time. Here the unit is 100 ps and the precision 1 ns, ten times longer;
// the factor of the precision (1) is the smaller number, so only a
// comparison of the two times, not of the factors, finds the error.

`timescale 100ps / 1ns  // illegal: precision longer than the unit

module test_illegal_timescale_precision_coarser_than_unit;
  initial #1 $display("done");
endmodule

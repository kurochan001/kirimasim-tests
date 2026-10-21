/*
:name: test_illegal_timeunit_mismatch
:description: A repeated timeunit declaration has to match the first one of its module (IEEE 1800-2023 Section 3.14.2.2)
:tags: ch3
:type: elaboration
:lrm: 1800-2023 3.14.2.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a later timeunit declaration gives another unit than the first one
:expected_stderr_regex: test_illegal_timeunit_mismatch\.sv:23:
*/
// IEEE 1800-2023 §3.14.2.2: a time scope has at most one time unit; a
// timeunit declaration repeated as a later item shall match the previous one.
// The design is accepted by Verilator 5.052 (docs/simulator-differences.md).

`timescale 1ns / 1ns

module test_illegal_timeunit_mismatch;
  timeunit 1ns;
  int n;
  timeunit 10ns;   // illegal: does not match the first timeunit
  initial #1 $display("$time=%0d", $time);
endmodule

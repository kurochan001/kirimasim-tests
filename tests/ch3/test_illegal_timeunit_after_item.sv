/*
:name: test_illegal_timeunit_after_item
:description: A timeunit declaration has to come before the other items of its module (IEEE 1800-2023 Section 3.14.2.2)
:tags: ch3
:type: elaboration
:lrm: 1800-2023 3.14.2.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the first timeunit declaration of the module follows a variable declaration
:expected_stderr_regex: test_illegal_timeunit_after_item\.sv:23:
*/
// IEEE 1800-2023 §3.14.2.2: when timeunit and timeprecision are declared in a
// time scope, they shall precede any other items in it; only repetitions that
// match come later.
// The design is accepted by Verilator 5.052 (docs/simulator-differences.md).

`timescale 1ns / 1ns

module test_illegal_timeunit_after_item;
  int n;
  timeunit 10ns;   // illegal: after another item
  initial #1 $display("$time=%0d", $time);
endmodule

/*
:name: test_illegal_timeunit_step
:description: A timeunit declaration that uses the step time unit is rejected (IEEE 1800-2023 Section 3.14.3)
:tags: ch3
:type: elaboration
:lrm: 1800-2023 3.14.3 3.14.2.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: 1step cannot set the time unit of a module
:expected_stderr_regex: test_illegal_timeunit_step\.sv:25:
*/
// IEEE 1800-2023 §3.14.3: the step time unit equals the global time precision,
// but unlike the physical time units it cannot be used to set or modify the
// time unit or the time precision. A timeunit declaration takes a time literal
// with one of the units s to fs (§3.14.2.2), so the declaration with 1step on
// the marked line is an error. The `timescale directive gives every module a
// time unit and precision, so the design has no other error; the other module
// overrides its unit with 1ns, which is legal.

`timescale 1ns / 1ns

module test_illegal_timeunit_step;
  timeunit 1step;   // illegal: step cannot set the time unit

  test_illegal_timeunit_step_ok u_ok();
endmodule

module test_illegal_timeunit_step_ok;
  timeunit 1ns;

  initial #1 $display("ok");
endmodule

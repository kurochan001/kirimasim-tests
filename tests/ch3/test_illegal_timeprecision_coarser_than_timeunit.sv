/*
:name: test_illegal_timeprecision_coarser_than_timeunit
:description: A module whose timeprecision declaration is coarser than its timeunit declaration is rejected (IEEE 1800-2023 Section 3.14)
:tags: ch3
:type: elaboration
:lrm: 1800-2023 3.14 3.14.2.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the time precision 100ps of the module is a longer time than its time unit 10ps
:expected_stderr_regex: test_illegal_timeprecision_coarser_than_timeunit\.sv:(29|30):
*/
// IEEE 1800-2023 §3.14: the time precision of a design element shall be at
// least as precise as its time unit; it cannot be a longer unit of time. The
// module test_illegal_timeprecision_coarser_than_timeunit_ok sets a unit of
// 100ps with a precision of 10ps, which is legal. The top module sets its time
// unit with a timeunit declaration (§3.14.2.2) to 10ps and its precision with
// a timeprecision declaration to 100ps, which is longer: the error can be
// reported at either of the two declarations. Verilator 5.052 accepts the
// design and runs it, which the clause does not allow.

module test_illegal_timeprecision_coarser_than_timeunit_ok;
  timeunit 100ps;
  timeprecision 10ps;
endmodule

module test_illegal_timeprecision_coarser_than_timeunit;
  timeunit 10ps;
  timeprecision 100ps;   // illegal: coarser than the time unit

  test_illegal_timeprecision_coarser_than_timeunit_ok u_ok();

  initial #1 $display("done");
endmodule

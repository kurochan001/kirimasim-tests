/*
:name: test_illegal_module_timeunit_repeat_mismatch
:description: A timeunit declaration among the items of a module is legal only when it repeats and matches an earlier one in the same time scope, so a later timeunit of 1 ps after a timeunit of 1 ns is an error (IEEE 1800-2023 Section 23.2.4)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.2.4 3.14.2.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the second timeunit declaration of the module, 1ps, does not match the earlier timeunit 1ns of the same module
:expected_stderr_regex: test_illegal_module_timeunit_repeat_mismatch\.sv:30:
*/
// IEEE 1800-2023 §23.2.4 (footnote 3 of Syntax 23-5): a timeunits
// declaration is legal as a non_port_module_item only if it repeats and
// matches a previous timeunits declaration in the same time scope
// (3.14.2.2). The module first declares timeunit 1ns; the repeated
// timeunit 1ns after the first item is legal, and the timeunit 1ps after
// it is the error. The `timescale gives a time unit to every other design
// element, so the design does not mix elements with and without one.
// The design is accepted by Verilator 5.052.

`timescale 1ns / 1ps

module test_illegal_module_timeunit_repeat_mismatch;
  timeunit 1ns;
  logic a = 1'b0;
  timeunit 1ns;
  logic b = 1'b1;
  timeunit 1ps;  // illegal: does not match timeunit 1ns
endmodule

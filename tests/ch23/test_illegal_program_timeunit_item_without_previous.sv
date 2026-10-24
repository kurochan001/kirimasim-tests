/*
:name: test_illegal_program_timeunit_item_without_previous
:description: A timeunit declaration among the items of a program is legal only when it repeats an earlier one in the same time scope, so a timeunit after the first item of a program without one is an error (IEEE 1800-2023 Section 23.2.4)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.2.4 3.14.2.2 24.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the program late_timeunit_prog has no timeunits declaration before its first item, so the later timeunit 1ns repeats nothing
:expected_stderr_regex: test_illegal_program_timeunit_item_without_previous\.sv:27:
*/
// IEEE 1800-2023 §23.2.4 (footnote 3 of Syntax 23-5): a timeunits
// declaration is legal as a non_port_program_item only if it repeats and
// matches a previous timeunits declaration within the same time scope. The
// program late_timeunit_prog begins with a variable declaration and only
// then declares timeunit 1ns. The `timescale gives a time unit to every
// design element, so the design does not mix elements with and without
// one.
// The design is accepted by Verilator 5.052.

`timescale 1ns / 1ps

program late_timeunit_prog;
  logic v = 1'b1;
  timeunit 1ns;  // illegal: no earlier timeunits declaration
endprogram

module test_illegal_program_timeunit_item_without_previous;
  late_timeunit_prog p();
endmodule

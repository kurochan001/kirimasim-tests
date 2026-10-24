/*
:name: test_illegal_interface_timeprecision_repeat_mismatch
:description: A timeprecision declaration among the items of an interface is legal only when it repeats and matches an earlier one in the same time scope, so a later timeprecision of 1 fs after one of 1 ps is an error (IEEE 1800-2023 Section 23.2.4)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.2.4 3.14.2.2 25.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the second timeprecision declaration of the interface, 1fs, does not match the earlier timeprecision 1ps
:expected_stderr_regex: test_illegal_interface_timeprecision_repeat_mismatch\.sv:27:
*/
// IEEE 1800-2023 §23.2.4 (footnote 3 of Syntax 23-5): a timeunits
// declaration is legal as a non_port_interface_item only if it repeats and
// matches a previous timeunits declaration within the same time scope. The
// interface timeprec_ifc first declares timeprecision 1ps and later
// timeprecision 1fs. The `timescale gives a time unit to every design
// element, so the design does not mix elements with and without one.
// The design is accepted by Verilator 5.052.

`timescale 1ns / 1ps

interface timeprec_ifc;
  timeprecision 1ps;
  logic v;
  timeprecision 1fs;  // illegal: does not match timeprecision 1ps
endinterface

module test_illegal_interface_timeprecision_repeat_mismatch;
  timeprec_ifc i();
endmodule

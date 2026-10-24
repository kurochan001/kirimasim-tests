/*
:name: test_illegal_interface_timeunit_mismatch
:description: A timeunit declaration among the later items of an interface has to match the one at the start of the interface (IEEE 1800-2023 Section 25.3)
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.3 3.14.2.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the interface itu_bad declares timeunit 1ns / 1ps at its start and timeunit 10ns / 1ps as a later item
:expected_stderr_regex: test_illegal_interface_timeunit_mismatch\.sv:30:
*/
// IEEE 1800-2023 §25.3: a timeunits_declaration is legal as a
// non_port_interface_item only if it repeats and matches a previous
// timeunits_declaration in the same time scope (footnote 3 of Syntax 25-1;
// 3.14.2.2). itu_ok declares timeunit 1ns / 1ps at its start and repeats it
// exactly after an item, which matches. itu_bad gives 10ns / 1ps later.
// Oracle checks: the 5.052 release of Verilator accepts the design.

interface itu_ok;
  timeunit 1ns / 1ps;
  logic a;
  timeunit 1ns / 1ps;
endinterface

interface itu_bad;
  timeunit 1ns / 1ps;
  logic a;
  timeunit 10ns / 1ps;   // illegal: does not match 1ns / 1ps
endinterface

module test_illegal_interface_timeunit_mismatch;
  itu_ok i1 ();
  itu_bad i2 ();
endmodule

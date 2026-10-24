/*
:name: test_illegal_program_timeunit_mismatch
:description: A timeunit declaration among the later items of a program is legal only when it repeats and matches an earlier one in the program, so a different time unit there is an error (IEEE 1800-2023 Section 24.3)
:tags: ch24
:type: elaboration
:lrm: 1800-2023 24.3 3.14.2.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the program ptu_bad declares timeunit 1ns / 1ps after its header and timeunit 100ps / 1ps as a later item
:expected_stderr_regex: test_illegal_program_timeunit_mismatch\.sv:33:
*/
// IEEE 1800-2023 §24.3, footnote 3 of Syntax 24-1: a timeunits_declaration
// written as a non_port_program_item is legal only if it repeats, and matches,
// a timeunits_declaration that comes earlier in the same time scope (see also
// 3.14.2.2). ptu_ok sets timeunit 1ns / 1ps right after its header and writes
// the same declaration again after an item, which is legal. ptu_bad also
// starts with timeunit 1ns / 1ps, but its later declaration gives 100ps / 1ps,
// which does not match.
// Oracle checks: the 5.052 release of Verilator accepts the design.

program ptu_ok;
  timeunit 1ns / 1ps;
  int n = 1;
  timeunit 1ns / 1ps;
  initial #1 $display("ok n=%0d", n);
endprogram

program ptu_bad;
  timeunit 1ns / 1ps;
  int m = 2;
  timeunit 100ps / 1ps;   // illegal: does not match timeunit 1ns / 1ps
  initial #1 $display("bad m=%0d", m);
endprogram

module test_illegal_program_timeunit_mismatch;
endmodule

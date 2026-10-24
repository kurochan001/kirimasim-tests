/*
:name: test_illegal_package_timeunit_after_item
:description: A timeunit declaration among the later items of a package is legal only as a repetition of an earlier one, so it cannot come first after other items (IEEE 1800-2023 Section 26.2)
:tags: ch26
:type: elaboration
:lrm: 1800-2023 26.2 3.14.2.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the package pta_bad has no timeunit declaration at its start and declares timeunit 1ns / 1ps after the item a
:expected_stderr_regex: test_illegal_package_timeunit_after_item\.sv:30:
*/
// IEEE 1800-2023 §26.2: a timeunits_declaration is legal as a package_item
// only if it repeats and matches a previous timeunits_declaration in the same
// time scope (footnote 3 of Syntax 26-1; 3.14.2.2). In pta_ok, timeunit
// 1ns / 1ps comes first, right after the package header, and its repetition
// after an item is legal. pta_bad starts with the variable a and only then
// declares timeunit 1ns / 1ps, which repeats nothing.
// Oracle checks: the 5.052 release of Verilator accepts the design.

package pta_ok;
  timeunit 1ns / 1ps;
  int a;
  timeunit 1ns / 1ps;
endpackage

package pta_bad;
  int a;
  timeunit 1ns / 1ps;   // illegal: no earlier timeunit in pta_bad
endpackage

module test_illegal_package_timeunit_after_item;
endmodule

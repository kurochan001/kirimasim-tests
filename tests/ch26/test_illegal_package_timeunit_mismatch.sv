/*
:name: test_illegal_package_timeunit_mismatch
:description: A timeunit declaration among the later items of a package has to match the one at the start of the package (IEEE 1800-2023 Section 26.2)
:tags: ch26
:type: elaboration
:lrm: 1800-2023 26.2 3.14.2.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the package ptu_bad declares timeunit 1ns / 1ps at its start and timeunit 10ns / 1ps as a later package item
:expected_stderr_regex: test_illegal_package_timeunit_mismatch\.sv:30:
*/
// IEEE 1800-2023 §26.2: a timeunits_declaration is legal as a package_item
// only if it repeats and matches a previous timeunits_declaration in the same
// time scope (footnote 3 of Syntax 26-1; 3.14.2.2). ptu_ok declares
// timeunit 1ns / 1ps at its start and repeats it exactly after an item,
// which matches. ptu_bad gives 10ns / 1ps later.
// Oracle checks: the 5.052 release of Verilator accepts the design.

package ptu_ok;
  timeunit 1ns / 1ps;
  int a;
  timeunit 1ns / 1ps;
endpackage

package ptu_bad;
  timeunit 1ns / 1ps;
  int a;
  timeunit 10ns / 1ps;   // illegal: does not match 1ns / 1ps
endpackage

module test_illegal_package_timeunit_mismatch;
endmodule

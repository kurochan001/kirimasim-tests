/*
:name: test_illegal_program_timeprecision_after_item
:description: A program whose first time declaration comes after another item is illegal, since a timeunits declaration among the items has to repeat an earlier one of the program (IEEE 1800-2023 Section 24.3)
:tags: ch24
:type: elaboration
:lrm: 1800-2023 24.3 3.14.2.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the program ptp_bad has no timeunits declaration after its header and declares timeprecision 1ps only after the variable k
:expected_stderr_regex: test_illegal_program_timeprecision_after_item\.sv:32:
*/
// IEEE 1800-2023 §24.3, footnote 3 of Syntax 24-1: the only place where a
// program can set its time unit or precision for the first time is right
// after its header; a timeunits_declaration (timeunit, timeprecision or both)
// among the later program items is legal only as a repetition of a matching
// earlier one in the same time scope (3.14.2.2). ptp_ok gives timeprecision
// 1ps after its header and repeats it after an item. ptp_bad declares the
// variable k first and only then timeprecision 1ps, which repeats nothing.
// Oracle checks: the 5.052 release of Verilator accepts the design.

program ptp_ok;
  timeprecision 1ps;
  int j = 1;
  timeprecision 1ps;
  initial $display("ok j=%0d", j);
endprogram

program ptp_bad;
  int k = 2;
  timeprecision 1ps;   // illegal: no earlier timeunits declaration in ptp_bad
  initial $display("bad k=%0d", k);
endprogram

module test_illegal_program_timeprecision_after_item;
endmodule

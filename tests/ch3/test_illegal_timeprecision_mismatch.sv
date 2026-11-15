/*
:name: test_illegal_timeprecision_mismatch
:description: A timeprecision declaration repeated as a later item of a module has to match the first one, so a later timeprecision of 10 ps after one of 100 ps is an error (IEEE 1800-2023 Section 3.14.2.2)
:tags: ch3
:type: elaboration
:lrm: 1800-2023 3.14.2.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the later timeprecision declaration of the module gives 10ps, while the first one gives 100ps
:expected_stderr_regex: test_illegal_timeprecision_mismatch\.sv:32:
*/
// IEEE 1800-2023 §3.14.2.2: a module is a time scope with at most one time
// precision. Its timeunit and timeprecision declarations come before its
// other items, and they may be written again as later items only with the
// values of the earlier ones. The module first declares the unit 1ns and
// the precision 100ps. After the variable flag it repeats timeunit 1ns,
// which matches and is legal, and then declares timeprecision 10ps, which
// does not match the precision 100ps: that line is the error. The design
// has a single design element, so no other element lacks a time unit.
// With 100ps on that line the design is legal and prints the delay 1.25
// rounded to the precision 100ps (§3.14.1), that is 1.30.
// Icarus Verilog 13.0 reports the mismatch of the repeated timeprecision on
// the line of the error. The 5.054 release of Verilator accepts the design.

module test_illegal_timeprecision_mismatch;
  timeunit 1ns;
  timeprecision 100ps;
  logic flag = 1'b1;
  timeunit 1ns;
  timeprecision 10ps;   // illegal: does not match timeprecision 100ps
  initial #1.25 $display("%0.2f flag=%b", $realtime, flag);
endmodule

/*
:name: test_time_unit_from_directive_or_keywords
:description: The time unit and precision of a module can be given by a `timescale directive before it or by timeunit and timeprecision declarations inside it, and the declarations of a module win over the directive in effect (IEEE 1800-2023 Section 3.14.2)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.14.2 3.14.2.1 3.14.2.2 3.14.2.3 3.14.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_time_unit_from_directive_or_keywords.expected
*/
// IEEE 1800-2023 §3.14.2: a time unit and precision are given either by the
// `timescale directive or by the timeunit and timeprecision keywords.
// §3.14.2.1: `timescale <unit> / <precision> applies to the modules after it
// that do not declare their own. §3.14.2.2: timeunit and timeprecision, or
// timeunit with a second argument after a slash, declare them inside a
// module; §3.14.2.3: those declarations win over the directive.
// All three modules follow `timescale 10ns / 1ns and wait #2.26, which each
// rounds to its precision (§3.14.1):
//   tf_directive  from the directive, 10ns / 1ns   2.3 units  = 23000 ps
//   tf_keywords   timeunit 100ps; timeprecision 10ps   2.3 units = 230 ps
//   tf_slash      timeunit 10ps / 1ps              22.6 ps rounded to 23 ps
// They report through a task of the top module, which declares 1ps / 1ps, so
// $time is in picoseconds. Release 5.052 of Verilator rounds the delays only
// to the global precision (1ps): 23, 226 and 22600 ps.

`timescale 10ns / 1ns

module tf_directive;
  initial #2.26 test_time_unit_from_directive_or_keywords.report("tf_directive");
endmodule

module tf_keywords;
  timeunit 100ps;
  timeprecision 10ps;
  initial #2.26 test_time_unit_from_directive_or_keywords.report("tf_keywords");
endmodule

module tf_slash;
  timeunit 10ps / 1ps;
  initial #2.26 test_time_unit_from_directive_or_keywords.report("tf_slash");
endmodule

module test_time_unit_from_directive_or_keywords;
  timeunit 1ps;
  timeprecision 1ps;

  task report(string who);
    $display("%0d ps: %s", $time, who);
  endtask

  tf_directive d();
  tf_keywords k();
  tf_slash s();
endmodule

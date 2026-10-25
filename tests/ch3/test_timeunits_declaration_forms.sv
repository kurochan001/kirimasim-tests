/*
:name: test_timeunits_declaration_forms
:description: Each form of timeunits_declaration, in the compilation unit and in modules, sets the time unit and precision that scale and round the delays of its time scope (IEEE 1800-2023 Section 3.14.2.2)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.14.2.2 3.14.2.3 3.14.1 20.3.3 A.1.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timeunits_declaration_forms.expected
*/
// IEEE 1800-2023 §3.14.2.2 and A.1.2: a timeunits_declaration is timeunit
// with an optional "/ precision", timeprecision alone, or both keywords in
// either order. Source text may start with one, before its descriptions,
// which sets the time unit and precision of the compilation-unit scope; here
// 10ns / 1ns. §3.14.2.3: a module that does not declare a unit or a precision
// takes it from the compilation unit. §3.14.1: a delay is rounded to the
// precision of its module, and §20.3.3: $realtime is scaled to the time unit
// of the module that calls it. Each module waits for one fractional delay and
// prints $realtime; the six resulting times all differ, so the lines appear
// in the order of their times:
//   tu_unit_prec  timeunit 100ps; timeprecision 10ps;  #2.347 -> 230ps
//   tu_slash      timeunit 1ns / 100ps;                #1.27  -> 1.3ns
//   tu_prec_unit  timeprecision 1ps; timeunit 1ns;     #3.1416 -> 3.142ns
//   tu_prec_only  timeprecision 100ps; (unit 10ns)     #0.4567 -> 4.6ns
//   tu_inherit    nothing (10ns / 1ns)                 #0.57  -> 6ns
//   tu_unit_only  timeunit 100ns; (precision 1ns)      #0.537 -> 54ns
// The 5.052 release of Verilator rounds these delays to the finest precision
// of the design (1ps) instead of the precision of each module, so it prints
// 2.3500, 1.2700, 0.4567, 0.5700 and 0.5370.

timeunit 10ns / 1ns;

module tu_slash;
  timeunit 1ns / 100ps;
  initial #1.27 $display("tu_slash %0.4f", $realtime);
endmodule

module tu_unit_only;
  timeunit 100ns;
  initial #0.537 $display("tu_unit_only %0.4f", $realtime);
endmodule

module tu_prec_only;
  timeprecision 100ps;
  initial #0.4567 $display("tu_prec_only %0.4f", $realtime);
endmodule

module tu_unit_prec;
  timeunit 100ps;
  timeprecision 10ps;
  initial #2.347 $display("tu_unit_prec %0.4f", $realtime);
endmodule

module tu_prec_unit;
  timeprecision 1ps;
  timeunit 1ns;
  initial #3.1416 $display("tu_prec_unit %0.4f", $realtime);
endmodule

module tu_inherit;
  initial #0.57 $display("tu_inherit %0.4f", $realtime);
endmodule

module test_timeunits_declaration_forms;
  tu_slash u_slash();
  tu_unit_only u_unit_only();
  tu_prec_only u_prec_only();
  tu_unit_prec u_unit_prec();
  tu_prec_unit u_prec_unit();
  tu_inherit u_inherit();
endmodule

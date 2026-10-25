/*
:name: test_timescale_before_unit_timeunit_precedence
:description: A module without its own timeunit and timeprecision takes both from the last `timescale before it, else from the compilation-unit timeunit and timeprecision, never from a later `timescale; a `timescale does not change the time unit of the compilation-unit scope itself (IEEE 1800-2023 Section 3.14.2.3)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.14.2.3 3.14.2.2 3.14.2.1 3.14.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timescale_before_unit_timeunit_precedence.expected
*/
// IEEE 1800-2023 §3.14.2.3: a module that is not nested and has no timeunit
// takes its time unit from the last `timescale before it in the compilation
// unit (b), and only when there is none from the timeunit of the
// compilation-unit scope (c); the time precision follows the same order. The
// time unit of the compilation-unit scope is set only by its timeunit
// declaration, not by a `timescale. §3.14.2.2: the compilation-unit scope
// declares 100ps / 10ps.
// tp_from_unit comes before any `timescale (case c): its #3.27 is 3.3 units of
// 100ps (§3.14.1), 330 ps; the directives after it do not apply.
// tp_from_timescale follows `timescale 1ns/1ns (case b): #4.27 rounds to 4 ns.
// tp_from_last follows a second `timescale 10ps/1ps, the last one before it:
// #5.27 is 52.7 ps, rounded to 53 ps. The task unit_wait is declared in the
// compilation-unit scope after `timescale 1ns/1ns, but its #6.27 is still in
// units of 100ps with a precision of 10ps: 630 ps.
// All report through a task of the top module, whose own unit and precision
// are 1ps (§3.14.2.2), so $time is in picoseconds.
// Release 5.052 of Verilator rounds the delays only to the global precision
// (327, 4270 and 627 ps).

timeunit 100ps;
timeprecision 10ps;

module tp_from_unit;
  initial #3.27 test_timescale_before_unit_timeunit_precedence.report("tp_from_unit, case c");
endmodule

`timescale 1ns/1ns

task automatic unit_wait();
  #6.27;
endtask

module tp_from_timescale;
  initial #4.27 test_timescale_before_unit_timeunit_precedence.report("tp_from_timescale, case b");
endmodule

`timescale 10ps/1ps

module tp_from_last;
  initial #5.27 test_timescale_before_unit_timeunit_precedence.report("tp_from_last, case b");
endmodule

module test_timescale_before_unit_timeunit_precedence;
  timeunit 1ps;
  timeprecision 1ps;

  task report(string who);
    $display("%0d ps: %s", $time, who);
  endtask

  tp_from_unit u();
  tp_from_timescale s();
  tp_from_last l();

  initial begin
    unit_wait();
    report("unit_wait in the compilation-unit scope");
  end
endmodule

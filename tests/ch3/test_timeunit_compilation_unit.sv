/*
:name: test_timeunit_compilation_unit
:description: Without `timescale, a timeunit and timeprecision declared in the compilation-unit scope apply to the modules that do not declare their own, and delays are rounded to that precision (IEEE 1800-2023 Section 3.14.2.3)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.14.2.3 3.14.2.2 3.14.1 3.12.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timeunit_compilation_unit.expected
*/
// IEEE 1800-2023 §3.14.2.3: with no `timescale before it, a module without a
// timeunit takes the time unit and precision of the compilation-unit scope
// (3.12.1), here 1 ns and 100 ps. So the #1.25 of the top module is rounded
// to the precision (3.14.1) and waits 1.3 ns, and #2 more brings it to 3.3
// ns. m_fine declares its own unit and precision, 1 ns and 1 ps, so its
// #1.25 waits exactly 1.25 ns. $realtime is in the unit of the module that
// calls it, 1 ns in both.

timeunit 1ns;
timeprecision 100ps;

module test_timeunit_compilation_unit;
  m_fine f();

  initial begin
    #1.25 $display("%0.3f: top after #1.25", $realtime);
    #2 $display("%0.3f: top after #2 more", $realtime);
  end
endmodule

module m_fine;
  timeunit 1ns;
  timeprecision 1ps;

  initial #1.25 $display("%0.3f: m_fine after #1.25", $realtime);
endmodule

/*
:name: test_timeunit_timescale_precedence
:description: $timeunit and $timeprecision show the precedence of time units: a timeunit or timeprecision declaration in a module wins over the `timescale directive for that value only, the other value comes from the last `timescale before the module, and a module that declares nothing takes both from that directive (IEEE 1800-2023 Sections 20.4.1, 3.14.2.3)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.4.1 3.14.2.3 22.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timeunit_timescale_precedence.expected
*/
// IEEE 1800-2023 §20.4.1: $timeunit and $timeprecision give the exponents of
// Table 20-2 for the design element of the current scope, or for the instance
// named as the argument. §3.14.2.3: a module without a timeunit takes the
// unit of the last `timescale directive before it in the compilation unit,
// and the same rule holds for the precision on its own. §22.7: a `timescale
// applies to the design elements that follow it until the next one.
// - The top module and unit_only follow `timescale 1us / 10ns: the top module
//   gives -6 -8, and unit_only, with timeunit 10us only, -5 -8.
// - prec_only, with timeprecision 1ps only, gives -6 -12.
// - late and both follow `timescale 1ms / 1us: late gives -3 -6, and both,
//   which declares 1ns and 1ps, -9 -12.
// Each module is a separate design element with both values determined, so
// the design does not mix elements with and without a time unit.
// Icarus Verilog 13.0 does not know $timeunit. The 5.054 release of the
// simulator named Verilator gives -6 -12 on every line: the unit of the
// calling module whatever the argument, and the simulation precision.

`timescale 1us / 10ns

module test_timeunit_timescale_precedence;
  unit_only u ();
  prec_only p ();
  late l ();
  both b ();

  initial begin
    $display("top: %0d %0d", $timeunit, $timeprecision);
    $display("unit_only: %0d %0d", $timeunit(u), $timeprecision(u));
    $display("prec_only: %0d %0d", $timeunit(p), $timeprecision(p));
    $display("late: %0d %0d", $timeunit(l), $timeprecision(l));
    $display("both: %0d %0d", $timeunit(b), $timeprecision(b));
  end
endmodule

module unit_only;
  timeunit 10us;
endmodule

module prec_only;
  timeprecision 1ps;
endmodule

`timescale 1ms / 1us

module late;
endmodule

module both;
  timeunit 1ns;
  timeprecision 1ps;
endmodule

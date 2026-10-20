/*
:name: test_timeunit_timeprecision_functions
:description: $timeunit and $timeprecision give the time unit and precision of the current design element, or of the instance they name, as powers of ten (IEEE 1800-2023 Section 20.4.1)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.4.1 3.14.2.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timeunit_timeprecision_functions.expected
*/
// IEEE 1800-2023 §20.4.1: without an argument $timeunit and $timeprecision
// give the time unit and precision of the design element of the current
// scope, and with the name of an instance those of that instance. The values
// are exponents of ten: -6 for 1 us, -8 for 10 ns, -9 for 1 ns, -12 for 1 ps.
// The time units are declared with timeunit and timeprecision (3.14.2.2).
// test_timeunit_unit_root covers the arguments $unit and $root.
//
// With Verilator 5.052, $timeprecision gives the simulation precision, -12,
// even without an argument.

module test_timeunit_timeprecision_functions_fine;
  timeunit 1ns;
  timeprecision 1ps;
endmodule

module test_timeunit_timeprecision_functions;
  timeunit 1us;
  timeprecision 10ns;

  test_timeunit_timeprecision_functions_fine u();

  initial begin
    $display("own: %0d %0d", $timeunit, $timeprecision);
    $display("instance u: %0d %0d", $timeunit(u), $timeprecision(u));
  end
endmodule

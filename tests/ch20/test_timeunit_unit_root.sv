/*
:name: test_timeunit_unit_root
:description: With the argument $unit, $timeunit and $timeprecision give the time unit and precision of the compilation unit, and with $root both give the simulation time unit, the finest precision in the design (IEEE 1800-2023 Section 20.4.1)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.4.1 3.14.3 3.14.2.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timeunit_unit_root.expected
*/
// IEEE 1800-2023 §20.4.1: with the argument $unit, $timeunit and
// $timeprecision give the time unit and precision of the compilation unit;
// with $root both give the simulation time unit (3.14.3), the smallest time
// precision of the design. The compilation unit declares 10 ns / 1 ns
// (3.14.2.2), the top module 1 us / 10 ns and the other module 1 ns / 1 ps,
// so $root gives -12 for 1 ps.

timeunit 10ns;
timeprecision 1ns;

module test_timeunit_unit_root_fine;
  timeunit 1ns;
  timeprecision 1ps;
endmodule

module test_timeunit_unit_root;
  timeunit 1us;
  timeprecision 10ns;

  test_timeunit_unit_root_fine u();

  initial begin
    $display("$unit: %0d %0d", $timeunit($unit), $timeprecision($unit));
    $display("$root: %0d %0d", $timeunit($root), $timeprecision($root));
  end
endmodule

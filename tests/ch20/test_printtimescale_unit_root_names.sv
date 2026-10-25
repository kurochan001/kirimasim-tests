/*
:name: test_printtimescale_unit_root_names
:description: $printtimescale($unit) prints the time unit and precision of the compilation unit and $printtimescale($root) the simulation time unit for both, named $unit and $root in the output (IEEE 1800-2023 Section 20.4.2)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.4.2 3.14.3 3.14.2.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_printtimescale_unit_root_names.expected
*/
// IEEE 1800-2023 §20.4.2: $printtimescale prints "Time scale of (<name>) is
// <unit> / <precision>". With the argument $unit it prints the time unit and
// precision of the compilation unit, and with $root the simulation time unit,
// as both the unit and the precision; the name in the output is then "$unit"
// or "$root". Without an argument it prints those of the current scope.
// §3.14.3: the simulation time unit is the smallest time precision in the
// design.
// The compilation unit declares 100ps / 10fs, the top module 1ns / 1ps and
// the module it instantiates 1ps / 1fs, so the simulation time unit, 1fs, is
// that of neither the compilation unit nor the module that calls the task.
// Icarus Verilog 13.0 and release 5.052 of Verilator both reject $root and
// $unit as the argument of $printtimescale with a syntax error.

timeunit 100ps;
timeprecision 10fs;

module pts_fine_child;
  timeunit 1ps;
  timeprecision 1fs;
endmodule

module test_printtimescale_unit_root_names;
  timeunit 1ns;
  timeprecision 1ps;

  pts_fine_child u_fine();

  initial begin
    $printtimescale($root);
    $printtimescale($unit);
    $printtimescale;
  end
endmodule

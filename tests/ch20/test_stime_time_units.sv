/*
:name: test_stime_time_units
:description: $stime returns the current time in the time unit of the module that calls it as a 32-bit unsigned value, keeping only the low 32 bits of a larger time, while $time keeps all 64; a module's timeunit declaration sets the unit its calls use (IEEE 1800-2023 Sections 20.3.2, 3.14.2.2)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.3.2 20.3.1 20.3.3 3.14.2.2 3.14.2.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_stime_time_units.expected
*/
// IEEE 1800-2023 §20.3.2: $stime returns an unsigned 32-bit time scaled to the
// time unit of the module that invokes it, and only the low 32 bits when the
// time does not fit. §20.3.1: $time returns a 64-bit integer, rounded, in the
// same unit; §20.3.3: $realtime a real number. §3.14.2.2: timeunit and
// timeprecision declarations in a module set its time unit and precision.
// The test module has a time unit of 1ns and slow has one of 10ns, both with
// 1ps precision. At 12.6 ns, $time is 13 in ns and 1 in units of 10 ns. At
// 4294967312.6 ns, $time in ns needs more than 32 bits: 4294967313 is 2**32 +
// 17, so $stime gives 17, while in units of 10 ns the time still fits.

`timescale 1ns/1ps

module slow;
  timeunit 10ns;
  timeprecision 1ps;
  always @(test_stime_time_units.check)
    $display("slow: $time=%0d $stime=%0d $realtime=%.2f", $time, $stime, $realtime);
endmodule

module test_stime_time_units;
  event check;

  slow s();

  initial begin
    #12.6;
    $display("ns: $time=%0d $stime=%0d $realtime=%.1f", $time, $stime, $realtime);
    -> check;
    #(64'd4294967300);
    $display("ns: $time=%0d $stime=%0d $realtime=%.1f", $time, $stime, $realtime);
    -> check;
    #1 $finish;
  end
endmodule

/*
:name: test_vpi_get_time_scaled
:description: vpi_get_time gives the time in the time unit of a module with vpiScaledRealTime, and in the simulation time unit with a NULL object; vpiTimeUnit and vpiTimePrecision give each module's timescale (IEEE 1800-2023 Section 38.13)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.13 38.6 3.14.2 3.14.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_get_time_scaled.c
:expected_stdout: @test_vpi_get_time_scaled.expected
*/
// IEEE 1800-2023 §38.13: vpi_get_time with vpiScaledRealTime gives the current
// time in the time unit of the object passed, and with a NULL object and
// vpiSimTime in the simulation time unit, the smallest time precision of the
// design (3.14.3), here 1 ps. §38.6: vpiTimeUnit and vpiTimePrecision of a
// module give its time unit and precision as powers of ten (3.14.2). At 2500 ns
// the call reports both modules.

`timescale 1us/1ns
module vpi_slow_unit;
endmodule

`timescale 1ns/1ps
module test_vpi_get_time_scaled;
  vpi_slow_unit s();

  initial #2500 $vt_now(test_vpi_get_time_scaled, s);
endmodule

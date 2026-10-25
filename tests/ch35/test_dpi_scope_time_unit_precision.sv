/*
:name: test_dpi_scope_time_unit_precision
:description: svGetTimeUnit and svGetTimePrecision give the time unit and precision of the instance of an svScope and the simulation time unit for a NULL scope, and svGetTime gives the current time as a real number in the scope's unit or, for a NULL scope, as a 64-bit simulation time or a real number in the simulation time unit, filling an svTimeVal that is the type s_vpi_time (IEEE 1800-2023 Section H.13)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.3 H.13 3.14.3 38.13
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_scope_time_unit_precision.c
:expected_stdout: @test_dpi_scope_time_unit_precision.expected
*/
// IEEE 1800-2023 §H.13: svGetTimeUnit and svGetTimePrecision give the time unit
// and the time precision of the instance that an svScope names, as the
// vpiTimeUnit and vpiTimePrecision properties would, that is, as the power of
// ten of seconds; with a NULL scope both give the simulation time unit, which
// is the smallest time precision in the design (3.14.3). svGetTime fills an
// svTimeVal, which svdpi.h defines as the type s_vpi_time, with the current
// time: its type field selects a scaled real time (vpiScaledRealTime), given
// in the time unit of the scope, or a simulation time (vpiSimTime), given in
// the high and low words; with a NULL scope the time is in the simulation
// time unit (38.13). A context import gets the scope of the instance that
// holds its import declaration from svGetScope (35.5.3).
//
// The top module has the time unit 1ns and precision 1ps and the module
// dpi_time_unit_b 1us and 10ns, so the simulation time unit is 1ps (-12).
// c_times runs in the top module at 1234.567ns and in the instance b at
// 2.5us and 5000us, and prints the unit and precision of its scope and of a
// NULL scope, the scaled real time in its scope, and the simulation time and
// the scaled real time for a NULL scope. 5000us is 5e9 ps, above 2**32, so
// the high word is 1. The C code assigns the address of its svTimeVal to an
// s_vpi_time pointer, which C++ accepts only when the two are the same type.
//
// Icarus Verilog 13.0 has no DPI. In Verilator 5.052 svGetTime ignores the
// scope and the type field and always gives the simulation time in the high
// and low words, leaving the real field unset; svGetTimePrecision ignores the
// scope; svGetTimeUnit gives -9 for the instance b and -6 for a NULL scope.
// So :oracle: names no simulator.

`timescale 1us/10ns

module dpi_time_unit_b;
  import "DPI-C" context function void c_times(input string who);

  initial begin
    #2.5 c_times("b");
    #4997.5 c_times("b");
  end
endmodule

`timescale 1ns/1ps

module test_dpi_scope_time_unit_precision;
  import "DPI-C" context function void c_times(input string who);

  dpi_time_unit_b b();

  initial begin
    #1234.567 c_times("top");
  end
endmodule

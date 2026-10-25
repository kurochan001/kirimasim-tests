/*
:name: test_svdpi_h_scope_time
:description: svGetTimeUnit and svGetTimePrecision give the time unit and precision of the instance scope that svGetScope names, as powers of ten of seconds, and those of the simulation for a NULL scope, and svGetTime fills an svTimeVal with the current time in the unit of the scope, or of the simulation for a NULL scope, in the field that its type selects (IEEE 1800-2023 Section 35.3.2, I.3, H.13, 3.14.3, 38.13)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.3.2 I.3 H.13 3.14.3 38.13
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_svdpi_h_scope_time.c
:expected_stdout: @test_svdpi_h_scope_time.expected
*/
// IEEE 1800-2023 §35.3.2: the C layer of DPI is the one Annex I lists.
// I.3 and H.13: svGetTimeUnit and svGetTimePrecision give the time unit and
// the time precision of the instance scope they are given, as the power of
// ten of seconds that vpi_get with vpiTimeUnit and vpiTimePrecision gives, and
// those of the simulation for a NULL scope; svGetTime fills an svTimeVal with
// the current time, scaled to the time unit of the scope, or to the simulation
// time unit for a NULL scope, and the type field of the value says which field
// holds it: the real field for vpiScaledRealTime and the high and low words
// for vpiSimTime, as in vpi_get_time with the timescale of the object (38.13).
// The simulation time unit is the smallest time precision of the design
// (3.14.3). Each routine returns 0 when it writes its result.
//
// The top module has the time unit 1ns and precision 1ps and
// dpi_time_b 1us and 10ns, so the simulation time unit is 1ps, -12. The
// instance b calls c_times at 2.5us and the top module at 3ns. Each call
// prints the unit and precision of its own scope and of a NULL scope, the
// real field of a value whose type is vpiScaledRealTime, which is the time in
// the unit of that scope, the high and low words of a value whose type is
// vpiSimTime and whose scope is NULL, which count the time in the simulation
// time unit, and whether every call returned 0.

`timescale 1us/10ns

module dpi_time_b;
  import "DPI-C" context function void c_times(input string who);

  initial #2.5 c_times("b");
endmodule

`timescale 1ns/1ps

module test_svdpi_h_scope_time;
  import "DPI-C" context function void c_times(input string who);

  dpi_time_b b();

  initial #3 c_times("top");
endmodule

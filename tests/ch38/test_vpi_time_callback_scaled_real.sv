/*
:name: test_vpi_time_callback_scaled_real
:description: A simulation time callback requested with vpiScaledRealTime takes its time in the time unit of the object in its obj field (IEEE 1800-2023 Section 38.36.2)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.36.2 38.36.3 38.13 3.14.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_time_callback_scaled_real.c
:expected_stdout: @test_vpi_time_callback_scaled_real.expected
*/
// IEEE 1800-2023 §38.36.2: when the time type of a simulation time callback
// is vpiScaledRealTime, the obj field gives the object whose time scale is
// used for the time in real. The instance u_sub has a time unit of 10 ns and
// the top module 1 ns; the simulation time unit is 1 ns, the smallest
// precision (3.14.3). At the start of the simulation (38.36.3), at time 0,
// where a time and a delay are the same, the application registers
// cbAfterDelay callbacks with a real of 3.0 for u_sub and for the top module,
// and a cbAtStartOfSimTime callback with a real of 2.0 for u_sub. Each
// callback prints the current simulation time from vpi_get_time with NULL
// (38.13): 30, 3 and 20.

`timescale 10ns/1ns
module scaled_real_sub;
endmodule

`timescale 1ns/1ns
module test_vpi_time_callback_scaled_real;
  scaled_real_sub u_sub();

  initial #40 $finish;
endmodule

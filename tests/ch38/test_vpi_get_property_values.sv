/*
:name: test_vpi_get_property_values
:description: vpi_get returns the defined type constants, sizes and Boolean properties (1 or 0) of variables of several types, and with a NULL object returns the simulation time unit for both vpiTimeUnit and vpiTimePrecision (IEEE 1800-2023 Section 38.6)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.6 37.17 3.14.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_get_property_values.c
:expected_stdout: @test_vpi_get_property_values.expected
*/
// IEEE 1800-2023 §38.6: vpi_get returns integer and Boolean properties;
// Boolean ones are 1 for true and 0 for false, and a property with defined
// values, such as vpiType, returns the value of Annex K or Annex M. §37.17:
// vpiSize of an integral variable is its number of bits; a logic or bit
// variable without packed dimension is a scalar, one with a packed dimension
// and the integer types are vectors, and a real variable is neither (detail
// 20). For vpiTimeUnit and vpiTimePrecision a NULL object gives the simulation
// time unit, the smallest time precision of the design (3.14.3): 1 ps from the
// submodule, while the top module's own unit and precision are 1 ns and 100 ps.
// The application reads the properties at the start of the simulation.
// With Verilator 5.052, int, byte and longint are vpiLogicVar, a real
// variable has vpiScalar 1, the NULL object gives -6 and -12, and both modules
// give -9 and -12.

`timescale 1us/1ps
module test_vpi_get_property_values_sub;
  logic a = 1'b0;
endmodule

`timescale 1ns/100ps
module test_vpi_get_property_values;
  logic [7:0] r = 8'd0;
  logic signed [11:0] sr = 12'sd0;
  logic b = 1'b0;
  int i = 0;
  byte by = 8'sd0;
  longint li = 0;
  bit [3:0] bt = 4'd0;
  real rl = 0.0;

  test_vpi_get_property_values_sub u();

  initial #1 $display("design: done");
endmodule

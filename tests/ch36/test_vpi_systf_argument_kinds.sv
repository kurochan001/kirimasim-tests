/*
:name: test_vpi_systf_argument_kinds
:description: The arguments of a user-defined system task are VPI objects of their own kind: variables, nets, parameters, constants with their constant type, hierarchical references and system function calls (IEEE 1800-2023 Section 36.4)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.4 37.42 38.15
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_systf_argument_kinds.c
:expected_stdout: @test_vpi_systf_argument_kinds.expected
*/
// IEEE 1800-2023 §36.4, §37.42: the application reads the arguments of a call
// as VPI objects, each with its own vpiType: a reg is a vpiReg, a net a
// vpiNet, a parameter a vpiParameter, a literal a vpiConstant, with a
// vpiConstType of vpiStringConst for a string, a hierarchical name the object
// it names, and a call of a system function a vpiSysFuncCall. The application
// prints the kind of each argument, the full name of each named object and
// the value of each (38.15).

`timescale 1ns/1ns

module test_vpi_systf_argument_kinds_child;
  reg [3:0] inner = 4'h9;
endmodule

module test_vpi_systf_argument_kinds;
  reg [7:0] r = 8'h5a;
  wire [3:0] w = 4'h3;
  parameter P = 12;

  test_vpi_systf_argument_kinds_child c();

  initial #1 $vt_kinds(r, w, P, 7, "abc", c.inner, $time);
endmodule

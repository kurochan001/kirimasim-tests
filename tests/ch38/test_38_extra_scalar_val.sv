/*
:name: test_38_extra_scalar_val
:description: vpi_get_value with vpiScalarVal returns the s_vpi_value scalar member as vpi0, vpi1, vpiX or vpiZ for the four logic values of a variable (IEEE 1800-2023 Section 38.15)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.15 6.3.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:vpi_c: @test_38_extra_scalar_val.c
:expected_stdout: @test_38_extra_scalar_val.expected
*/
// IEEE 1800-2023 §38.15: Table 38-3 gives the value format vpiScalarVal the
// union member scalar, whose value is one of vpi0, vpi1, vpiX, vpiZ, vpiH or
// vpiL. At time 1 the application reads four one-bit variables that hold 0,
// 1, x and z, and prints the member as the name of the constant. The two
// remaining Table 38-3 values, vpiH and vpiL, come from strengths that a
// pullup or pulldown does not produce here: this tool reports those nets as
// vpi1 and vpi0, so only the four logic values are observed.

`timescale 1ns/1ns

module test_38_extra_scalar_val;
  logic zero_v = 1'b0;
  logic one_v = 1'b1;
  logic x_v = 1'bx;
  logic z_v = 1'bz;

  initial begin
    #1 $vt_read;
    #1 $finish;
  end
endmodule

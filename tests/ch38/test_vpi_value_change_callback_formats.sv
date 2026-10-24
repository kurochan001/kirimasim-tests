/*
:name: test_vpi_value_change_callback_formats
:description: A cbValueChange callback gets a new s_cb_data with the registered user_data, the time in the requested type and the new value in the requested format of Table 38-5: binary, octal and hex strings with x, X, z and Z, decimal strings, doubles, the scalar values vpi0, vpi1, vpiX and vpiZ, ASCII strings and aval/bval words (IEEE 1800-2023 Section 38.36.1)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.36.1 38.15 38.36.2 38.36.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:vpi_c: @test_vpi_value_change_callback_formats.c
:expected_stdout: @test_vpi_value_change_callback_formats.expected
*/
// IEEE 1800-2023 §38.36.1: the routine of a cbValueChange callback gets a
// pointer to a new s_cb_data, not to the one given to vpi_register_cb, whose
// time and value are set as the time type and the value format of the
// registration ask and whose user_data is the registered one. Table 38-5
// gives the formats: vpiBinStrVal (1, 0, x, z), vpiOctStrVal and
// vpiHexStrVal (digits, x, X, z, Z, as in Table 38-3 of 38.15), vpiDecStrVal
// (0 to 9), vpiRealVal (a double), vpiScalarVal (vpi1, vpi0, vpiX, vpiZ, ...),
// vpiStringVal (ASCII characters) and vpiVectorVal (aval/bval).
//
// In a cbAfterDelay callback at 1 (38.36.2), registered at the start of the
// simulation (38.36.3), the application registers one cbValueChange callback
// with vpiSimTime for each variable, from one static s_cb_data, with the
// format in its user_data. Each variable changes at its own time from 10 on,
// and s four times. Each callback prints the time, its user_data, whether
// its structure is a new one whose value has the registered format, and the
// value.

`timescale 1ns/1ns

module test_vpi_value_change_callback_formats;
  logic [7:0] b8;
  logic [14:0] o15;
  logic [19:0] h20;
  int d;
  real r;
  logic s;
  logic [23:0] str;
  logic [39:0] vv;

  initial begin
    b8 = 0;
    o15 = 0;
    h20 = 0;
    s = 0;
    str = 0;
    vv = 0;
    #10 b8 = 8'b1xxx_0z10;
    #1 o15 = 15'bxxx_zzz_x01_z10_101;
    #1 h20 = 20'bxxxx_1010_zzzz_x011_0z01;
    #1 d = 1234;
    #1 r = 2.5;
    #1 s = 1'b1;
    #1 s = 1'bx;
    #1 s = 1'bz;
    #1 s = 1'b0;
    #1 str = "abc";
    #1 vv = 40'b1z00_0000_x000_0000_0000_0000_0000_0000_0000_01xz;
    #1 $finish;
  end
endmodule

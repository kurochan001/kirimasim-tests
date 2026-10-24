/*
:name: test_vpi_get_value_string_formats
:description: vpi_get_value gives binary strings with 1, 0, x and z, octal and hex strings with x or z for a digit whose bits are all x or all z and X or Z for a digit with only some, and integers with x and z bits taken as 0 (IEEE 1800-2023 Section 38.15)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.15 38.36.2 38.36.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:vpi_c: @test_vpi_get_value_string_formats.c
:expected_stdout: @test_vpi_get_value_string_formats.expected
*/
// IEEE 1800-2023 §38.15 (Table 38-3): with vpiBinStrVal, vpi_get_value puts
// in str a string of the characters 1, 0, x and z, one per bit; with
// vpiOctStrVal and vpiHexStrVal, one digit per group of 3 or 4 bits, which is
// x when all the bits of the group are x, X when only some are, z when all
// are z and Z when only some are; with vpiIntVal, the integer value, where
// each x or z bit counts as 0. The test gives each variable a value in which
// no digit mixes x and z bits, and whose leftmost bit is not 0. The
// application reads the values in a cbAfterDelay callback at time 1
// (38.36.2), registered at the start of the simulation (38.36.3); the
// design ends at 2.

`timescale 1ns/1ns

module test_vpi_get_value_string_formats;
  logic [15:0] h1, h2;
  logic [11:0] o1, o2;
  logic [7:0] all_x, all_z;

  initial begin
    h1 = 16'b1010_xxxx_zzzz_01x1;
    h2 = 16'b1z11_1111_0000_zz10;
    o1 = 12'b101_xxx_zzz_x10;
    o2 = 12'bz01_111_000_0zz;
    all_x = 8'bxxxx_xxxx;
    all_z = 8'bzzzz_zzzz;
    #2 $finish;
  end
endmodule

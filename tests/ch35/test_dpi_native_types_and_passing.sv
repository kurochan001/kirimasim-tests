/*
:name: test_dpi_native_types_and_passing
:description: a foreign function declares the C types that are equivalent to the SystemVerilog formals of its import (int, shortint, byte, packed bit and logic vectors, real and string), reads the values in the canonical representation and writes output and inout arguments, and SystemVerilog sees the values it passed and the values the foreign code wrote (IEEE 1800-2023 Sections 35.3.2, 35.5.6 and 35.6.1)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.3.2 35.5.6 35.6.1 35.2.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_native_types_and_passing.c
:expected_stdout: @test_dpi_native_types_and_passing.expected
*/
// IEEE 1800-2023 §35.3.2: the foreign declaration uses the C types that are
// equivalent to the SystemVerilog formals, and the foreign layer maps the
// values. §35.5.6: the formals are the supported SystemVerilog types, here
// int, shortint, byte, bit [7:0], logic [3:0], bit [63:0], real, string and
// bit. §35.6.1: passing is transparent, so the foreign function reads the
// values that SystemVerilog passed and the output and inout arguments reach
// SystemVerilog.
//
// The C function sums one part of each argument: the integers, the low byte of
// the 8-bit bit vector, the value bits of the 4-bit logic vector (and 1000
// times its x and z bits, which are zero), the low byte and the low nibble of
// the upper chunk of the 64-bit bit vector, twice the real, 100 and 10 for the
// two characters of the string and the bit. The sum is 693. The second
// function writes 10*a to its output and adds a to its inout.

module test_dpi_native_types_and_passing;
  import "DPI-C" function int native_types(
      input int i, input shortint s, input byte b, input bit [7:0] u8,
      input logic [3:0] l4, input bit [63:0] u64, input real r,
      input string text, input bit flag);
  import "DPI-C" function void directions(input int a, output int o, inout int io);

  initial begin
    int o;
    static int io = 4;
    $display("types=%0d", native_types(7, -3, 5, 8'hA5, 4'b1010,
             64'h0000_0001_2345_6789, 2.5, "hi", 1));
    directions(3, o, io);
    $display("output=%0d inout=%0d", o, io);
  end
endmodule

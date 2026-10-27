/*
:name: test_dpi_declaration_site_types
:description: the foreign side sees each argument with the type of the formal in the import declaration, so a 4-bit unsigned actual reaches an int formal as 15, a negative byte reaches an int as -1, a 32-bit actual reaches a bit [15:0] formal truncated, and a value written through an inout int is assigned back to a 4-bit actual (IEEE 1800-2023 Section 35.6.1)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.6.1 35.6.1.1 35.2.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_declaration_site_types.c
:expected_stdout: @test_dpi_declaration_site_types.expected
*/
// IEEE 1800-2023 §35.6.1: the arguments of an imported function are passed as
// their declaration types say, so an actual of another type is converted to
// the type of the formal by the assignment rules; the foreign side therefore
// sees the formal's type and value. For an inout formal the value the foreign
// code writes is converted back to the actual in the same way.
//
// c_seen takes int, bit [15:0] and int formals and returns a value that names
// the first that differs from what the formal type requires: the 4-bit 4'hF
// as an int is 15, the signed byte -1 as an int is -1, and 32'h1234_ABCD as a
// 16-bit formal is 16'hABCD. c_set writes 9 to its inout int, which a 4-bit
// actual holds without a change. The two calls return 0 when each value is as
// the formal says.

module test_dpi_declaration_site_types;
  import "DPI-C" function int c_seen(input int a, input bit [15:0] b, input int c);
  import "DPI-C" function void c_set(inout int v);

  bit [3:0] nibble = 4'hF;
  byte minus_one = -1;
  bit [31:0] word = 32'h1234_ABCD;
  bit [3:0] count = 4;

  initial begin
    $display("seen=%0d", c_seen(nibble, word, minus_one));
    c_set(count);
    $display("count=%0d", count);
  end
endmodule

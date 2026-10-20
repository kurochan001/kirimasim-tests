/*
:name: test_dpi_unsigned_types
:description: The unsigned forms of byte, shortint, int and longint, and an enumeration type, pass between SystemVerilog and C as the matching C types (IEEE 1800-2023 Section 35.5.6)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.6 35.5.5 H.7.4 H.8.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_unsigned_types.c
:expected_stdout: @test_dpi_unsigned_types.expected
*/
// IEEE 1800-2023 §35.5.6, H.7.4: byte unsigned, shortint unsigned, int
// unsigned and longint unsigned pass as the unsigned C types of the same size,
// and all of them may be function results (35.5.5, H.8.9). So 255 + 1 in an
// unsigned char is 0, the largest unsigned int is 4294967295, and 2 to the 63
// fits in an unsigned long long. An enumeration type passes as its base type,
// here byte.

module test_dpi_unsigned_types;
  typedef enum byte {RED = 1, GREEN = 2, BLUE = 4} color_e;

  import "DPI-C" function byte unsigned dpi_inc_ubyte(input byte unsigned b);
  import "DPI-C" function shortint unsigned dpi_half_ushort(input shortint unsigned s);
  import "DPI-C" function int unsigned dpi_max_uint();
  import "DPI-C" function longint unsigned dpi_pow63();
  import "DPI-C" function int dpi_color_code(input color_e c);

  initial begin
    $display("byte unsigned: 255 + 1 = %0d", dpi_inc_ubyte(8'd255));
    $display("shortint unsigned: 65534 / 2 = %0d", dpi_half_ushort(16'd65534));
    $display("int unsigned: max = %0d", dpi_max_uint());
    $display("longint unsigned: 2**63 = %0d", dpi_pow63());
    $display("enum: GREEN gives %0d, BLUE gives %0d", dpi_color_code(GREEN), dpi_color_code(BLUE));
  end
endmodule

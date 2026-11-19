/*
:name: test_svdpi_h_partsel_get_put_bit_logic_width_32
:description: svGetPartselBit, svGetPartselLogic, svPutPartselBit and svPutPartselLogic work on the normalized indices of a 64-bit vector declared [70:7], with widths from 4 up to the limit 32 and parts that cross the 32-bit chunks (IEEE 1800-2023 Section I.3)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.3.2 I.3
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_svdpi_h_partsel_get_put_bit_logic_width_32.c
:expected_stdout: @test_svdpi_h_partsel_get_put_bit_logic_width_32.expected
*/
// IEEE 1800-2023 §35.3.2: the C layer of DPI is the one Annex I lists. I.3:
// the part-select utilities svGetPartselBit, svGetPartselLogic,
// svPutPartselBit and svPutPartselLogic copy a part of at most 32 bits
// between a packed vector in canonical form and one 32-bit chunk (aval and
// bval for logic); s is the source, d the destination, i the starting bit
// index and w the width, and both sides use the normalized range n-1:0, in
// which 0 is the least significant bit.
//
// The vectors are declared [70:7], so the normalized index k is the declared
// bit k + 7. The C code gets, from the bit vector 0123456789abcdef, the parts
// at 0 and 28 (width 8; the second crosses two chunks) and at 32 and 20
// (width 32, the limit; the second crosses two chunks). From the logic
// vector fedcba9876543210 it gets the part at 36 of width 8 and the part at
// 16 of width 32, with their aval and bval. Only the w low bits of each
// result are printed. It then puts a5a5a5a5 at index 20 (width 32) and the
// low four bits of 3c at 60 into the bit vector, and puts the chunk aval 6
// at 44 (width 4) and the chunk aval 12345678 at 4 (width 32) into the logic
// vector; the design prints both vectors, whose other bits keep their values.
// Parts counted from the declared index 7, or from the most significant
// bit, would give other values. The values have no x or z, so that a
// two-state simulator can run the test. Icarus Verilog 13.0 does not support
// DPI.

module test_svdpi_h_partsel_get_put_bit_logic_width_32;
  import "DPI-C" function void dpi_get_parts(input bit [70:7] b, input logic [70:7] l);
  import "DPI-C" function void dpi_put_parts(inout bit [70:7] b, inout logic [70:7] l);

  bit [70:7] b = 64'h0123_4567_89ab_cdef;
  logic [70:7] l;

  initial begin
    l = 64'hfedc_ba98_7654_3210;
    dpi_get_parts(b, l);
    dpi_put_parts(b, l);
    $display("bit vector after the puts: %h", b);
    $display("logic vector after the puts: %b", l);
  end
endmodule

/*
:name: test_svdpi_h_packed_bit_and_part_select
:description: svGetBitselBit, svGetBitselLogic, svPutBitselBit, svPutBitselLogic, svGetPartselBit, svGetPartselLogic, svPutPartselBit and svPutPartselLogic read and write a packed vector as n-1:0 with bit 0 the least significant bit, and SV_MASK and SV_GET_UNSIGNED_BITS keep the low bits of a chunk (IEEE 1800-2023 Section 35.3.2, I.3)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.3.2 I.3 H.7.6 H.10.1.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_svdpi_h_packed_bit_and_part_select.c
:expected_stdout: @test_svdpi_h_packed_bit_and_part_select.expected
*/
// IEEE 1800-2023 §35.3.2: the C layer of DPI is the one Annex I lists.
// I.3 and H.7.6 give a packed vector that C sees the normalized range n-1:0
// whatever range the SystemVerilog declaration writes, with 0 the index of
// the least significant bit. The bit-select utilities take that index and the
// part-select utilities take a starting index and a width of at most 32 and
// work on the same normalized indices. SV_MASK(N) has the N low bits set and
// SV_GET_UNSIGNED_BITS(VALUE, N) keeps those N bits of VALUE.
//
// The C code reads all eight bits of a logic vector declared [15:8] and a bit
// vector declared [8:15], so its index 0 has to be the last bit of each
// declaration, and prints the two sequences. It then sets bits 7 and 0 of a
// logic vector and bits 4 and 3 of a bit vector through the put functions,
// and the design prints the two vectors. From the 64-bit value
// 0123456789abcdef the C code extracts the eight bits at index 28, which lie
// in two 32-bit chunks, and those at index 0, and prints both. It also puts
// the 16-bit value abcd at index 28 of a 64-bit vector, and the design prints
// that vector. A last line prints 1 when SV_MASK of 1, 8 and 31 and
// SV_GET_UNSIGNED_BITS of 89abcdef with 8, 32 and 31 have the values the
// macros give.

module test_svdpi_h_packed_bit_and_part_select;
  import "DPI-C" function void dpi_bit_select(input logic [15:8] a, input bit [8:15] b,
                                              inout logic [15:8] lput,
                                              inout bit [8:15] bput);
  import "DPI-C" function void dpi_part_select(input logic [7:0] c,
                                               input bit [63:0] w,
                                               inout bit [63:0] d);
  import "DPI-C" function int dpi_macros();

  logic [15:8] a = 8'b1010_0110;
  bit [8:15] b = 8'b0101_1001;
  logic [15:8] lput = 8'h00;
  bit [8:15] bput = 8'h00;
  logic [7:0] c = 8'ha6;
  bit [63:0] d = 64'h0;

  initial begin
    dpi_bit_select(a, b, lput, bput);
    $display("bits put into logic %b and into bit %b", lput, bput);
    dpi_part_select(c, 64'h0123456789abcdef, d);
    $display("the 16 bits abcd put at index 28: %016h", d);
    $display("masks and unsigned bits: %0d", dpi_macros());
  end
endmodule

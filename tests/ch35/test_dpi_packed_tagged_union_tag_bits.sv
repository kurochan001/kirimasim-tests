/*
:name: test_dpi_packed_tagged_union_tag_bits
:description: A packed tagged union argument reaches C as the packed array of its width, with the 2-state tag in the most significant bits of the svBitVecVal chunk, or of the aval word of the svLogicVecVal chunk for a 4-state union, and the member value right-justified (IEEE 1800-2023 Section 35.5.6, H.7.4, 7.3.2)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.6 H.7.4 7.3.2 H.7.7
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:dpi_c: @test_dpi_packed_tagged_union_tag_bits.c
:expected_stdout: @test_dpi_packed_tagged_union_tag_bits.expected
*/
// IEEE 1800-2023 §35.5.6: packed unions may be formal arguments. H.7.4: DPI
// handles a packed struct or union as the one-dimensional packed array of the
// same width, and the tag of a packed tagged union is a 2-state value in the
// most significant bits of the canonical form: of the svBitVecVal chunks of a
// 2-state union, and of the aval bits of the svLogicVecVal chunks of a
// 4-state one. §7.3.2: the tag has the fewest bits that code all member
// names, here 2 bits for three members and 1 bit for two; the members' bits
// are right-justified, and the bits between them and the tag are undefined.
// The tag values follow the order of the members, from 0.
//
// two_t has 2 + 12 = 14 bits, its tag in bits 13:12; four_t has 1 + 4 = 5
// bits, its tag in bit 4. c_two prints the tag bits and the member bits, the
// 8-bit member of the first value masked to 8 bits since bits 11:8 are
// undefined. c_four prints the 5 bits of aval and bval: for tagged b 4'b10xz
// the tag bit is 1 in aval and 0 in bval, and the member bits are 1, 0, x
// and z (aval 1010, bval 0011, H.10.1.2).
//
// Icarus Verilog 13.0 has no DPI, and Verilator 5.052 does not support
// tagged unions, so :oracle: names no simulator.

module test_dpi_packed_tagged_union_tag_bits;
  typedef union tagged packed {
    bit [7:0] narrow;
    bit [11:0] wide;
    bit [11:0] other;
  } two_t;
  typedef union tagged packed {
    logic [3:0] a;
    logic [3:0] b;
  } four_t;

  import "DPI-C" function void c_two(input string name, input two_t u);
  import "DPI-C" function void c_four(input four_t v);

  two_t u;
  four_t v;

  initial begin
    u = tagged narrow 8'h5a;
    c_two("narrow", u);
    u = tagged wide 12'habc;
    c_two("wide", u);
    u = tagged other 12'h123;
    c_two("other", u);
    v = tagged b 4'b10xz;
    c_four(v);
  end
endmodule

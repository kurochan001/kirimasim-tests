/*
:name: test_dpi_packed_canonical
:description: A packed bit array reaches C in the canonical form, 32 bits per svBitVecVal word with the least significant word first, and the bit-select and part-select utilities read and write it (IEEE 1800-2023 Section H.7.7)
:tags: ch35
:type: simulation
:lrm: 1800-2023 H.7.7 H.8.4 H.11.5 35.5.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_packed_canonical.c
:expected_stdout: @test_dpi_packed_canonical.expected
*/
// IEEE 1800-2023 H.7.7: a packed 2-state array is passed as an array of
// svBitVecVal words, the first holding bits 31:0 and the next the bits above;
// unused bits of the last word are undetermined. H.8.4: such an argument is
// passed by reference. H.11.5: svGetBitselBit, svPutBitselBit and
// svGetPartselBit read and write single bits and up to 32-bit slices, indexed
// from bit 0. The C code counts the ones of a 40-bit value, reverses its bits
// and extracts bits 35:28.

module test_dpi_packed_canonical;
  import "DPI-C" function int dpi_popcount40(input bit [39:0] a);
  import "DPI-C" function void dpi_reverse40(input bit [39:0] a, output bit [39:0] r);
  import "DPI-C" function int dpi_slice_35_28(input bit [39:0] a);
  import "DPI-C" function int dpi_low_word(input bit [39:0] a);

  initial begin
    bit [39:0] a, r;
    a = 40'h5a_1234_00f1;
    dpi_reverse40(a, r);
    $display("ones: %0d", dpi_popcount40(a));
    $display("reversed: %h", r);
    $display("bits 35:28: %h", dpi_slice_35_28(a));
    $display("first word: %h", dpi_low_word(a));
  end
endmodule

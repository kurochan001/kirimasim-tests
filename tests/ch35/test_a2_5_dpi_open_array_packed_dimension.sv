/*
:name: test_a2_5_dpi_open_array_packed_dimension
:description: A DPI import declares an unsized packed dimension as its only packed dimension, and an actual whose packed dimensions together hold eight bits arrives as an open array with no unpacked dimension: the queries of dimension 0 give the normalized packed range [7:0], and the whole array is one packed value in the canonical form (IEEE 1800-2023 Sections 35.5.6.1, H.7.6, H.7.7 and H.12, A.2.5 and A.10)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.6.1 35.6 H.2 H.7.6 H.7.7 H.12.2 H.12.4 A.2.5 A.10
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:dpi_c: @test_a2_5_dpi_open_array_packed_dimension.c
:expected_stdout: @test_a2_5_dpi_open_array_packed_dimension.expected
*/
// IEEE 1800-2023 A.2.5: a packed dimension is a bracketed constant range or an
// unsized dimension; clarification 24 allows the unsized one only as the sole
// packed dimension of a DPI import declaration. H.2: the actual packed
// dimensions of the argument together match that one unsized dimension, and a
// formal of an import may be an open array. H.7.6: the unsized packed
// dimension of the formal has the linearized, normalized range of all packed
// dimensions of the actual. H.12.2: dimension 0 of the array queries is the
// packed part and the queries follow 20.7. H.7.7: a packed 4-state value has
// the canonical form of svLogicVecVal words, the least significant 32 bits
// first. H.12.4: svGetArrayPtr gives the address of the whole array, or NULL
// when the array is not in the C layout.
//
// c_packed takes the packed open array logic [] and the value the caller
// passes. The actual byte_value is logic [7:0] and the actual split_value is
// logic [3:0][1:0], whose two packed dimensions together are eight bits. The
// formal has no unpacked dimension, so each call gives one packed value of
// eight bits: svSize, svLeft and svRight of dimension 0 are 8, 7 and 0. The C
// code compares the low eight bits of the first canonical word with the value
// when svGetArrayPtr gives an address, and accepts NULL, which H.12.4 allows.
// Neither release supports an unsized packed dimension, so the expected
// output follows the standard.
// Corrected on 2026-11-12: the C code took svSizeOfArray, the size in bytes
// (H.12.4), as a number of elements and read eight scalar elements with
// svGetArrElemPtr1, which indexes an unpacked dimension that this formal does
// not have.

module test_a2_5_dpi_open_array_packed_dimension;
  import "DPI-C" function void c_packed(input logic [] v, input int want);

  logic [7:0] byte_value = 8'hA5;
  logic [3:0][1:0] split_value = 8'h02;

  initial begin
    c_packed(byte_value, 32'hA5);
    c_packed(split_value, 32'h02);
  end
endmodule

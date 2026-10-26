/*
:name: test_a2_5_dpi_open_array_packed_dimension
:description: A DPI import declares an unsized packed dimension as its only packed dimension, and an actual whose packed dimensions together hold eight bits arrives as a canonical open array of eight logic elements, each with the same representation as a single logic value (IEEE 1800-2023 Sections 35.5.6.1, 35.6 and H.7.3, A.2.5 and A.10)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.6.1 35.6 H.2 H.7.3 H.12.2 A.2.5 A.10
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
// formal of an import may be an open array. H.7.3: the elements of an open
// array whose element is a 2-state or 4-state scalar have the canonical
// representation of an individual value, and the element with index 0 comes
// first.
//
// c_packed takes the packed open array logic []. The actual byte_value is
// logic [7:0] and the actual split_value is logic [3:0][1:0], whose two packed
// dimensions together are eight bits. Each call therefore gives an open array
// of eight logic elements, with bit 0 first; the C code reads the eight
// elements with svGetArrElemPtr1 and prints their number and the value they
// form. The values of 8'hA5 and 8'h02 give 8 elements and a5, and 8 elements
// and 02. Neither release supports an unsized packed dimension, so the
// expected output follows the standard.

module test_a2_5_dpi_open_array_packed_dimension;
  import "DPI-C" function void c_packed(input logic [] v);

  logic [7:0] byte_value = 8'hA5;
  logic [3:0][1:0] split_value = 8'h02;

  initial begin
    c_packed(byte_value);
    c_packed(split_value);
  end
endmodule

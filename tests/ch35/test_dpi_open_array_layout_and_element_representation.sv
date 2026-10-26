/*
:name: test_dpi_open_array_layout_and_element_representation
:description: An open array of int has the C layout, so svGetArrayPtr gives the address of its elements and svSizeOfArray its total byte size, the elements are in index order, and each element of an open array of logic [7:0] arrives in the canonical two-word representation that a standalone logic [7:0] value has (IEEE 1800-2023 Sections H.7.3 and H.12.4, 35.6.1.1)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.6.1 H.7.3 H.12.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_open_array_layout_and_element_representation.c
:expected_stdout: @test_dpi_open_array_layout_and_element_representation.expected
*/
// IEEE 1800-2023 H.7.3: a stand-alone array passed to an open array formal
// has the canonical representation when its element is a 2- or 4-state
// scalar or packed type, and otherwise the C representation; an element has
// the same representation as an individual value of its type, and elements
// with lower indices come first. H.12.4: svGetArrayPtr gives the actual
// address of the whole array and svSizeOfArray its total size in bytes when
// the layout is the C layout, and the address of an element is always
// available through svGetArrElemPtr1. 35.6.1.1: the packed part of an open
// array has the normalized range and the unpacked dimensions keep the range
// of the actual.
//
// The int array 10, 20, 30, 40 has the C layout, so the pointer is not NULL,
// the size is 16 bytes, the sum read through the pointer is 100, and the
// element pointers give 10 and 40. The array of logic [7:0] 11, 22, 33 is
// read with svGetLogicArrElem1VecVal: each element has aval with the low byte
// 11, 22 or 33 and bval 0, the canonical form of a four-state logic value
// without x or z. The packed size 8 and the unpacked size 3 come from
// svSize.

`timescale 1ns/1ns

module test_dpi_open_array_layout_and_element_representation;
  import "DPI-C" function int c_layout(input int a[]);
  import "DPI-C" function int c_packed(logic [7:0] e[]);

  int ints[4] = '{10, 20, 30, 40};
  logic [7:0] bytes[3] = '{8'h11, 8'h22, 8'h33};

  initial begin
    $display("layout %0d", c_layout(ints));
    $display("packed %0d", c_packed(bytes));
  end
endmodule

/*
:name: test_svdpi_h_open_array_queries_and_whole_pointer
:description: The query functions of svdpi.h give dimension 0 the normalized packed range and dimension 1 the unpacked range of the actual, svDimensions gives the number of unpacked dimensions, and svGetArrayPtr and svSizeOfArray give either the address and byte size of an array in C layout, with the low index of an int array first, or 0 for both (IEEE 1800-2023 Section 35.3.2, I.3, H.12.2, H.12.4)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.3.2 I.3 H.12.2 H.12.4 H.7.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_svdpi_h_open_array_queries_and_whole_pointer.c
:expected_stdout: @test_svdpi_h_open_array_queries_and_whole_pointer.expected
*/
// IEEE 1800-2023 §35.3.2: the C layer of DPI is the one Annex I lists.
// I.3 and H.12.2 give the six query functions the semantics of the
// SystemVerilog queries of 20.7, with dimension 0 for the packed part, which
// is normalized to n-1:0, and dimensions above 0 for the unpacked parts in
// the order the declaration writes them; svDimensions counts the unpacked
// dimensions. H.12.4: svGetArrayPtr gives the address of the whole array and
// svSizeOfArray its size in bytes when the actual is laid out as C lays it
// out, and both are 0 when it is not, which H.7.3 leaves to the
// implementation for a type that is not an int or a real; H.7.3 also puts the
// lower index of each unpacked dimension first, so the elements of an int
// array follow the C order.
//
// c_queries gets logic [7:0] a [5:2] and prints svDimensions and the six
// queries of dimension 0, the packed part, and of dimension 1; the design
// prints the SystemVerilog queries of dimension 1, which have to agree.
// c_whole prints, for an int array [0:3], the address
// and the byte size from the whole-array functions and the four ints read
// through the address, and, for a two-dimensional int array [0:1][0:2], the
// same in C order. For an array of logic [7:0] and one of string, whose
// layout H.7.3 leaves to the implementation, it prints 1 when the address
// and the size are both given or both 0.

module test_svdpi_h_open_array_queries_and_whole_pointer;
  import "DPI-C" function void c_queries(input logic [7:0] a []);
  import "DPI-C" function void c_whole(input int a [], input int m [] [],
                                      input logic [7:0] p [], input string s []);

  logic [7:0] packed_a [5:2] = '{8'hff, 8'h01, 8'haa, 8'h55};
  int a [0:3] = '{10, 20, 30, 40};
  int m [0:1][0:2] = '{'{1, 2, 3}, '{4, 5, 6}};
  logic [7:0] p [0:3] = '{8'h01, 8'h02, 8'h03, 8'h04};
  string s [0:3] = '{"a", "b", "c", "d"};

  initial begin
    $display("SV dim 1: left %0d right %0d low %0d high %0d increment %0d size %0d",
             $left(packed_a, 1), $right(packed_a, 1), $low(packed_a, 1),
             $high(packed_a, 1), $increment(packed_a, 1), $size(packed_a, 1));
    c_queries(packed_a);
    c_whole(a, m, p, s);
  end
endmodule

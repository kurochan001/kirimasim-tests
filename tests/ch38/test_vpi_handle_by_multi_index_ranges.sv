/*
:name: test_vpi_handle_by_multi_index_ranges
:description: vpi_handle_by_multi_index takes the indices of arrays with descending and negative ranges and of a three-dimensional array as written in the source, leftmost first, with an optional bit index, and vpi_put_value through the handles writes the selected elements and bits (IEEE 1800-2023 Section 38.20)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.20 38.34
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_handle_by_multi_index_ranges.c
:expected_stdout: @test_vpi_handle_by_multi_index_ranges.expected
*/
// IEEE 1800-2023 §38.20: vpi_handle_by_multi_index returns the subobject that
// its indices select: one index per unpacked dimension, from the leftmost
// range to the rightmost, with the values used in the source, optionally
// followed by the index of a bit. Indices that do not form a legal select give
// NULL. m has the ranges [2:-1][5:4] and c, an int array, three dimensions.
// At the start of the simulation the application writes through each handle
// with vpi_put_value and vpiNoDelay (38.34); the design prints the elements
// at time 1. A fifth index after the bit of c's element would select a bit of
// a bit, so that handle is NULL.

module test_vpi_handle_by_multi_index_ranges;
  logic [7:0] m [2:-1][5:4];
  int c [1:0][0:1][3:2];

  initial begin
    #1;
    $display("m[-1][5]=%h m[2][4]=%h m[0][4][7]=%b", m[-1][5], m[2][4], m[0][4][7]);
    $display("c[0][1][2]=%0d c[1][0][3]=%0d c[0][0][2]=%0d", c[0][1][2], c[1][0][3], c[0][0][2]);
  end
endmodule

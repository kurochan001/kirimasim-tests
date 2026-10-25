/*
:name: test_dpi_bit_elem_vecval_index_forms
:description: svGetBitArrElemVecVal and svPutBitArrElemVecVal and their one-, two- and three-index forms copy a whole 40-bit packed element of an open array with one, two or three unpacked dimensions to and from two canonical chunks, at the element named by the actual's original indices (IEEE 1800-2023 Section H.12.5)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.6.1 H.12.5 H.12.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_bit_elem_vecval_index_forms.c
:expected_stdout: @test_dpi_bit_elem_vecval_index_forms.expected
*/
// IEEE 1800-2023 §H.12.5: for an open array whose elements are packed bit
// vectors, the Get functions copy one whole element into a canonical
// svBitVecVal buffer that the C code provides, and the Put functions copy a
// buffer into one element. The element is chosen with the original
// SystemVerilog indices of the actual (H.12.1); the forms ending in 1, 2 and
// 3 take that many indices, and the forms without a number take a variable
// list of indices (H.12.3). H.7.7: chunk 0 holds the 32 least significant
// bits and chunk 1 the next ones; the unused upper bits of the last chunk are
// undetermined, so the C code masks them.
//
// The elements are 40 bits wide, so each copy needs two chunks, and the
// unpacked ranges do not start at 0 and run both ways. Every element holds a
// marker byte for its array in bits 39:32, a fixed half word in bits 31:16
// and its indices as hex digits in bits 15:0, so a3[2][1][6] is a3f00d0216.
// c_bit_elems reads six elements, one with each Get form and with one, two
// and three indices for the variable form, into buffers prefilled with
// 0x55555555, and prints both chunks. It then writes six other elements, one
// with each Put form, with values whose two chunks differ from all the
// elements. The design prints every element afterwards: only the six
// written elements change, and they hold exactly the written values.

module test_dpi_bit_elem_vecval_index_forms;
  import "DPI-C" function void c_bit_elems(inout bit [39:0] a1 [], inout bit [39:0] a2 [][],
                                           inout bit [39:0] a3 [][][]);

  bit [39:0] a1 [5:3];
  bit [39:0] a2 [1:2][4:3];
  bit [39:0] a3 [2:1][0:1][7:6];

  initial begin
    foreach (a1[i]) a1[i] = {8'ha1, 16'hc0de, 16'(i)};
    foreach (a2[i, j]) a2[i][j] = {8'ha2, 16'hbeef, 16'(i * 16 + j)};
    foreach (a3[i, j, k]) a3[i][j][k] = {8'ha3, 16'hf00d, 16'(i * 256 + j * 16 + k)};
    c_bit_elems(a1, a2, a3);
    foreach (a1[i]) $display("a1[%0d] = %h", i, a1[i]);
    foreach (a2[i, j]) $display("a2[%0d][%0d] = %h", i, j, a2[i][j]);
    foreach (a3[i, j, k]) $display("a3[%0d][%0d][%0d] = %h", i, j, k, a3[i][j][k]);
  end
endmodule

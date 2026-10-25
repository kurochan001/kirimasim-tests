/*
:name: test_dpi_logic_elem_vecval_index_forms
:description: svGetLogicArrElemVecVal and svPutLogicArrElemVecVal and their one-, two- and three-index forms copy a whole 44-bit packed logic element with x and z bits of an open array with one, two or three unpacked dimensions to and from two canonical aval/bval chunks, at the element named by the actual's original indices (IEEE 1800-2023 Section H.12.5)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.6.1 H.12.5 H.12.3 H.7.7
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:dpi_c: @test_dpi_logic_elem_vecval_index_forms.c
:expected_stdout: @test_dpi_logic_elem_vecval_index_forms.expected
*/
// IEEE 1800-2023 §H.12.5: for an open array whose elements are packed logic
// vectors, the Get functions copy one whole element into a canonical
// svLogicVecVal buffer that the C code provides, and the Put functions copy a
// buffer into one element. The element is chosen with the original
// SystemVerilog indices of the actual (H.12.1); the forms ending in 1, 2 and
// 3 take that many indices, and the forms without a number take a variable
// list of indices (H.12.3). H.7.7: chunk 0 holds the 32 least significant
// bits and chunk 1 the next ones, each as an aval and a bval word with the
// VPI encoding (H.10.1.2, 38.15): 0 is a=0 b=0, 1 is a=1 b=0, z is a=0 b=1 and
// x is a=1 b=1. The unused upper bits of the last chunk are undetermined, so
// the C code masks them.
//
// The elements are 44 bits wide, and every element holds z, x and its array
// number in bits 43:32, an x and a z nibble, a fixed byte and its indices as
// hex digits in bits 15:0, so a3[2][1][6] is zx3xzf00216. c_logic_elems reads
// six elements, one with each Get form and with one, two and three indices
// for the variable form, into buffers prefilled with 0x55555555, and prints
// the aval and bval words of both chunks. It then writes six other elements,
// one with each Put form, with values that have x and z bits in other places.
// The design prints every element afterwards: only the six written elements
// change, and they hold exactly the written values, x and z included.
//
// Icarus Verilog 13.0 has no DPI. Verilator 5.052 rejects the z bits written
// to the array elements as an unsupported tristate construct, and it keeps
// logic variables in two states, so it would read every bval word as 0 and
// drop x and z on the writes; :oracle: names no simulator.

module test_dpi_logic_elem_vecval_index_forms;
  import "DPI-C" function void c_logic_elems(inout logic [43:0] a1 [],
                                             inout logic [43:0] a2 [][],
                                             inout logic [43:0] a3 [][][]);

  logic [43:0] a1 [5:3];
  logic [43:0] a2 [1:2][4:3];
  logic [43:0] a3 [2:1][0:1][7:6];

  initial begin
    foreach (a1[i]) a1[i] = {12'hzx1, 8'hxz, 8'hc0, 16'(i)};
    foreach (a2[i, j]) a2[i][j] = {12'hzx2, 8'hxz, 8'hbe, 16'(i * 16 + j)};
    foreach (a3[i, j, k]) a3[i][j][k] = {12'hzx3, 8'hxz, 8'hf0, 16'(i * 256 + j * 16 + k)};
    c_logic_elems(a1, a2, a3);
    foreach (a1[i]) $display("a1[%0d] = %h", i, a1[i]);
    foreach (a2[i, j]) $display("a2[%0d][%0d] = %h", i, j, a2[i][j]);
    foreach (a3[i, j, k]) $display("a3[%0d][%0d][%0d] = %h", i, j, k, a3[i][j][k]);
  end
endmodule

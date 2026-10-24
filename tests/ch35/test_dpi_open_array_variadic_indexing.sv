/*
:name: test_dpi_open_array_variadic_indexing
:description: The variable-argument indexing functions of svdpi.h reach elements of open arrays with one to four unpacked dimensions, and the specialized one-, two- and three-index functions reach the same elements (IEEE 1800-2023 Section 35.5.6.1, H.12.3)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.6.1 H.12.3 H.12.4 H.12.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_open_array_variadic_indexing.c
:expected_stdout: @test_dpi_open_array_variadic_indexing.expected
*/
// IEEE 1800-2023 §35.5.6.1: an open array formal can have any number of
// unsized unpacked dimensions. H.12.3: as an array can have any number of
// dimensions, the indexing functions take a variable argument list with one
// index per dimension, and specialized forms take exactly one, two or three
// indices. H.12.4: svGetArrElemPtr and svGetArrElemPtr1 to 3 give the address
// of an element; H.12.5: svGetBitArrElemVecVal and svPutBitArrElemVecVal and
// their 1 to 3 forms copy a packed element. The indices are those of the
// actual's ranges.
//
// Each element of the int arrays holds its indices as decimal digits, so
// m4[2][1][2][1] holds 2121. c_index prints the elements that the variadic
// svGetArrElemPtr reaches with one, two, three and four indices, and prints 1
// when the specialized function gives the same address. With the packed
// array b3 it copies an element out with svGetBitArrElemVecVal and its
// three-index form, and writes elements of b3 and of the four-dimensional b4
// with svPutBitArrElemVecVal, which the design prints.
//
// In Verilator 5.052 the variadic functions reach no element of a
// four-dimensional array (svGetArrElemPtr returns NULL with a warning), so
// :oracle: names no simulator; Icarus Verilog 13.0 has no DPI.

module test_dpi_open_array_variadic_indexing;
  import "DPI-C" function void c_index(input int m1 [], input int m2 [][], input int m3 [][][],
                                       input int m4 [][][][], inout bit [7:0] b3 [][][],
                                       inout bit [7:0] b4 [][][][]);

  int m1 [5:3];
  int m2 [0:1][2:1];
  int m3 [1:2][0:1][3:2];
  int m4 [1:2][0:1][3:2][0:2];
  bit [7:0] b3 [1:2][0:1][3:2];
  bit [7:0] b4 [1:2][0:1][3:2][0:2];

  initial begin
    foreach (m1[i]) m1[i] = i;
    foreach (m2[i, j]) m2[i][j] = i * 10 + j;
    foreach (m3[i, j, k]) m3[i][j][k] = i * 100 + j * 10 + k;
    foreach (m4[i, j, k, l]) m4[i][j][k][l] = i * 1000 + j * 100 + k * 10 + l;
    foreach (b3[i, j, k]) b3[i][j][k] = 8'(i * 16 + j * 4 + k);
    foreach (b4[i, j, k, l]) b4[i][j][k][l] = 8'h00;
    c_index(m1, m2, m3, m4, b3, b4);
    $display("b3[1][0][3] = %h, b4[2][1][2][1] = %h, b4[1][0][3][0] = %h", b3[1][0][3],
             b4[2][1][2][1], b4[1][0][3][0]);
  end
endmodule

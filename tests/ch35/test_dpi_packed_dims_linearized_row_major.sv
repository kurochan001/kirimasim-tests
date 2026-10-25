/*
:name: test_dpi_packed_dims_linearized_row_major
:description: Formals with several packed dimensions reach C as one normalized packed dimension in row-major order, where the normalized element [l][m][n] of sizes (i, j, k) is bit n + m*k + l*j*k, for input and output, and a sized formal with three unpacked dimensions is a three-dimensional C array (IEEE 1800-2023 Section 35.5.6, H.7.5, H.7.1, H.11.2)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.6 H.7.5 H.7.1 H.11.2 H.7.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_packed_dims_linearized_row_major.c
:expected_stdout: @test_dpi_packed_dims_linearized_row_major.expected
*/
// IEEE 1800-2023 §35.5.6, H.7.1, H.11.2: a packed type with several
// dimensions is one packed dimension on the C side; the compiler linearizes
// the packed dimensions of a formal, while unpacked arrays can have any
// number of dimensions. H.7.5: linearizing stores the dimensions in
// row-major order, so with dimension sizes (i, j, k) and normalized indices
// l, m, n, the element [l][m][n] is bit n + m*k + l*j*k. H.7.6 b:
// normalizing [L:R] gives the index abs(L-R) to L and 0 to R.
//
// p is bit [2:0][1:0][3:0] (already normalized, sizes 3, 2, 4) with
// p[2][1][3], p[1][0][2] and p[0][1][0] set: bits 23, 10 and 4. q is
// bit [1:3][0:1][7:4] with q[1][0][7], q[2][0][5] and q[3][1][4] set, which
// normalize to [2][1][3], [1][1][1] and [0][0][0]: bits 23, 13 and 0. r is
// logic [1:0][0:2] (sizes 2, 3) with r[1][0] and r[0][2] set: bits 5 and 0.
// The C code prints the values it receives and writes bits 22, 9 and 5 to the
// output po, which are po[2][1][2], po[1][0][1] and po[0][1][1]. The int
// array c3 [0:1][0:2][0:1] goes to a sized formal and is read as
// int[2][3][2] in C.
//
// Icarus Verilog 13.0 has no DPI.

module test_dpi_packed_dims_linearized_row_major;
  import "DPI-C" function void c_sized(input bit [2:0][1:0][3:0] p, input bit [1:3][0:1][7:4] q,
                                       input logic [1:0][0:2] r, output bit [2:0][1:0][3:0] po);
  import "DPI-C" function void c_unpacked(input int c3 [0:1][0:2][0:1]);

  bit [2:0][1:0][3:0] p, po;
  bit [1:3][0:1][7:4] q;
  logic [1:0][0:2] r;
  int c3 [0:1][0:2][0:1];

  initial begin
    p = '0;
    p[2][1][3] = 1'b1;
    p[1][0][2] = 1'b1;
    p[0][1][0] = 1'b1;
    q = '0;
    q[1][0][7] = 1'b1;
    q[2][0][5] = 1'b1;
    q[3][1][4] = 1'b1;
    r = '0;
    r[1][0] = 1'b1;
    r[0][2] = 1'b1;
    c_sized(p, q, r, po);
    $display("po %h: po[2][1][2] %b po[1][0][1] %b po[0][1][1] %b, ones %0d", po, po[2][1][2],
             po[1][0][1], po[0][1][1], $countones(po));
    foreach (c3[i, j, k]) c3[i][j][k] = i * 100 + j * 10 + k;
    c_unpacked(c3);
  end
endmodule

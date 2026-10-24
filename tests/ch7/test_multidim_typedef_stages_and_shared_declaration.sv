/*
:name: test_multidim_typedef_stages_and_shared_declaration
:description: packed and unpacked dimensions built in stages with typedef keep the dimensions of the typedef as the faster-varying ones, and the arrays of one comma-separated declaration share the data type and packed dimensions while their unpacked dimensions differ (IEEE 1800-2023 Section 7.4.4)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4.4 20.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_multidim_typedef_stages_and_shared_declaration.expected
*/
// IEEE 1800-2023 §7.4.4: several packed dimensions can be declared in stages
// with typedef, and so can several unpacked dimensions; the dimensions that
// come from the typedef vary faster than the ones added in the declaration
// that uses it. All arrays of one comma-separated declaration have the same
// data type and the same packed dimensions, but each has its own unpacked
// dimensions.
// pk (tri_t [1:0], tri_t being logic [2:0]) is a 6-bit vector whose dimension
// 1 is [1:0] and dimension 2 is [2:0] (numbered as in §20.7), so pk[1] is its
// upper 3 bits. tab (row_t [0:1], row_t being tri_t [0:3]) has the unpacked
// dimensions [0:1] then [0:3] and the packed one [2:0]. a1, a2 and a3 all get
// logic [3:0]: a3 holds 4 bits, so 4'hf + 1 wraps to 0 in it.
// Icarus Verilog 13.0 makes the [0:3] of row_t the slowest dimension of tab
// (size 4, then 2) and rejects the assignment of tab[1] to one_row.

module test_multidim_typedef_stages_and_shared_declaration;
  typedef logic [2:0] tri_t;
  typedef tri_t row_t [0:3];

  tri_t [1:0] pk;
  row_t tab [0:1];
  row_t one_row;
  logic [3:0] a1 [0:1], a2 [0:2][0:1], a3;

  initial begin
    pk = 6'b101_011;
    $display("pk: bits=%0d dim1=[%0d:%0d] dim2=[%0d:%0d] pk[1]=%0d pk[0]=%0d pk[1][2]=%b",
             $bits(pk), $left(pk, 1), $right(pk, 1), $left(pk, 2), $right(pk, 2),
             pk[1], pk[0], pk[1][2]);

    foreach (tab[i, j]) tab[i][j] = 3'(4 * i + j);
    one_row = tab[1];
    $display("tab: dims=%0d unpacked=%0d size1=%0d size2=%0d bits=%0d row bits=%0d",
             $dimensions(tab), $unpacked_dimensions(tab), $size(tab, 1), $size(tab, 2),
             $bits(tab), $bits(tab[1]));
    $display("tab: [0][3]=%0d [1][0]=%0d [1][2]=%0d one_row[3]=%0d tab[1][2][2]=%b",
             tab[0][3], tab[1][0], tab[1][2], one_row[3], tab[1][2][2]);

    a1[1] = 4'h7;
    a2[2][1] = 4'h9;
    a3 = 4'hf;
    a3 = a3 + 1'b1;
    $display("shared: bits a1[1]=%0d a2[2][1]=%0d a3=%0d; unpacked a1=%0d a2=%0d a3=%0d",
             $bits(a1[1]), $bits(a2[2][1]), $bits(a3), $unpacked_dimensions(a1),
             $unpacked_dimensions(a2), $unpacked_dimensions(a3));
    $display("shared: size a1=%0d a2=%0dx%0d; a1[1]=%h a2[2][1]=%h a3=%h", $size(a1),
             $size(a2, 1), $size(a2, 2), a1[1], a2[2][1], a3);
  end
endmodule

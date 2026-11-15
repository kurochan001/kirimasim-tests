/*
:name: test_procedural_lhs_forms_write_selected_parts
:description: The left-hand side of a procedural assignment can be a whole singular variable, a whole unpacked array, a bit-select, a part-select, a slice of a packed array or a slice of an unpacked array, and each assignment writes exactly the selected bits or elements (IEEE 1800-2023 Section 10.4)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.4
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_procedural_lhs_forms_write_selected_parts.expected
*/
// IEEE 1800-2023 §10.4: the left-hand side of a procedural assignment is a
// variable, written as a singular variable, an aggregate variable, a
// bit-select, part-select or slice of a packed array, or a slice of an
// unpacked array. Each line prints the target after one assignment, so a
// write that reached more or fewer bits or elements than the selected ones
// would change it:
// - whole: v = 16'h1234 writes the singular variable, and ua = ub copies the
//   whole unpacked array ub (10, 11, 12, 13 in hexadecimal).
// - bit: v[0] = 1 changes only bit 0, 1234 -> 1235.
// - part: v[15:12] = 4'hA changes only the top digit, 1235 -> a235.
// - indexed: v[8 +: 4] = 4'h9 changes only bits 11 to 8, a235 -> a935.
// - packed slice: pa has four 4-bit elements; pa[2:1] = 8'hBC writes
//   elements 2 and 1 only, so the zero pa becomes 0bc0.
// - unpacked slice: ub becomes 20, 21, 22, 23, and ua[1:2] = ub[2:3] writes
//   elements 1 and 2 of ua only, so ua is 10, 22, 23, 13.
// Icarus Verilog 13.0 does not compile the assignment of the whole unpacked
// array ub to ua or the slice ua[1:2] on the left-hand side.

module test_procedural_lhs_forms_write_selected_parts;
  logic [15:0] v;
  logic [3:0][3:0] pa;
  logic [7:0] ua [0:3];
  logic [7:0] ub [0:3];

  initial begin
    v = 16'h1234;
    ub = '{8'h10, 8'h11, 8'h12, 8'h13};
    ua = ub;
    $display("whole v=%h ua=%h,%h,%h,%h", v, ua[0], ua[1], ua[2], ua[3]);
    v[0] = 1'b1;
    $display("bit v=%h", v);
    v[15:12] = 4'hA;
    $display("part v=%h", v);
    v[8 +: 4] = 4'h9;
    $display("indexed v=%h", v);
    pa = 16'h0000;
    pa[2:1] = 8'hBC;
    $display("packed slice pa=%h", pa);
    ub = '{8'h20, 8'h21, 8'h22, 8'h23};
    ua[1:2] = ub[2:3];
    $display("unpacked slice ua=%h,%h,%h,%h", ua[0], ua[1], ua[2], ua[3]);
  end
endmodule

/*
:name: test_dpi_open_array_unsized_ranges_per_call
:description: One import with an unsized packed dimension and two unsized unpacked dimensions is called with actuals of different shapes; for each call the query functions give the actual's unpacked ranges and the linearized, normalized range of its packed dimensions, and the access functions take the actual's indices (IEEE 1800-2023 Section 35.5.6.1, H.12, H.6.1, H.7.1)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.6.1 H.12 H.12.1 H.6.1 H.7.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_open_array_unsized_ranges_per_call.c
:expected_stdout: @test_dpi_open_array_unsized_ranges_per_call.expected
*/
// IEEE 1800-2023 §35.5.6.1, H.12: both the sole packed dimension and several
// unpacked dimensions of an open array formal can be unsized, so one import
// takes actuals of different sizes. H.6.1, H.12.1: the unsized ranges are
// decided at each call: the unpacked dimensions are those of the actual, with
// its original ranges and indices, and the packed dimension is all the packed
// dimensions of the actual linearized and normalized (H.7.1), while the rest
// of the type, here bit, comes from the import declaration. H.12.2: dimension
// 0 is the packed part.
//
// c_show is called with x1, bit [3:0][1:0] with unpacked [2:1][0:2], and
// with x2, bit [0:4] with unpacked [5:5][3:0]. For each it prints the ranges
// of dimensions 0, 1 and 2, then reads every element with
// svGetBitArrElem2VecVal at the actual's indices, going from the left bound
// to the right bound of each dimension, and prints it. x1[i][j] holds
// i * 16 + j; the packed [3:0][1:0] is one 8-bit dimension 7:0. The
// ascending bit [0:4] of x2 becomes 4:0 with x2[5][j][0] as bit 4, so
// x2[5][3] = 5'b10011 is 13 and x2[5][2] = 5'b01100 is 0c.
//
// Icarus Verilog 13.0 has no DPI, and Verilator 5.052 does not accept an
// unsized packed dimension in an import declaration, so :oracle: names no
// simulator.

module test_dpi_open_array_unsized_ranges_per_call;
  import "DPI-C" function void c_show(input string name, input bit [] x [][]);

  bit [3:0][1:0] x1 [2:1][0:2];
  bit [0:4] x2 [5:5][3:0];

  initial begin
    foreach (x1[i, j]) x1[i][j] = 8'(i * 16 + j);
    x2[5][3] = 5'b10011;
    x2[5][2] = 5'b01100;
    x2[5][1] = 5'b00001;
    x2[5][0] = 5'b11110;
    c_show("x1", x1);
    c_show("x2", x2);
  end
endmodule

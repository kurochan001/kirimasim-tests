/*
:name: test_dpi_open_array_2d
:description: An open array argument with two unpacked dimensions reports its dimensions, the ranges of each dimension and its elements through the query and access functions of svdpi.h (IEEE 1800-2023 Section 35.5.6.1)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.6.1 H.12.2 H.12.3 H.7.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_open_array_2d.c
:expected_stdout: @test_dpi_open_array_2d.expected
*/
// IEEE 1800-2023 §35.5.6.1, H.12.2: an open array formal int m[][] takes the
// ranges of its actual: svDimensions gives 2, and svLeft, svRight and svSize
// give the declared range of each dimension, [2:0] and [1:3] here (H.7.6).
// H.12.3: svGetArrElemPtr2 takes SystemVerilog indices, so element (2, 1) is
// m[2][1]. dpi_shape returns the numbers packed into one int, and dpi_corner
// sums the elements at the four corners.

module test_dpi_open_array_2d;
  import "DPI-C" function int dpi_shape(input int m[][]);
  import "DPI-C" function int dpi_corner_sum(input int m[][]);

  int m[2:0][1:3];

  initial begin
    foreach (m[i, j]) m[i][j] = 10 * i + j;
    $display("shape: %0d", dpi_shape(m));
    $display("corners: %0d", dpi_corner_sum(m));
  end
endmodule

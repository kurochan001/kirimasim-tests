/*
:name: test_dpi_open_array_query_functions
:description: svLeft, svRight, svLow, svHigh, svIncrement and svSize give for each unsized unpacked dimension of an open array the values that $left, $right, $low, $high, $increment and $size give for the actual, with ascending, descending, negative and single-element ranges, and the range of its packed dimension 0 (IEEE 1800-2023 Section 35.5.6.1, H.12.2, 20.7, H.12.1)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.6.1 H.12.2 20.7 H.12.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_open_array_query_functions.c
:expected_stdout: @test_dpi_open_array_query_functions.expected
*/
// IEEE 1800-2023 §35.5.6.1: a formal argument with unsized unpacked dimensions
// takes actual arrays of any size. H.12.1: each unsized unpacked dimension
// keeps the range of the actual. H.12.2: the query functions follow those of
// 20.7, and dimension 0 is the packed part. §20.7: $left and $right are the
// bounds as written, $increment is 1 when $left is not below $right and -1
// otherwise; $low and $high are the smaller and the larger bound; $size is
// $high - $low + 1. Dimension 1 is the leftmost unpacked dimension.
//
// For each actual the design prints what the SystemVerilog queries give, and
// the C code then prints what the svdpi.h queries give for the same
// dimension, which has to be the same, and for dimension 0, the packed
// [7:0], which is already normalized, so declared and normalized ranges are
// the same (H.7.6). The C code also prints 1 when svIncrement has
// the declared type int (const svOpenArrayHandle, int), compared at compile
// time (C11 _Generic in C, decltype in C++).

module test_dpi_open_array_query_functions;
  import "DPI-C" function void c_query(input string name, input bit [7:0] a [][]);
  import "DPI-C" function void c_types();

  bit [7:0] up_down [2:5][3:1];
  bit [7:0] negative [-1:-3][0:0];

  initial begin
    for (int d = 1; d <= 2; d++)
      $display("up_down dim %0d: SV left %0d right %0d low %0d high %0d increment %0d size %0d",
               d, $left(up_down, d), $right(up_down, d), $low(up_down, d), $high(up_down, d),
               $increment(up_down, d), $size(up_down, d));
    c_query("up_down", up_down);
    for (int d = 1; d <= 2; d++)
      $display("negative dim %0d: SV left %0d right %0d low %0d high %0d increment %0d size %0d",
               d, $left(negative, d), $right(negative, d), $low(negative, d),
               $high(negative, d), $increment(negative, d), $size(negative, d));
    c_query("negative", negative);
    c_types();
  end
endmodule

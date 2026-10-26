/*
:name: test_vpi_array_get_formats
:description: vpi_get_value_array starts at one index per unpacked dimension in textual order, walks the rightmost index fastest, returns integers in value.integers and 40-bit elements as A/B word pairs in value.vectors, and its VPI storage is overwritten by a later call so a copy keeps the values (IEEE 1800-2023 Section 38.16)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.16
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_array_get_formats.c
:expected_stdout: @test_vpi_array_get_formats.expected
*/
// IEEE 1800-2023 38.16: index_p holds one start index per unpacked
// dimension, in the left-to-right order of the declaration, and elements
// come back with the rightmost index varying fastest, each range running
// from its left bound to its right bound. The values are integers in
// value.integers for vpiIntVal, and for vpiVectorVal each element occupies
// ceil(bits/32) A/B word pairs in value.vectors, least significant word
// first. By default VPI's storage may be overwritten by the next call, so a
// caller that keeps values copies them.
//
// m[1:2][4:5] holds 10, 11, 12 and 13 in that textual order, so a read from
// {1, 4} gives 10, 11, 12, 13: the rightmost index 5 runs before the left
// index moves from 1 to 2. wa holds 40-bit vectors, so each occupies two A/B
// word pairs. The application reads m and keeps a copy, reads wa, which
// overwrites VPI's storage, and prints the copy.

`timescale 1ns/1ns

module test_vpi_array_get_formats;
  int m[1:2][4:5];
  logic [39:0] wa[0:1];
  string sa[0:1];
  int da[];

  initial begin
    m[1][4] = 10;
    m[1][5] = 11;
    m[2][4] = 12;
    m[2][5] = 13;
    wa[0] = 40'h1_0000_0001;
    wa[1] = 40'h2_0000_0002;
    sa[0] = "ab";
    sa[1] = "cd";
    da = new[3];
    da[0] = 1;
    da[1] = 2;
    da[2] = 3;
  end

  initial #5 $display("design done");
endmodule

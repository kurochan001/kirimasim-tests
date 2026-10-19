/*
:name: test_dpi_import_output_inout
:description: Output and inout arguments of an imported function are copied back after it returns, and a value change on them wakes processes waiting on the actual (IEEE 1800-2023 Section 35.6.2)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.6.2 35.5.1.2 35.6.1 H.8.8 H.8.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_import_output_inout.c
:expected_stdout: @test_dpi_import_output_inout.expected
*/
// IEEE 1800-2023 §35.5.1.2: an imported function may read the initial value of
// an inout argument, and its changes to output and inout arguments are visible
// to the caller. §35.6.1: they behave like copy-out and copy-in, copy-out.
// §35.6.2: the actual is assigned when the function returns, which is a value
// change that wakes the always procedure on q, which prints the changes after
// time 0. H.8.8: output and inout arguments, including packed arrays
// (svBitVecVal*), are passed by reference; H.8.10: an output string is a const
// char** that C fills in.

`timescale 1ns/1ns

module test_dpi_import_output_inout;
  import "DPI-C" function void dpi_divmod(input int a, input int b, output int q, output int r);
  import "DPI-C" function void dpi_bump(inout int x, input int by);
  import "DPI-C" function void dpi_fill12(output bit [11:0] v);
  import "DPI-C" function void dpi_swap_nibbles(inout bit [7:0] v);
  import "DPI-C" function void dpi_name(output string s);

  int q, r, x;
  bit [11:0] v;
  bit [7:0] n;
  string s;

  always @(q) if ($time > 0) $display("%0d: q changed to %0d", $time, q);

  initial begin
    x = 40;
    n = 8'h3c;
    #1 dpi_divmod(17, 5, q, r);
    #1 $display("divmod: q=%0d r=%0d", q, r);
    dpi_bump(x, 7);
    $display("bump: x=%0d", x);
    dpi_fill12(v);
    $display("fill: v=%h", v);
    dpi_swap_nibbles(n);
    $display("swap: n=%h", n);
    dpi_name(s);
    $display("name: %s", s);
  end
endmodule

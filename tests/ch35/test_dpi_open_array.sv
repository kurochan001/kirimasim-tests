/*
:name: test_dpi_open_array
:description: An open array argument takes arrays of any size and range, and C reads its bounds with svLeft, svRight and svSize and its elements with svGetArrElemPtr1 (IEEE 1800-2023 Section 35.5.6.1)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.6.1 35.6.1.1 H.12.1 H.12.2 H.12.3 H.12.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_open_array.c
:expected_stdout: @test_dpi_open_array.expected
*/
// IEEE 1800-2023 §35.5.6.1: a formal argument with an unsized unpacked
// dimension, int a[], matches actual arrays of any size. §35.6.1.1, H.12.1: the
// unsized dimension takes the range of the actual, here [0:3] and [5:1].
// H.12.2: svLeft, svRight and svSize return that range; H.12.3, H.12.7: an
// element of a C-compatible type such as int is reached through the pointer
// that svGetArrElemPtr1 returns for a SystemVerilog index. dpi_iota writes
// start, start+1, ... from the left index to the right one.

module test_dpi_open_array;
  import "DPI-C" function int dpi_sum(input int a[]);
  import "DPI-C" function void dpi_bounds(input int a[], output int left, output int right,
                                         output int size);
  import "DPI-C" function void dpi_iota(output int a[], input int start);

  int x[0:3] = '{1, 2, 3, 4};
  int y[5:1];

  initial begin
    int l, r, n;
    dpi_bounds(x, l, r, n);
    $display("x: [%0d:%0d], %0d elements, sum %0d", l, r, n, dpi_sum(x));
    dpi_bounds(y, l, r, n);
    $display("y: [%0d:%0d], %0d elements", l, r, n);
    dpi_iota(y, 10);
    foreach (y[i]) $display("y[%0d] = %0d", i, y[i]);
    $display("sum of y: %0d", dpi_sum(y));
  end
endmodule

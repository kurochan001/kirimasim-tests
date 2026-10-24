/*
:name: test_dpi_dynamic_array_actual
:description: A dynamic array or a queue can be the actual of an open array input of an imported function, taking its size and the range [0:n-1], and a dynamic array of equal size can be the actual of a fixed-size array input or output, as for native subroutines (IEEE 1800-2023 Section 35.6.1.1)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.6.1.1 7.7 H.7.6 H.12.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_dynamic_array_actual.c
:expected_stdout: @test_dpi_dynamic_array_actual.expected
*/
// IEEE 1800-2023 §35.6.1.1: a dynamic array can be passed as an actual to an
// imported subroutine by the same rules as for native subroutines (7.7): a
// dynamic array or a queue matches an unsized (open) unpacked dimension, and
// a fixed-size array formal accepts a dynamic array of the same size. The
// open dimension takes the range of the actual (H.12.2), [0:n-1] for a
// dynamic array or queue of n elements; the fixed-size formal a[0:2] has the
// C index 0 for a[0] (H.7.6). dpi_open_info returns the size, the range and
// the sum of an open array; dpi_fixed_sum the sum and the C element 0 of a
// fixed-size array; dpi_fixed_fill writes 7, 8 and 9 into a fixed-size output
// array, which is copied back into the dynamic array. Icarus Verilog 13.0 has
// no DPI, and Verilator 5.052 does not accept a dynamic array as the actual
// of an array formal of an imported function.

module test_dpi_dynamic_array_actual;
  import "DPI-C" function void dpi_open_info(input int a[], output int size, output int left,
                                             output int right, output int sum);
  import "DPI-C" function void dpi_fixed_sum(input int a[0:2], output int sum, output int c0);
  import "DPI-C" function void dpi_fixed_fill(output int a[0:2]);

  int d[];
  int q[$];

  initial begin
    int size, left, right, sum, c0;
    d = new[3];
    d = '{10, 20, 30};
    q = {1, 2, 3, 4};
    dpi_open_info(d, size, left, right, sum);
    $display("open formal, dynamic array: size %0d, range [%0d:%0d], sum %0d", size, left,
             right, sum);
    dpi_open_info(q, size, left, right, sum);
    $display("open formal, queue: size %0d, range [%0d:%0d], sum %0d", size, left, right, sum);
    dpi_fixed_sum(d, sum, c0);
    $display("fixed-size formal, dynamic array: sum %0d, C element 0 is %0d", sum, c0);
    dpi_fixed_fill(d);
    $display("fixed-size output into the dynamic array: size %0d, %0d %0d %0d", d.size(), d[0],
             d[1], d[2]);
  end
endmodule

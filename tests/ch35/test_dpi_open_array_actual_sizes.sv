/*
:name: test_dpi_open_array_actual_sizes
:description: One imported function with an open-array formal takes actual arrays of different sizes and ranges, and C reads each actual's own bounds and elements (IEEE 1800-2023 Section 35.2.2, 35.5.6.1)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.2.2 35.5.6 35.5.6.1 H.12.1 H.12.2 H.12.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_open_array_actual_sizes.c
:expected_stdout: @test_dpi_open_array_actual_sizes.expected
*/
// IEEE 1800-2023 §35.2.2: a formal argument of an imported function may be
// declared as an open array. §35.5.6.1: an unspecified unpacked range, written
// [], matches an actual of any size and range, and the number of unpacked
// dimensions is not restricted. The imported c_sum is called with the 3-, 4-
// and 5-element arrays a3, a4 and a5 and with the two-dimensional m, and
// c_span reports the bounds the actual a4 gives to the open dimension. H.12.2
// gives svLeft, svRight and svSize those bounds; H.12.3 reads an element by
// its SystemVerilog index.
//
// Icarus Verilog 13.0 has no DPI. Verilator 5.052 produces this output.

module test_dpi_open_array_actual_sizes;
  import "DPI-C" function int c_sum(input int a []);
  import "DPI-C" function int c_sum2(input int m [][]);
  import "DPI-C" function void c_span(input int a [], output int left, output int right,
                                     output int size);

  int a3[0:2] = '{1, 2, 3};
  int a4[10:13] = '{4, 5, 6, 7};
  int a5[-1:3] = '{8, 9, 10, 11, 12};
  int m[1:2][3:5] = '{'{1, 2, 3}, '{4, 5, 6}};

  initial begin
    int l, r, n;
    c_span(a4, l, r, n);
    $display("a3 sum=%0d a4 sum=%0d a5 sum=%0d", c_sum(a3), c_sum(a4), c_sum(a5));
    $display("m sum=%0d", c_sum2(m));
    $display("a4 bounds %0d:%0d size %0d", l, r, n);
  end
endmodule

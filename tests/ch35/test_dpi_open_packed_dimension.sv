/*
:name: test_dpi_open_packed_dimension
:description: A formal argument whose packed and unpacked dimensions are both unsized matches actuals with any packed dimensions and any unpacked range; C sees the packed part as the normalized, linearized range of the actual and the unpacked part with the actual's own range (IEEE 1800-2023 Sections 35.5.6.1 and 35.6.1.1)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.6.1 35.6.1.1 H.7.6 H.12.1 H.12.2 H.12.5 35.2.2.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_open_packed_dimension.c
:expected_stdout: @test_dpi_open_packed_dimension.expected
*/
// IEEE 1800-2023 §35.5.6.1: an unsized packed dimension of a formal matches
// any collection of packed dimensions of the actual, and an unsized unpacked
// dimension matches an actual dimension of any size. §35.6.1.1: the unsized
// unpacked dimension takes the range of the actual, and the sole unsized
// packed dimension the linearized, normalized range of the actual's packed
// dimensions, [n-1:0] (H.7.6, H.12.1). H.12.2: svLeft, svRight and svSize
// with dimension 0 query the packed part and with 1 the unpacked one; H.12.5:
// svGetBitArrElem1VecVal reads an element by its SystemVerilog index. The
// formal bit [] v [] gets bit [7:0] a [0:1], bit [1:4] b [3:2] and the
// two-dimensional bit [2:0][3:0] c [5:5]; C returns the packed left, right
// and size, the unpacked left and right, and the element at the left index.
// Icarus Verilog 13.0 has no DPI, and Verilator 5.052 does not parse an
// unsized packed dimension.

module test_dpi_open_packed_dimension;
  import "DPI-C" function void dpi_shape(input bit [] v [], output int pl, output int pr,
                                         output int ps, output int ul, output int ur,
                                         output int first);

  bit [7:0] a [0:1] = '{8'h12, 8'h34};
  bit [1:4] b [3:2] = '{4'h5, 4'h6};
  bit [2:0][3:0] c [5:5] = '{12'habc};

  initial begin
    int pl, pr, ps, ul, ur, first;
    dpi_shape(a, pl, pr, ps, ul, ur, first);
    $display("a: packed [%0d:%0d] size %0d, unpacked [%0d:%0d], first %h", pl, pr, ps, ul, ur,
             first);
    dpi_shape(b, pl, pr, ps, ul, ur, first);
    $display("b: packed [%0d:%0d] size %0d, unpacked [%0d:%0d], first %h", pl, pr, ps, ul, ur,
             first);
    dpi_shape(c, pl, pr, ps, ul, ur, first);
    $display("c: packed [%0d:%0d] size %0d, unpacked [%0d:%0d], first %h", pl, pr, ps, ul, ur,
             first);
  end
endmodule

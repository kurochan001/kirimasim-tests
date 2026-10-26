/*
:name: test_dpi_open_and_unsized_packed
:description: an open unpacked formal takes a dynamic array by its size and range, and the single unsized packed formal takes the actual's full width
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_open_and_unsized_packed.c
:expected_stdout: @test_dpi_open_and_unsized_packed.expected
*/
// IEEE 1800-2023 7.7: the open unpacked formal dimension of a DPI import
// follows the dynamic-array and queue rules, so it matches an actual of any
// size; a DPI formal may also have one unsized packed dimension, under
// 34.5.6.1. The import below has one of each. The C side asks dimension 1 for
// the open unpacked array, which is the dynamic array's size 3 and range
// [0:2], and dimension 0 for the unsized packed part, which is the whole 8-bit
// actual normalized to [7:0]. A tool without DPI cannot run the test, and the
// 5.052 release does not accept an unsized packed dimension in an import.

module test_dpi_open_and_unsized_packed;
  import "DPI-C" function void dpi_info(input int a[], input bit [] v,
                                        output int asize, output int aleft,
                                        output int aright, output int psize,
                                        output int pleft, output int pright);

  int d[];
  bit [7:0] p;

  initial begin
    int asize, aleft, aright, psize, pleft, pright;

    d = new[3];
    d = '{10, 20, 30};
    p = 8'hA5;
    dpi_info(d, p, asize, aleft, aright, psize, pleft, pright);
    $display("unpacked size=%0d left=%0d right=%0d", asize, aleft, aright);
    $display("packed size=%0d left=%0d right=%0d", psize, pleft, pright);
  end
endmodule

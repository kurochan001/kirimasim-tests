/*
:name: test_dpi_bit_scalar_elem_index_forms
:description: svGetBitArrElem and svPutBitArrElem and their one-, two- and three-index forms read and write the scalar bit elements of open arrays with one, two and three unpacked dimensions, at the elements named by the actual's original indices (IEEE 1800-2023 Section H.12.6)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.6.1 H.12.6 H.12.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_bit_scalar_elem_index_forms.c
:expected_stdout: @test_dpi_bit_scalar_elem_index_forms.expected
*/
// IEEE 1800-2023 §H.12.6: an element of an open array that is a scalar bit is
// read as an svBit value returned by svGetBitArrElem and written from an svBit
// value by svPutBitArrElem; the forms ending in 1, 2 and 3 take that many
// indices and the forms without a number take a variable list (H.12.3). The
// indices are the original SystemVerilog indices of the actual (H.12.1).
//
// The arrays have ranges that do not start at 0 and run both ways, and each
// row of bits is different from the others and from its own reverse, so a
// wrong index gives another string. c_bit_scalars visits every element in the
// order of the declared ranges, from the left bound to the right bound with
// the rightmost dimension changing fastest, and prints the bits that the
// numbered Get form and the variable Get form read. It then writes the
// complement of every element with the numbered Put form and prints what the
// variable Get form reads back, and last writes a fixed new pattern with the
// variable Put form, which the design prints in the same order.

module test_dpi_bit_scalar_elem_index_forms;
  import "DPI-C" function void c_bit_scalars(inout bit s1 [], inout bit s2 [][],
                                             inout bit s3 [][][]);

  bit s1 [2:5];
  bit s2 [1:0][0:2];
  bit s3 [1:2][1:0][3:2];

  initial begin
    s1 = '{1, 1, 0, 1};
    s2 = '{'{1, 0, 0}, '{1, 1, 0}};
    s3 = '{'{'{1, 0}, '{0, 0}}, '{'{1, 1}, '{0, 1}}};
    c_bit_scalars(s1, s2, s3);
    $display("final s1: %b%b%b%b", s1[2], s1[3], s1[4], s1[5]);
    $display("final s2: %b%b%b %b%b%b", s2[1][0], s2[1][1], s2[1][2],
             s2[0][0], s2[0][1], s2[0][2]);
    $display("final s3: %b%b %b%b %b%b %b%b", s3[1][1][3], s3[1][1][2], s3[1][0][3],
             s3[1][0][2], s3[2][1][3], s3[2][1][2], s3[2][0][3], s3[2][0][2]);
  end
endmodule

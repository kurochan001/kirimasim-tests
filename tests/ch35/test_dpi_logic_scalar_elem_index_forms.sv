/*
:name: test_dpi_logic_scalar_elem_index_forms
:description: svGetLogicArrElem and svPutLogicArrElem and their one-, two- and three-index forms read and write the scalar logic elements of open arrays with one, two and three unpacked dimensions, with the values 0, 1, z and x, at the elements named by the actual's original indices (IEEE 1800-2023 Section H.12.6)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.6.1 H.12.6 H.12.3 H.10.1.1
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:dpi_c: @test_dpi_logic_scalar_elem_index_forms.c
:expected_stdout: @test_dpi_logic_scalar_elem_index_forms.expected
*/
// IEEE 1800-2023 §H.12.6: an element of an open array that is a scalar logic
// is read as an svLogic value returned by svGetLogicArrElem and written from an
// svLogic value by svPutLogicArrElem; the forms ending in 1, 2 and 3 take that
// many indices and the forms without a number take a variable list (H.12.3).
// The indices are the original SystemVerilog indices of the actual (H.12.1).
// H.10.1.1: the svLogic values of 0, 1, z and x are sv_0, sv_1, sv_z and sv_x.
//
// The arrays have ranges that do not start at 0 and run both ways, every row
// holds different values and differs from its own reverse, and all four
// values occur. c_logic_scalars visits every element in the order of the
// declared ranges, from the left bound to the right bound with the rightmost
// dimension changing fastest, and prints, as 0, 1, z or x, the values that
// the numbered Get form and the variable Get form read. It then replaces
// every value with the next one of 0, 1, z, x, 0 with the numbered Put form,
// so each of the four values is written, and prints what the variable Get
// form reads back. Last it writes a fixed new pattern with the variable Put
// form, which the design prints in the same order with %b.
//
// Icarus Verilog 13.0 has no DPI, and Verilator 5.052 keeps logic variables in
// two states and does not accept the z values written to the array elements,
// so :oracle: names no simulator.

module test_dpi_logic_scalar_elem_index_forms;
  import "DPI-C" function void c_logic_scalars(inout logic l1 [], inout logic l2 [][],
                                               inout logic l3 [][][]);

  logic l1 [2:5];
  logic l2 [1:0][0:2];
  logic l3 [1:2][1:0][3:2];

  initial begin
    l1 = '{1'b1, 1'bz, 1'bx, 1'b0};
    l2 = '{'{1'bx, 1'b0, 1'b1}, '{1'bz, 1'b1, 1'bx}};
    l3 = '{'{'{1'b1, 1'bx}, '{1'bz, 1'b0}}, '{'{1'bx, 1'bz}, '{1'b0, 1'b1}}};
    c_logic_scalars(l1, l2, l3);
    $display("final l1: %b%b%b%b", l1[2], l1[3], l1[4], l1[5]);
    $display("final l2: %b%b%b %b%b%b", l2[1][0], l2[1][1], l2[1][2],
             l2[0][0], l2[0][1], l2[0][2]);
    $display("final l3: %b%b %b%b %b%b %b%b", l3[1][1][3], l3[1][1][2], l3[1][0][3],
             l3[1][0][2], l3[2][1][3], l3[2][1][2], l3[2][0][3], l3[2][0][2]);
  end
endmodule

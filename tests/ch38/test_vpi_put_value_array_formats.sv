/*
:name: test_vpi_put_value_array_formats
:description: vpi_put_value_array writes consecutive array elements from values in the formats vpiRawTwoStateVal, vpiRawFourStateVal, vpiVectorVal, vpiShortIntVal and vpiLongIntVal, laid out per element as the clause describes (IEEE 1800-2023 Section 38.35)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.35 38.15
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_put_value_array_formats.c
:expected_stdout: @test_vpi_put_value_array_formats.expected
*/
// IEEE 1800-2023 §38.35: the values for vpi_put_value_array are laid out by
// format. vpiRawTwoStateVal gives each element ngroups bytes, ngroups being the
// element's bits divided by 8 and rounded up, least significant byte first;
// vpiRawFourStateVal gives ngroups bytes of aval and then ngroups bytes of bval
// per element; vpiVectorVal gives each element its s_vpi_vecval words (38.15),
// least significant first; vpiShortIntVal and vpiLongIntVal give one short or
// one 64-bit integer per element. At the start of the simulation the
// application writes the arrays with these formats, si from index 1 and lv
// from its first index 1, and the design prints them at time 1.

module test_vpi_put_value_array_formats;
  bit [11:0] bv [0:2];
  logic [9:0] fv [0:1];
  logic [39:0] lv [1:2];
  shortint si [0:3];
  longint li [0:1];

  initial begin
    #1;
    $display("bv: %h %h %h", bv[0], bv[1], bv[2]);
    $display("fv: %h %h", fv[0], fv[1]);
    $display("lv: %h %h", lv[1], lv[2]);
    $display("si: %0d %0d %0d %0d", si[0], si[1], si[2], si[3]);
    $display("li: %0d %0d", li[0], li[1]);
  end
endmodule

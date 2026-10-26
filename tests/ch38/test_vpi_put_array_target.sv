/*
:name: test_vpi_put_array_target
:description: vpi_put_value_array writes static unpacked variable arrays with static lifetime and no dynamic dimensions or unpacked element types, here int, shortint, longint, bit and logic arrays (IEEE 1800-2023 Section 38.35)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.35 38.15
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_put_array_target.c
:expected_stdout: @test_vpi_put_array_target.expected
*/
// IEEE 1800-2023 §38.35: vpi_put_value_array modifies contiguous elements of
// a static unpacked variable or net array: an array whose vpiArrayType is
// vpiStaticArray, with static lifetime and without dynamic dimensions or
// dynamic elements, and whose elements are not of an unpacked type. The
// element data type is the array type with all unpacked ranges removed. The
// format selects the layout; vpiIntVal gives one 32-bit integer per element,
// vpiShortIntVal one 16-bit short, vpiLongIntVal one 64-bit long,
// vpiRawTwoStateVal ngroups bytes and vpiRawFourStateVal ngroups aval bytes
// and ngroups bval bytes.
//
// At the start of the simulation the application writes a static int,
// shortint, longint, bit and logic array and each element takes the value
// given. The design prints the arrays at time 1.

module test_vpi_put_array_target;
  int ia [0:1];
  shortint sa [0:1];
  longint la [0:1];
  bit [7:0] ba [0:1];
  logic [7:0] lga [0:1];

  initial begin
    #1;
    $display("ia: %0d %0d", ia[0], ia[1]);
    $display("sa: %0d %0d", sa[0], sa[1]);
    $display("la: %0d %0d", la[0], la[1]);
    $display("ba: %h %h", ba[0], ba[1]);
    $display("lga: %h %h", lga[0], lga[1]);
    $finish;
  end
endmodule

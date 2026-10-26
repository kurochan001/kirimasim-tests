/*
:name: test_vpi_put_array_raw
:description: vpi_put_value_array writes static unpacked arrays with raw four-state bytes to a 2-state array, with raw two-state bytes to a 4-state array, and with shortint, longint and vector values in the union members and word layout of s_vpi_arrayvalue (IEEE 1800-2023 Section 38.35)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.35 38.15
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_put_array_raw.c
:expected_stdout: @test_vpi_put_array_raw.expected
*/
// IEEE 1800-2023 §38.35: vpi_put_value_array writes num consecutive elements
// of a static unpacked array from the element that index_p names. The
// s_vpi_arrayvalue structure has PLI_UINT32 format and flags and a union of
// pointers to PLI_INT32, PLI_INT16, PLI_INT64, PLI_BYTE8, s_vpi_vecval,
// s_vpi_time, double and float arrays. vpiRawFourStateVal gives each element
// ceil(bits/8) aval bytes followed by as many bval bytes; vpiRawTwoStateVal
// gives only the aval bytes. For a 2-state array the bval bytes of a raw
// four-state value are ignored, and for a 4-state array the missing bval of a
// raw two-state value is zero. vpiVectorVal gives consecutive A/B word pairs.
// The vpiOneValue flag writes one given element value to every element of the
// section. The write takes effect at once, as vpiNoDelay does.
//
// At the start of the simulation the application writes b (bit, 2-state) with
// four-state bytes whose bval is not zero, l (logic, 4-state) with two-state
// bytes, lv with vector words, ia with shortint values, la with longint
// values and so with one value for all elements. The design prints them at
// time 1.

module test_vpi_put_array_raw;
  bit [9:0] b [0:1];
  logic [9:0] l [0:1];
  logic [39:0] lv [0:1];
  shortint si [0:2];
  longint la [0:1];

  initial begin
    #1;
    $display("b: %h %h", b[0], b[1]);
    $display("l: %h %h", l[0], l[1]);
    $display("lv: %h %h", lv[0], lv[1]);
    $display("si: %0d %0d %0d", si[0], si[1], si[2]);
    $display("la: %0d %0d", la[0], la[1]);
    $finish;
  end
endmodule

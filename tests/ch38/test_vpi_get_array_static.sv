/*
:name: test_vpi_get_array_static
:description: vpi_get_value_array reads elements of static unpacked arrays from a start index in the raw two-state and four-state, integer, shortint and vector formats, with the bytes and words in the order the clause fixes, and the application copies VPI's storage to keep the values (IEEE 1800-2023 Section 38.16)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.16 38.15 38.13
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_get_array_static.c
:expected_stdout: @test_vpi_get_array_static.expected
*/
// IEEE 1800-2023 §38.16: vpi_get_value_array reads num consecutive elements
// of a static unpacked array from the element that index_p names. The
// s_vpi_arrayvalue structure has PLI_UINT32 format and flags and a union of
// pointers to PLI_INT32, PLI_INT16, PLI_INT64, PLI_BYTE8, s_vpi_vecval,
// s_vpi_time, double and float arrays. vpiRawFourStateVal gives each element
// ceil(bits/8) aval bytes and then as many bval bytes; vpiRawTwoStateVal gives
// only the aval bytes. Either raw format may be requested of the other 4-state
// or 2-state array: the bval bytes of a 2-state array are zero, and a 4-state
// array read as two-state ignores its bval. The bit at position n of an
// element is bit n modulo 8 of rawvals[n/8] for aval, and the same for bval.
// vpiVectorVal gives consecutive A/B word pairs, ceil(bits/32) for each
// element. By default VPI owns the returned storage, and the application
// copies it to keep it.
//
// The application makes each call in a cbAfterDelay callback at time 1 and
// copies the bytes or words into its own arrays before the next call.

module test_vpi_get_array_static;
  logic [8:0] a [0:3];
  bit [9:0] b [0:1];
  logic [9:0] l [0:1];
  int ia [2:5];
  shortint sa [0:2];
  longint la [0:2];
  logic [39:0] lv [0:1];

  initial begin
    a[0] = 9'h003;
    a[1] = 9'h0fe;
    a[2] = 9'h101;
    a[3] = 9'h1ff;
    b[0] = 10'h2a5;
    b[1] = 10'h15a;
    l[0] = 10'h0ff;
    l[1] = 10'h300;
    ia[2] = 18;
    ia[3] = 34;
    ia[4] = 56;
    ia[5] = 78;
    sa[0] = -5;
    sa[1] = 7;
    sa[2] = 300;
    la[0] = 42;
    la[1] = -5;
    la[2] = 1000000;
    lv[0] = 40'h89abcdef12;
    lv[1] = 40'h0000000013;
    #2 $finish;
  end
endmodule

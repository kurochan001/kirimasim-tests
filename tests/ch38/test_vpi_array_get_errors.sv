/*
:name: test_vpi_array_get_errors
:description: vpi_get_value_array returns a NULL value pointer for an unsupported format, a format inconsistent with the element type, a string element and a dynamic array, leaves the application's own pointer usable, and reads a shortreal array through the float shortreals member (IEEE 1800-2023 Section 38.16)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.16
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_array_get_errors.c
:expected_stdout: @test_vpi_array_get_errors.expected
*/
// IEEE 1800-2023 38.16: vpi_get_value_array works on static unpacked
// variable or net arrays with static lifetime. A string element and a
// dynamic array are outside that set, and a format that the clause does not
// list or one inconsistent with the element type is an error. A NULL
// returned value pointer indicates the error, so after an error the union
// member is NULL; the application must free its own allocation even when the
// call overwrote its pointer, and it keeps a separate pointer for that. For
// vpiShortRealVal the values are floats in the shortreals member of the
// union, and the format is appropriate only for arrays of shortreal
// elements, so asking for it on an int array is likewise an error.
//
// The arrays are filled at time 0 and the application runs at time 1. It
// reads sr as three floats, then makes each failing call and prints whether
// the returned pointer is NULL; a buffer that it still holds keeps the value
// 77 that it put there. It also reads m with its own buffer, and reads the
// real, time and 40-bit vector arrays, which use the reals, times and
// vectors members and the A/B word pairs of their formats.

`timescale 1ns/1ns

module test_vpi_array_get_errors;
  int m[1:2][4:5];
  shortreal sr[0:2];
  string sa[0:1];
  logic [39:0] wa[0:1];
  real ra[0:1];
  time ta[0:1];
  int da[];

  initial begin
    m[1][4] = 10;
    m[1][5] = 11;
    m[2][4] = 12;
    m[2][5] = 13;
    sr[0] = 1.5;
    sr[1] = -2.25;
    sr[2] = 3.75;
    sa[0] = "ab";
    wa[0] = 40'h1_0000_0001;
    wa[1] = 40'h2_0000_0002;
    ra[0] = 1.25;
    ra[1] = -2.5;
    ta[0] = 3;
    ta[1] = 4;
    sa[1] = "cd";
    da = new[3];
    da[0] = 1;
    da[1] = 2;
    da[2] = 3;
  end

  initial #5 $display("design done");
endmodule

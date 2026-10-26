/*
:name: test_vpi_array_put_formats
:description: vpi_put_value_array writes a shortreal array through the float shortreals member, real and time arrays through reals and times, int elements with one index per unpacked dimension, and 40-bit elements as consecutive A/B word pairs (IEEE 1800-2023 Section 38.35)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.35
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_array_put_formats.c
:expected_stdout: @test_vpi_array_put_formats.expected
*/
// IEEE 1800-2023 38.35: the format of vpi_put_value_array selects the union
// member and the layout of the values. vpiIntVal takes an array of 32-bit
// integers, vpiRealVal an array of doubles, vpiTimeVal an array of s_vpi_time
// and vpiVectorVal consecutive A/B word pairs, ceil(bits/32) pairs for each
// element. vpiShortRealVal supplies num floats through the shortreals
// member, the member that the prose calls shortrealvals. The object is a
// static unpacked array with static lifetime, and an element is named with
// every unpacked index. The application writes m[2][4] and m[2][5] from
// {2, 4}, then m[1][5] alone, and writes the shortreal, real, time and
// 40-bit vector arrays. The design prints the values at time 2, one time
// unit after the writes, which are not delayed.

`timescale 1ns/1ns

module test_vpi_array_put_formats;
  shortreal fsr[0:2];
  real fr[0:1];
  time ft[0:1];
  int m[1:2][4:5];
  logic [39:0] w[0:1];

  initial begin
    m[1][4] = 10;
    m[1][5] = 11;
    m[2][4] = 12;
    m[2][5] = 13;
  end

  initial begin
    #2 $display("sr=%.2f,%.2f,%.2f r=%.2f,%.2f t=%0t,%0t m=%0d,%0d,%0d,%0d w=%0h,%0h",
                fsr[0], fsr[1], fsr[2], fr[0], fr[1], ft[0], ft[1],
                m[1][4], m[1][5], m[2][4], m[2][5], w[0], w[1]);
    $finish;
  end
endmodule

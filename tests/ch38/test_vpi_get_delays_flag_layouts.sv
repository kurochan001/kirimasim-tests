/*
:name: test_vpi_get_delays_flag_layouts
:description: vpi_get_delays fills 1, 3 or 9 s_vpi_time elements per delay of a module path as mtm_flag and pulsere_flag ask, in the order delay, reject, error and min, typ, max, and writes nothing past those elements (IEEE 1800-2023 Section 38.10)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_get_delays_flag_layouts.c
:expected_stdout: @test_vpi_get_delays_flag_layouts.expected
*/
// IEEE 1800-2023 §38.10, Table 38-2: the application allocates the da array
// of s_vpi_time for vpi_get_delays, and its size follows no_of_delays and
// the two flags. With neither flag each delay takes one element. With only
// mtm_flag each delay takes three, its min, typ and max values. With only
// pulsere_flag each delay takes three, the delay and then its reject and
// error limits. With both flags each delay takes nine: min, typ, max of the
// delay, then of the reject limit, then of the error limit. The delays come
// in source order.
//
// The path of u1 has the delays 6 and 8, and its PATHPULSE$ specparam gives
// the reject limit 2 and the error limit 5 to each delay (30.7.1). The path
// of u2 has distinct min:typ:max values for both delays and both limits, so
// every element of the 18 has its own value. The application reads u1 with
// no flag and with pulsere_flag, and u2 with mtm_flag and with both flags,
// always with two delays and in the time unit of the modules, 1 ns. The
// array has room for 24 elements and every byte is set to 0xA5 first; after
// each call the application prints the elements the table requires and
// whether the bytes of all later elements still hold 0xA5, which they do
// when the routine writes no more elements than the table gives. u2 is not
// read without mtm_flag, since which of its three values a tool then uses
// is a choice of the tool. The release 13.0 of Icarus Verilog rejects the
// min:typ:max limits of PATHPULSE$ as a syntax error, and without them it
// fills only no_of_delays elements, whatever the flags; the 5.054 release
// of Verilator ignores specify blocks. The expected output follows the
// clause alone.

`timescale 1ns/1ns

module test_vpi_get_delays_flag_layouts_plain (input a, output y);
  buf g (y, a);

  specify
    specparam PATHPULSE$a$y = (2, 5);
    (a => y) = (6, 8);
  endspecify
endmodule

module test_vpi_get_delays_flag_layouts_mtm (input a, output y);
  buf g (y, a);

  specify
    specparam PATHPULSE$a$y = (1:2:3, 4:5:6);
    (a => y) = (10:11:12, 20:21:22);
  endspecify
endmodule

module test_vpi_get_delays_flag_layouts;
  logic a = 1'b0;
  wire y1, y2;

  test_vpi_get_delays_flag_layouts_plain u1 (a, y1);
  test_vpi_get_delays_flag_layouts_mtm u2 (a, y2);

  initial #1 $vt_layouts;
endmodule

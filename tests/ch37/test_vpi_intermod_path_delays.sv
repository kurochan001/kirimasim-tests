/*
:name: test_vpi_intermod_path_delays
:description: the delays of an intermodule path between an output port and an input port are set with vpi_put_delays and read back with vpi_get_delays, as two delays and then as three (IEEE 1800-2023 Section 37.37)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.37 38.10 38.22 38.32 37.14
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_intermod_path_delays.c
:expected_stdout: @test_vpi_intermod_path_delays.expected
*/
// IEEE 1800-2023 §37.37: an intermodule path, reached with
// vpi_handle_multi(vpiInterModPath, port1, port2) (detail 1, 38.22), has delays
// that vpi_get_delays and vpi_put_delays access; for an intermodule path
// no_of_delays is 2 or 3 (38.10, 38.32), and the delays keep the order in
// which they are given. Such delays do not appear in the source (37.3.4), so
// the test prints none before it sets them: it puts the delays 4 and 6, reads
// them back as two delays, then puts 1, 2 and 5 and reads them back as three,
// with vpiScaledRealTime in the time unit of the modules, 1 ns. The output
// port of s and the input port of d are joined by the net w; the ports are
// found by iterating vpiPort of each instance (37.14).

`timescale 1ns/1ns

module test_vpi_intermod_path_delays_src (output wire o);
  assign o = 1'b1;
endmodule

module test_vpi_intermod_path_delays_dst (input wire i);
endmodule

module test_vpi_intermod_path_delays;
  wire w;

  test_vpi_intermod_path_delays_src s (.o(w));
  test_vpi_intermod_path_delays_dst d (.i(w));

  initial #1 $vt_path;
endmodule

/*
:name: test_38_extra_intermod_delays
:description: vpi_put_delays accepts two or three delays for an intermodule path and vpi_get_delays reads them back in source order (IEEE 1800-2023 Sections 38.32 and 38.10)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.32 38.10 38.22 37.37
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_38_extra_intermod_delays.c
:expected_stdout: @test_38_extra_intermod_delays.expected
*/
// IEEE 1800-2023 §38.32: for an intermodule path the no_of_delays of
// vpi_put_delays must be 2 or 3. §38.10: vpi_put_delays writes the delays of
// the object from an s_vpi_delay structure and an array of s_vpi_time that the
// application allocates, and vpi_get_delays reads them back in the order of
// the structure. §38.22: the intermodule path between the output port of s and
// the input port of d, which a net joins, is the object of
// vpi_handle_multi(vpiInterModPath, port, port). At time 1 the application
// writes two delays and reads them, then writes three and reads them. The
// time unit is 1 ns, and the delays are read as vpiScaledRealTime.

`timescale 1ns/1ns

module test_38_extra_intermod_delays_src (output wire o);
  assign o = 1'b1;
endmodule

module test_38_extra_intermod_delays_dst (input wire i);
endmodule

module test_38_extra_intermod_delays;
  wire w;

  test_38_extra_intermod_delays_src s (.o(w));
  test_38_extra_intermod_delays_dst d (.i(w));

  initial begin
    #1 $vt_delays;
    #1 $finish;
  end
endmodule

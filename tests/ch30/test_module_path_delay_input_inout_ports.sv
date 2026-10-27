/*
:name: test_module_path_delay_input_inout_ports
:description: A module path delay is the time from a source port to a destination port, with an input or an inout port as the source and an output or an inout port as the destination, while the gates inside have no delay (IEEE 1800-2023 Section 30.2)
:tags: ch30
:type: simulation
:lrm: 1800-2023 30.2 A.7.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_module_path_delay_input_inout_ports.expected
*/
// IEEE 1800-2023 §30.2: module path delays describe the time it takes an
// event at a source, an input port or inout port, to propagate to a
// destination, an output port or inout port. The buffers of mpd_cell have no
// delay. Its paths are from the input a to the output y with 4, from the
// inout io to the output z with 6, and from the input c to the inout w with 3.
// a, io and c rise at 10, 20 and 30; $strobe shows each destination at the
// end of the time step before and at its delay.

`timescale 1ns/1ns

module mpd_cell(input wire a, inout wire io, input wire c, output wire y,
                output wire z, inout wire w);
  buf g1 (y, a);
  buf g2 (z, io);
  buf g3 (w, c);
  specify
    (a => y) = 4;
    (io => z) = 6;
    (c => w) = 3;
  endspecify
endmodule

module test_module_path_delay_input_inout_ports;
  logic a = 1'b0, c = 1'b0, io_drv = 1'b0;
  wire io, y, z, w;
  assign io = io_drv;
  mpd_cell u (.a(a), .io(io), .c(c), .y(y), .z(z), .w(w));
  initial begin
    #10 a = 1'b1;
    #3 $strobe("t=%0t y=%b", $time, y);
    #1 $strobe("t=%0t y=%b", $time, y);
    #6 io_drv = 1'b1;
    #5 $strobe("t=%0t z=%b", $time, z);
    #1 $strobe("t=%0t z=%b", $time, z);
    #4 c = 1'b1;
    #2 $strobe("t=%0t w=%b", $time, w);
    #1 $strobe("t=%0t w=%b", $time, w);
  end
endmodule

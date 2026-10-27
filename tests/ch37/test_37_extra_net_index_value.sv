/*
:name: test_37_extra_net_index_value
:description: A net array gives its elements by index and a vector net gives its bits by index, each element and bit gives its value, and vpi_put_value sets a new value that reads back (IEEE 1800-2023 Section 37.16)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.16 38.15 38.19 38.34
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_37_extra_net_index_value.c
:expected_stdout: @test_37_extra_net_index_value.expected
*/
// IEEE 1800-2023 §37.16 detail 24: vpiSize of an array net is its number of
// nets and that of a net bit is 1; §37.16 detail 30 lists the nets that have
// no value property, so an element of an array net and a net bit do have one.
// §37.16 requires nets to support indexed access with vpi_handle_by_index
// (38.19), reading with vpi_get_value (38.15) and writing with vpi_put_value
// (38.34). The application reads the value of element 1 of the array net
// na, writes 0011 to the undriven element 0 and reads it back, then reads and
// writes bit 3 of the vector net vec. vpi_get_delays of vec reports no delay,
// since a net declared without a delay has none.

`timescale 1ns/1ns

module test_37_extra_net_index_value;
  wire [3:0] na [0:1];
  wire [3:0] vec = 4'b1010;

  assign na[1] = 4'b0101;

  initial #1 $vt_net;
endmodule

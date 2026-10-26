/*
:name: test_vpi_net_driver_objects
:description: A vector net driven by one continuous assignment returns that assignment once from vpiDriver, and its bit returns the continuous assignment bit of that assignment with the offset of the bit (IEEE 1800-2023 Sections 37.16 and 37.46)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.16 37.46 37.47
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_net_driver_objects.c
:expected_stdout: @test_vpi_net_driver_objects.expected
*/
// IEEE 1800-2023 §37.16 detail 18: for a vector net, all drivers are returned
// exactly once as the driving object; if a part-select drives only some bits,
// the driver returned is the part-select, and passing a vpiNetBit object to
// vpi_iterate traces exact bit-by-bit connectivity. §37.46: a continuous
// assignment bit is a member of the net drivers group, so the driver of one
// bit of the assigned vector is the continuous assignment bit of that bit,
// whose vpiOffset is its offset from the LSB (37.47 detail 3). The one
// assignment to w drives both bits, so w has one driver and w[0] has the bit
// of offset 0.

`timescale 1ns/1ns

module test_vpi_net_driver_objects;
  logic [1:0] src = 2'b10;
  wire [1:0] w;
  wire y;

  assign w = src;
  assign y = w[1];

  initial #1 $vt_netdrv;
endmodule

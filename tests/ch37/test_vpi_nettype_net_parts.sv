/*
:name: test_vpi_nettype_net_parts
:description: A net declared with a nettype has vpiNetType vpiNettypeNet, any part of it has vpiNettypeNetSelect and no driver iteration, and an unpacked array of such nets gives its range and its elements with vpiArrayMember (IEEE 1800-2023 Section 37.16)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.16 6.6.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_nettype_net_parts.c
:expected_stdout: @test_vpi_nettype_net_parts.expected
*/
// IEEE 1800-2023 §37.16 detail 11: the vpiNetType of a net declared with a
// nettype is vpiNettypeNet, and the vpiNetType of any part of such a net is
// vpiNettypeNetSelect; for a net with vpiNettypeNetSelect the iterations
// vpiDriver and vpiLocalDriver shall not be supported, so vpi_iterate returns
// NULL. Detail 28 and detail 2: the array net is an unpacked array with one
// range, its elements are nettype nets and vpiArrayMember is TRUE for each.
// The additional type property is printed with its integer value and with the
// constant name that vpi_get_str returns (37.3.2).

`timescale 1ns/1ns

module test_vpi_nettype_net_parts;
  typedef logic [3:0] nt_nib;
  nettype logic nt_bit;
  nettype nt_nib nt_word;

  nt_bit b;
  nt_word w;
  nt_word wa [0:1];
  logic d = 1'b1;

  assign b = d;
  assign w = 4'h9;

  initial #1 $vt_ntnets;
endmodule

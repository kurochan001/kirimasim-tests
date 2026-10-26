/*
:name: test_vpi_net_bits_constant_select
:description: A scalared and a vectored logic net both give their net bits with their indices, and vpiConstantSelect is TRUE for a net without a parent, for a struct member select and for a select with only constant indices, and FALSE when an index is a variable (IEEE 1800-2023 Section 37.16)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.16 11.5.1 37.47
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_net_bits_constant_select.c
:expected_stdout: @test_vpi_net_bits_constant_select.expected
*/
// IEEE 1800-2023 §37.16: for logic and bit nets the net bits are available
// regardless of vector expansion (detail 3), each with the vpiIndex of detail
// 10 and the vpiExpanded value of its parent (detail 21); whether a vector is
// expanded is up to the tool, so only the Boolean form and the equality are
// printed. vpiConstantSelect is TRUE for a net or net bit with no parent or
// when every index of its select is an elaboration-time constant and every
// element is a struct or union member or a member of a packed or unpacked
// array with static bounds, and FALSE otherwise (detail 23). The right-hand
// sides of the continuous assignments (37.47) are the select expressions
// snet.lo[1] (a struct member and a constant bit index), mda[0][1] (two
// constant packed indices) and mda[i][0] (a variable index).

`timescale 1ns/1ns

module test_vpi_net_bits_constant_select;
  typedef struct packed {
    logic [3:0] hi;
    logic [3:0] lo;
  } cs_st;

  int i = 1;
  logic [3:0] src = 4'hA;
  wire scalared [3:0] ws;
  wire vectored [3:0] wv;
  wire cs_st snet;
  wire [1:0][1:0] mda;
  wire y1, y2, y3;

  assign ws = src;
  assign wv = src;
  assign y1 = snet.lo[1];
  assign y2 = mda[0][1];
  assign y3 = mda[i][0];

  initial #1 $vt_cs;
endmodule

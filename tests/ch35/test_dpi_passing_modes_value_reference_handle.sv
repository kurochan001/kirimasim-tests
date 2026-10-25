/*
:name: test_dpi_passing_modes_value_reference_handle
:description: In one import call the small inputs (byte, shortint, int, longint, real, shortreal, chandle, string, scalar bit and logic) arrive by value, packed, integer and time inputs and every output and inout by pointer, and an open array by handle; every function result type that may be returned is returned by value (IEEE 1800-2023 Section 35.5.5, H.2, H.8.1, H.8.3)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.5 H.2 H.8.1 H.8.3 H.8.4 H.8.7 H.8.8 H.8.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_passing_modes_value_reference_handle.c
:expected_stdout: @test_dpi_passing_modes_value_reference_handle.expected
*/
// IEEE 1800-2023 H.2, H.8.1, H.8.3: only small values of input formals are
// passed by value, and so is the function result, which can only be a small
// value (35.5.5, H.8.9); every other formal except an open array is passed by
// direct reference, and an open array by a handle reached through library
// functions. The C code declares the C type that matches each formal for its
// passing mode. H.8.7: the small types are byte, shortint, int, longint,
// real, shortreal, scalar bit and logic, chandle and string; other inputs go
// by reference, a const pointer. H.8.4, H.8.8: an argument passed by
// reference is a T* (svBitVecVal* or svLogicVecVal* for packed data), and
// outputs and inouts are always passed by reference.
//
// c_in takes the ten small types by value, then bit [7:0], logic [3:0],
// integer and time by const pointer, and an open array of int by handle; it
// prints each value as C sees it and returns their count. c_out writes byte,
// real, string, bit and logic [7:0] outputs through pointers and adds 1 to an
// inout int through its pointer. The functions r_byte to r_logic return one
// value of each result type, which the design prints.
//
// Icarus Verilog 13.0 has no DPI. Verilator 5.052 gives every other line, but
// passes a shortreal input and result as 0.00 (see test_dpi_shortreal), so
// :oracle: names no simulator.

module test_dpi_passing_modes_value_reference_handle;
  import "DPI-C" function int c_in(input byte b, input shortint s, input int i, input longint l,
                                   input real r, input shortreal sr, input chandle c,
                                   input string str, input bit bt, input logic lg,
                                   input bit [7:0] pb, input logic [3:0] pl, input integer ig,
                                   input time t, input int oa []);
  import "DPI-C" function void c_out(output byte ob, output real orl, output string os,
                                     output bit obt, output logic [7:0] opl, inout int ioi);
  import "DPI-C" function chandle c_handle();
  import "DPI-C" function byte r_byte();
  import "DPI-C" function shortint r_shortint();
  import "DPI-C" function int r_int();
  import "DPI-C" function longint r_longint();
  import "DPI-C" function real r_real();
  import "DPI-C" function shortreal r_shortreal();
  import "DPI-C" function string r_string();
  import "DPI-C" function bit r_bit();
  import "DPI-C" function logic r_logic();

  int oa [2:0];
  byte ob;
  real orl;
  string os;
  bit obt;
  logic [7:0] opl;
  int ioi;
  int n;
  chandle h;

  initial begin
    oa = '{30, 20, 10};
    h = c_handle();
    n = c_in(-5, -300, 70000, 64'sd5000000000, 2.5, 0.75, h, "abc", 1'b1, 1'b1, 8'hc3,
             4'b1001, -2, 64'h0000_0002_8000_0001, oa);
    $display("c_in returned %0d", n);
    ioi = 9;
    c_out(ob, orl, os, obt, opl, ioi);
    $display("ob %0d orl %0.2f os %s obt %b opl %h ioi %0d", ob, orl, os, obt, opl, ioi);
    $display("results: %0d %0d %0d %0d %0.3f %0.3f %s %b %b", r_byte(), r_shortint(), r_int(),
             r_longint(), r_real(), r_shortreal(), r_string(), r_bit(), r_logic());
  end
endmodule

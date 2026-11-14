/*
:name: test_vpi_udp_entry_vector_storage
:description: the vector value of a UDP table entry with five or nine symbols spreads them over two or three s_vpi_vecval elements, four symbols each, two bytes per symbol, with a NUL second byte for a one-character symbol and both characters of an edge (IEEE 1800-2023 Section 38.15)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.15
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_udp_entry_vector_storage.c
:expected_stdout: @test_vpi_udp_entry_vector_storage.expected
*/
// IEEE 1800-2023 §38.15: read with vpiVectorVal, a UDP table entry gives an
// array of s_vpi_vecval with ((symbols - 1) / 4 + 1) elements. Every symbol
// takes two bytes, so one element holds four symbols: the upper and lower
// halves of aval, then the upper and lower halves of bval. The first
// character of a symbol is the more significant byte of its half, and when
// the symbol has only one character the second byte is NUL. An edge such as
// (0x) is one symbol of two characters (Table 29-1).
//
// Each UDP has one table entry, so the order of the vpiTableEntry iteration
// does not matter. The entry of the combinational UDP has four inputs and
// the output, five symbols, so the fifth one is in the second element. The
// entry of the sequential UDP has seven inputs, the current state and the
// next state, nine symbols, so the ninth one is in the third element; its
// first input is the edge (0x), which has no one-letter form. The
// application gets each definition from its instance and prints, for every
// symbol, the element it is read from and the 16-bit half in hex. The rest
// of the last element is not printed, since the clause does not fix it.
// The release 13.0 of Icarus Verilog rejects the table symbol b and its
// vpi_user.h lacks vpiTableEntry, and the 5.054 release of Verilator
// rejects $vt_entries as an unknown PLI call, so the expected output
// follows the clause alone.

`timescale 1ns/1ns

primitive test_vpi_udp_entry_vector_storage_comb (output y, input a, b, c, d);
  table
    1 0 ? b : 1;
  endtable
endprimitive

primitive test_vpi_udp_entry_vector_storage_seq (output reg q,
                                                 input a, b, c, d, e, f, g);
  table
    (0x) 1 0 ? b x 1 : ? : -;
  endtable
endprimitive

module test_vpi_udp_entry_vector_storage;
  logic a = 1'b0;
  wire y, q;

  test_vpi_udp_entry_vector_storage_comb u1 (y, a, a, a, a);
  test_vpi_udp_entry_vector_storage_seq u2 (q, a, a, a, a, a, a, a);

  initial #1 $vt_entries;
endmodule

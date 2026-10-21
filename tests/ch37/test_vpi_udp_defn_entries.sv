/*
:name: test_vpi_udp_defn_entries
:description: vpi_iterate(vpiUdpDefn, NULL) gives the UDP definitions; a definition gives its io declarations and its table entries, whose vector value holds the ASCII symbols of the entry in the layout the standard fixes; the terminals of a UDP instance give their direction, index and value; vpi_put_value sets the state of a sequential UDP at once (IEEE 1800-2023 Sections 37.36 and 37.35)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.36 37.35 38.15 38.34 29.3 29.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_udp_defn_entries.c
:expected_stdout: @test_vpi_udp_defn_entries.expected
*/
// IEEE 1800-2023 §37.36: vpi_iterate(vpiUdpDefn, NULL) gives the UDP
// definitions of the design, each with vpiDefName, vpiSize (its number of
// inputs), its io declarations (29.3) and its table entries (29.4). Only a
// string and a vector can be read from a table entry (detail 1); the form of
// the string is not fixed, but §38.15 fixes the vector: each symbol of the
// entry takes two bytes, NUL in the second when the symbol has one
// character, four symbols per s_vpi_vecval, in the upper and lower halves of
// aval and then of bval, most significant first; the entry's vpiSize is its
// number of symbols. §37.35: the terminals of the instance u1 give
// vpiDirection, vpiTermIndex (0 for the first, the output, detail 3) and
// their values; vpi_handle(vpiUdpDefn, u1) is and2. §38.34: vpi_put_value
// with vpiNoDelay on the sequential UDP u2 sets its state to 1 at once
// (detail 2). After that its own table rules again (29.6, 29.9): arm falling
// to 0 clears hit through the level entry, and a falling trig while arm is 1
// sets it through the edge entry f. Lists are sorted.

`timescale 1ns/1ns

primitive test_vpi_udp_defn_entries_and2 (output y, input a, b);
  table
    1 1 : 1;
    0 ? : 0;
    ? 0 : 0;
  endtable
endprimitive

primitive test_vpi_udp_defn_entries_catch (output reg hit, input arm, trig);
  initial hit = 1'b0;
  table
    0 ? : ? : 0;
    1 f : ? : 1;
    1 r : ? : -;
    p ? : ? : -;
  endtable
endprimitive

module test_vpi_udp_defn_entries;
  logic a = 1, b = 1, arm = 1, trig = 1;
  wire y, hit;

  test_vpi_udp_defn_entries_and2 u1 (y, a, b);
  test_vpi_udp_defn_entries_catch u2 (hit, arm, trig);

  initial begin
    #1 $vt_udp;
    #1 $display("hit after vpi_put_value: %b", hit);
    arm = 0;
    #1 $display("hit after arm falls: %b", hit);
    arm = 1;
    #1 trig = 0;
    #1 $display("hit after trig falls with arm at 1: %b", hit);
  end
endmodule

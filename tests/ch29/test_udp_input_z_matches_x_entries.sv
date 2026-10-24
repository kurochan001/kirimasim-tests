/*
:name: test_udp_input_z_matches_x_entries
:description: A z value on a UDP input is treated as x, so it selects the table entries written for x, both the level entries of a combinational UDP and the transitions of an edge-sensitive UDP (IEEE 1800-2023 Section 29.2)
:tags: ch29
:type: simulation
:lrm: 1800-2023 29.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_udp_input_z_matches_x_entries.expected
*/
// IEEE 1800-2023 §29.2: z values passed to UDP inputs shall be treated the
// same as x values. The table of uzx_comb gives 1 for an x on either input
// with the other input 0, and 0 for every combination of 0 and 1 except
// 1 1, so a z read as x gives 1, a z read as 0 or 1 gives 0, and a z that
// matched no entry would give x. uzx_edge sets its state to 1 on a 0-to-x
// transition of clk, to 0 on 0-to-1, and keeps it on the way back to 0; a
// change of clk from 0 to z is a 0-to-x transition.

`timescale 1ns/1ns

primitive uzx_comb(y, a, b);
  output y;
  input a, b;
  table
    // a b : y
       0 0 : 0;
       0 1 : 0;
       1 0 : 0;
       1 1 : 1;
       x 0 : 1;
       0 x : 1;
  endtable
endprimitive

primitive uzx_edge(q, clk);
  output q;
  reg q;
  input clk;
  initial q = 1'b0;
  table
    // clk  : q : q+
       (01) : ? : 0;
       (0x) : ? : 1;
       (x0) : ? : -;
       (10) : ? : -;
  endtable
endprimitive

module test_udp_input_z_matches_x_entries;
  logic a = 1'b0, b = 1'b0, clk = 1'b0;
  wire y, q;
  uzx_comb c (y, a, b);
  uzx_edge e (q, clk);
  initial begin
    #1 a = 1'bx;
    #1 $display("a=x b=0: y=%b", y);
    a = 1'bz;
    #1 $display("a=z b=0: y=%b", y);
    a = 1'b0; b = 1'bz;
    #1 $display("a=0 b=z: y=%b", y);
    clk = 1'bz;
    #1 $display("clk 0->z: q=%b", q);
    clk = 1'b0;
    #1 $display("clk z->0: q=%b", q);
    clk = 1'b1;
    #1 $display("clk 0->1: q=%b", q);
    clk = 1'b0;
    #1 clk = 1'bx;
    #1 $display("clk 0->x: q=%b", q);
  end
endmodule

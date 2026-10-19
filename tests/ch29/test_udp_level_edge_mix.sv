/*
:name: test_udp_level_edge_mix
:description: In a sequential UDP that mixes edge-sensitive and level-sensitive entries, a level-sensitive entry wins when both match (IEEE 1800-2023 Section 29.9)
:tags: ch29
:type: simulation
:lrm: 1800-2023 29.9 29.10 29.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_udp_level_edge_mix.expected
*/
// IEEE 1800-2023 §29.9, §29.10: a sequential UDP (29.7) may mix edge-sensitive
// and level-sensitive entries. When an input changes, the edge-sensitive entries
// are looked at first and the level-sensitive ones after, so when both match
// with different outputs, the level-sensitive entry decides. Here a rising clock
// captures d whatever clr is, but clr high forces 0, so a rising clock while
// clr is high leaves 0.

primitive udp_mix(q, clk, d, clr);
  output q;
  reg q;
  input clk, d, clr;
  table
  // clk  d  clr  : q : q+
     r    1   ?   : ? : 1;
     r    0   ?   : ? : 0;
     f    ?   ?   : ? : -;
     ?    *   ?   : ? : -;
     ?    ?   1   : ? : 0;
     ?    ?  (10) : ? : -;
  endtable
endprimitive

module test_udp_level_edge_mix;
  reg clk, d, clr;
  wire q;

  udp_mix u(q, clk, d, clr);

  initial begin
    clk = 0; d = 0; clr = 1;
    #1 $display("clr high: q=%b", q);
    d = 1;
    #1 clk = 1;
    #1 $display("rising clock with d=1 while clr is high: q=%b", q);
    clk = 0;
    #1 clr = 0;
    #1 $display("clr released: q=%b", q);
    clk = 1;
    #1 $display("rising clock with d=1: q=%b", q);
    clr = 1;
    #1 $display("clr high again: q=%b", q);
  end
endmodule

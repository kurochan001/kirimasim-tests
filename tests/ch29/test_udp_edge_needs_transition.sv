/*
:name: test_udp_edge_needs_transition
:description: An edge symbol matches a transition, not a level, so a clock that is already 1 at the start of the simulation does not clock a flip-flop until it has gone to 0 and back to 1 (IEEE 1800-2023 Section 29.6)
:tags: ch29
:type: simulation
:lrm: 1800-2023 29.6 29.3.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_udp_edge_needs_transition.expected
*/
// IEEE 1800-2023 §29.6, Table 29-1: the entry (01) matches the change of clk
// from 0 to 1, not the value 1. The clock is x at the start and is set to 1,
// which is the change x1 that (01) does not match, so the flip-flop keeps its
// initial x. A later change 1 to 0 and then 0 to 1 clocks d through.

primitive udp_dff_edge (q, clk, d);
  output q;
  reg q;
  input clk, d;
  table
  // clk  d : q : q+
    (01) 0 : ? : 0;
    (01) 1 : ? : 1;
    (10) ? : ? : -;
    (0x) ? : ? : -;
    (x1) ? : ? : -;
    ?    * : ? : -;
  endtable
endprimitive

module test_udp_edge_needs_transition;
  reg clk, d;
  wire q;

  udp_dff_edge u (q, clk, d);

  initial begin
    clk = 1;
    d = 1;
    #1 $display("clk=%b d=%b: q=%b", clk, d, q);
    clk = 0;
    #1 d = 0;
    #1 clk = 1;
    #1 $display("clk=%b d=%b: q=%b", clk, d, q);
    clk = 0;
    #1 d = 1;
    #1 clk = 1;
    #1 $display("clk=%b d=%b: q=%b", clk, d, q);
  end
endmodule

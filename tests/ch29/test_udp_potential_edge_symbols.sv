/*
:name: test_udp_potential_edge_symbols
:description: In a sequential UDP, p matches the changes 01, 0x and x1, n matches 10, 1x and x0, and * matches any change of the input (IEEE 1800-2023 Section 29.3.6)
:tags: ch29
:type: simulation
:lrm: 1800-2023 29.3.6 29.6 29.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_udp_potential_edge_symbols.expected
*/
// IEEE 1800-2023 §29.3.6, Table 29-1: the symbol p stands for (01), (0x) and
// (x1), a potential positive edge, and n for (10), (1x) and (x0). udp_edge_kind
// gives 1 on a p change and 0 on an n change of clk, so its output tells
// which group each change of clk belongs to, also the changes to and from x.
// udp_any_change toggles on *, any change of its input; it starts at 0 by
// its initial statement (29.7), so after the seven changes it is 1.

primitive udp_edge_kind (q, clk);
  output q;
  reg q;
  input clk;
  table
  // clk : q : q+
     p   : ? : 1;
     n   : ? : 0;
  endtable
endprimitive

primitive udp_any_change (q, clk);
  output q;
  reg q;
  input clk;
  initial q = 0;
  table
  // clk : q : q+
     *   : 0 : 1;
     *   : 1 : 0;
  endtable
endprimitive

module test_udp_potential_edge_symbols;
  reg clk;
  wire kind, toggled;

  udp_edge_kind e (kind, clk);
  udp_any_change t (toggled, clk);

  task step(input logic v);
    logic was;
    was = clk;
    clk = v;
    #1 $display("clk %b -> %b: edge kind q=%b, toggled=%b", was, v, kind, toggled);
    #9;
  endtask

  initial begin
    #10;
    step(1'b0);
    step(1'bx);
    step(1'b0);
    step(1'b1);
    step(1'bx);
    step(1'b1);
    step(1'b0);
  end
endmodule

/*
:name: test_udp_edge_symbol_r_versus_p
:description: In a sequential UDP table r matches only the change 0 to 1 while p also matches 0 to x and x to 1, so the two edge symbols differ on an unknown clock (IEEE 1800-2023 Section 29.3.6)
:tags: ch29
:type: simulation
:lrm: 1800-2023 29.3.6 29.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_udp_edge_symbol_r_versus_p.expected
*/
// IEEE 1800-2023 §29.3.6, Table 29-1: r stands for (01) alone, and p for (01),
// (0x) and (x1). Both toggling primitives list their own edge symbol and hold
// on every other change of clk. Going from 0 to x and from x to 1 toggles the
// p one but not the r one. Going from 1 to 0 keeps both, and going from 0 to 1
// toggles both.

primitive udp_r_only (q, clk);
  output q;
  reg q;
  input clk;
  initial q = 0;
  table
  // clk : q : q+
    r    : 0 : 1;
    r    : 1 : 0;
    (x0) : ? : -;
    (0x) : ? : -;
    (x1) : ? : -;
    (1x) : ? : -;
    (10) : ? : -;
  endtable
endprimitive

primitive udp_p_edge (q, clk);
  output q;
  reg q;
  input clk;
  initial q = 0;
  table
  // clk : q : q+
    p    : 0 : 1;
    p    : 1 : 0;
    (x0) : ? : -;
    (10) : ? : -;
    (1x) : ? : -;
  endtable
endprimitive

module test_udp_edge_symbol_r_versus_p;
  reg clk;
  wire q_r, q_p;

  udp_r_only u_r (q_r, clk);
  udp_p_edge u_p (q_p, clk);

  task step(input logic v);
    logic was;
    was = clk;
    clk = v;
    #1 $display("clk %b -> %b: r=%b p=%b", was, v, q_r, q_p);
  endtask

  initial begin
    clk = 0;
    #1;
    step(1'bx);
    step(1'b1);
    step(1'b0);
    step(1'b1);
  end
endmodule

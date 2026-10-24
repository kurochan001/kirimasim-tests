/*
:name: test_udp_combinational_level_and_edge_kinds
:description: A combinational UDP output follows its current inputs only, while sequential UDPs also use their current state, a level-sensitive one holding it while its enable is 0 and an edge-sensitive one changing only on the edges its table lists (IEEE 1800-2023 Section 29.2)
:tags: ch29
:type: simulation
:lrm: 1800-2023 29.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_udp_combinational_level_and_edge_kinds.expected
*/
// IEEE 1800-2023 §29.2: a combinational UDP uses the values of its inputs to
// determine its next output, and a sequential UDP uses its inputs and the
// current value of its output; a sequential UDP can be level-sensitive or
// edge-sensitive. ukd_and is an and function. ukd_latch passes d while en is 1
// and keeps its state while en is 0. ukd_toggle inverts its current state on
// each rising edge of clk, which needs the current-state field, and keeps it
// on a falling edge. The entries for an x enable whose data equals the state,
// and for a clk change from x to 0, only keep the state if the initial values
// of the inputs reach the UDPs as changes at time 0. The outputs are printed
// between the changes of the inputs.

`timescale 1ns/1ns

primitive ukd_and(y, a, b);
  output y;
  input a, b;
  table
    // a b : y
       0 ? : 0;
       ? 0 : 0;
       1 1 : 1;
  endtable
endprimitive

primitive ukd_latch(q, d, en);
  output q;
  reg q;
  input d, en;
  initial q = 1'b0;
  table
    // d en : q : q+
       ?  0 : ? : -;
       0  1 : ? : 0;
       1  1 : ? : 1;
       0  x : 0 : 0;
       1  x : 1 : 1;
  endtable
endprimitive

primitive ukd_toggle(q, clk);
  output q;
  reg q;
  input clk;
  initial q = 1'b0;
  table
    // clk  : q : q+
       (01) : 0 : 1;
       (01) : 1 : 0;
       (10) : ? : -;
       (x0) : ? : -;
  endtable
endprimitive

module test_udp_combinational_level_and_edge_kinds;
  logic a = 1'b0, b = 1'b1, d = 1'b0, en = 1'b0, clk = 1'b0;
  wire y, lq, tq;
  ukd_and g (y, a, b);
  ukd_latch l (lq, d, en);
  ukd_toggle t (tq, clk);
  initial begin
    #1 $display("t=1 y=%b latch=%b toggle=%b", y, lq, tq);
    a = 1'b1; d = 1'b1; clk = 1'b1;
    #1 $display("t=2 y=%b latch=%b toggle=%b", y, lq, tq);
    b = 1'b0; en = 1'b1; clk = 1'b0;
    #1 $display("t=3 y=%b latch=%b toggle=%b", y, lq, tq);
    b = 1'b1; en = 1'b0; clk = 1'b1;
    #1 $display("t=4 y=%b latch=%b toggle=%b", y, lq, tq);
    d = 1'b0; clk = 1'b0;
    #1 $display("t=5 y=%b latch=%b toggle=%b", y, lq, tq);
    clk = 1'b1;
    #1 $display("t=6 y=%b latch=%b toggle=%b", y, lq, tq);
  end
endmodule

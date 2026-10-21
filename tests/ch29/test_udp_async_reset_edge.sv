/*
:name: test_udp_async_reset_edge
:description: A sequential UDP table combines edge-sensitive clock entries with a level-sensitive asynchronous reset, which clears the output whenever it is low and holds the cleared value when it is released (IEEE 1800-2023 Section 29.6)
:tags: ch29
:type: simulation
:lrm: 1800-2023 29.6 29.5
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_udp_async_reset_edge.expected
*/
// IEEE 1800-2023 §29.6: edge-sensitive entries follow the clock and the
// level-sensitive entry ? ? 0 : ? : 0 clears the output while clr is low,
// whatever the clock and the data do. The entries ? ? (01) : ? : - and
// ? * 1 : ? : - keep the output when clr is released or the data changes
// between clock edges. The output starts at x, which the clear at 0 removes.

`timescale 1ns/1ns

primitive udp_dff_clear (q, clk, d, clr);
  output q;
  reg q;
  input clk, d, clr;
  table
  // clk d clr  : q : q+
    ?   ?  0   : ? : 0;
    ?   ? (01) : ? : -;
    ?   *  1   : ? : -;
    r   0  1   : ? : 0;
    r   1  1   : ? : 1;
    n   ?  1   : ? : -;
  endtable
endprimitive

module test_udp_async_reset_edge;
  reg clk, d, clr;
  wire q;

  udp_dff_clear u (q, clk, d, clr);

  initial begin
    clk = 0;
    d = 0;
    clr = 0;
    #1 $display("t=%0d: clk=%b d=%b clr=%b q=%b", $time, clk, d, clr, q);
    clr = 1;
    #1 $display("t=%0d: clk=%b d=%b clr=%b q=%b", $time, clk, d, clr, q);
    d = 1;
    #1 $display("t=%0d: clk=%b d=%b clr=%b q=%b", $time, clk, d, clr, q);
    clk = 1;
    #1 $display("t=%0d: clk=%b d=%b clr=%b q=%b", $time, clk, d, clr, q);
    d = 0;
    #1 $display("t=%0d: clk=%b d=%b clr=%b q=%b", $time, clk, d, clr, q);
    clk = 0;
    #1 $display("t=%0d: clk=%b d=%b clr=%b q=%b", $time, clk, d, clr, q);
    clr = 0;
    #1 $display("t=%0d: clk=%b d=%b clr=%b q=%b", $time, clk, d, clr, q);
    clr = 1;
    #1 $display("t=%0d: clk=%b d=%b clr=%b q=%b", $time, clk, d, clr, q);
  end
endmodule

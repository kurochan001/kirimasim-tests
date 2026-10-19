/*
:name: test_global_clocking
:description: $global_clock resolves to the global clocking of the closest enclosing instance that declares one, so two instances of one module count the edges of their own global clocks (IEEE 1800-2023 Section 14.14)
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.14
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_global_clocking.expected
*/
// IEEE 1800-2023 §14.14: $global_clock refers to the event of the effective
// global clocking declaration, found by looking in the enclosing instance and
// then upward. gc_count has none, so in s1.c it resolves to the global
// clocking of s1, posedge of clk1, and in s2.c to that of s2, posedge of clk2.
// The top module declares its own global clocking, any change of clk1 or clk2,
// which its own @($global_clock) uses. clk1 rises three times and falls twice,
// clk2 rises twice and falls once.

`timescale 1ns/1ns

module gc_count;
  int n = 0;
  always @($global_clock) n++;
endmodule

module gc_sub(input logic clk);
  global clocking gck @(posedge clk); endclocking
  gc_count c();
endmodule

module test_global_clocking;
  logic clk1 = 0, clk2 = 0;
  int changes = 0;

  global clocking top_clk @(clk1 or clk2); endclocking

  gc_sub s1(clk1);
  gc_sub s2(clk2);

  always @($global_clock) changes++;

  initial begin
    #1 clk1 = 1;
    #1 clk1 = 0;
    #1 clk1 = 1;
    #1 clk1 = 0;
    #1 clk1 = 1;
    #1 clk2 = 1;
    #1 clk2 = 0;
    #1 clk2 = 1;
    #1 $display("s1: %0d, s2: %0d, top: %0d", s1.c.n, s2.c.n, changes);
  end
endmodule

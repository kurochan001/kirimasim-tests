/*
:name: test_global_clocking_lookup_at_assertion
:description: $global_clock in a property declaration is looked up from the assertion that instantiates the property, not from the module that declares it, so the assertion ticks with the global clocking of its own module (IEEE 1800-2023 Section 14.14)
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.14 16.12 16.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_global_clocking_lookup_at_assertion.expected
*/
// IEEE 1800-2023 §14.14: when $global_clock is used in a property
// declaration, the effective global clocking is looked up after the property
// is substituted into the assertion that instantiates it, from the place of
// that assertion and not from the place of the declaration. §16.12: a
// property can be instantiated by a hierarchical name; §16.14.1: the pass
// action of an assertion runs each time it succeeds.
//
// The property p_tick is declared in gc_holder, whose global clocking hg is
// the posedge of hclk (1, 3, 5, ..., 39). It is instantiated by the assertion
// a_tick in the test module, whose global clocking tg is the posedge of tclk
// (5, 15, 25, 35). @($global_clock) 1'b1 succeeds at every tick of its clock,
// so by 40 the pass action has run 4 times with tg. A simulator that looks
// $global_clock up from the declaration counts the 20 ticks of hg.
// Icarus Verilog 13.0 does not support clocking blocks or concurrent
// assertions. The 5.052 release of Verilator prints 20.

`timescale 1ns/1ns

module gc_holder(input logic hclk);
  global clocking hg @(posedge hclk); endclocking
  property p_tick;
    @($global_clock) 1'b1;
  endproperty
endmodule

module test_global_clocking_lookup_at_assertion;
  logic tclk = 0, hclk = 0;
  int n = 0;

  global clocking tg @(posedge tclk); endclocking

  always #5 tclk = ~tclk;
  always #1 hclk = ~hclk;

  gc_holder h(hclk);

  a_tick: assert property (h.p_tick) n++;

  initial begin
    #40;
    $display("passes of a_tick by 40: %0d", n);
    $finish;
  end
endmodule

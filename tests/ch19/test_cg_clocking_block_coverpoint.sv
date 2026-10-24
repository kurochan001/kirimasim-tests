/*
:name: test_cg_clocking_block_coverpoint
:description: A coverpoint of a clocking block signal covers the value that the clocking block sampled, from the Preponed region with a #1step input skew and from the Observed region with a #0 skew (IEEE 1800-2023 Section 19.5)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5 14.13 14.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_clocking_block_coverpoint.expected
*/
// IEEE 1800-2023 §19.5: a coverpoint that denotes a clocking block signal
// samples the value made available by the clocking block: with an input skew
// of #1step the value of the Preponed region, with #0 the value of the
// Observed region. §14.13: a clocking block updates its sampled values before
// it triggers its clocking block event (14.10), so a covergroup sampled at
// @(cb) reads the new values.
//
// d is 1 until the time step of the rising edge of clk, in which d is set to
// 2 just before clk. cb1 (#1step) samples 1 and cb0 (#0) samples 2. Each
// coverpoint has one bin for one value, so its coverage is 100 when that
// value was sampled and 0 otherwise.

`timescale 1ns/1ns

module test_cg_clocking_block_coverpoint;
  bit clk = 0;
  bit [1:0] d = 1;

  clocking cb1 @(posedge clk);
    input #1step d;
  endclocking

  clocking cb0 @(posedge clk);
    input #0 d;
  endclocking

  covergroup cg1 @(cb1);
    old_value: coverpoint cb1.d { bins b = {1}; }
    new_value: coverpoint cb1.d { bins b = {2}; }
  endgroup

  covergroup cg0 @(cb0);
    old_value: coverpoint cb0.d { bins b = {1}; }
    new_value: coverpoint cb0.d { bins b = {2}; }
  endgroup

  cg1 g1 = new;
  cg0 g0 = new;

  initial begin
    #5;
    d = 2;
    clk = 1;
    #1;
    $display("#1step: 1 %.0f, 2 %.0f", g1.old_value.get_inst_coverage(),
             g1.new_value.get_inst_coverage());
    $display("#0: 1 %.0f, 2 %.0f", g0.old_value.get_inst_coverage(),
             g0.new_value.get_inst_coverage());
  end
endmodule

/*
:name: test_cg_coverage_event_kinds
:description: A covergroup is sampled at its clocking event, at its block event, by calls of its own sample method with arguments, of which a defaulted one may be left out, or, with no coverage event, only by calls of the built-in sample() (IEEE 1800-2023 Section 19.3)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.3 19.8 19.8.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_coverage_event_kinds.expected
*/
// IEEE 1800-2023 §19.3: the coverage event of a covergroup may be a clocking
// event, a block event or a sample method with arguments (19.8.1). Without a
// coverage event the covergroup has the built-in sample() without arguments
// (19.8), and it is sampled only when sample() is called; a call of a sample
// method gives the actual arguments that are not defaulted.
//
// Each coverpoint has one bin for one value, so its coverage is 100 when that
// value was sampled and 0 otherwise. v is 1 at the rising edge of clk, which
// samples cg_clock; cg_none, which has no coverage event, is not sampled
// then, although v is later 5 for a while. The end of the task bump, after it
// has set v to 2, samples cg_block. sample(4) of cg_args gives 4 for x and the
// default 3 for y. Finally sample() samples cg_none while v is 5.

`timescale 1ns/1ns

module test_cg_coverage_event_kinds;
  bit clk = 0;
  int v = 0;

  covergroup cg_clock @(posedge clk);
    cp: coverpoint v { bins b = {1}; }
  endgroup

  covergroup cg_block @@(end bump);
    cp: coverpoint v { bins b = {2}; }
  endgroup

  covergroup cg_args with function sample(int x, int y = 3);
    cx: coverpoint x { bins b = {4}; }
    cy: coverpoint y { bins b = {3}; }
  endgroup

  covergroup cg_none;
    cp: coverpoint v { bins b = {5}; }
  endgroup

  cg_clock gc = new;
  cg_block gb = new;
  cg_args ga = new;
  cg_none gn = new;

  task bump();
    v = 2;
  endtask

  initial begin
    #1 v = 5;
    #1 v = 1;
    #1 clk = 1;
    #1 $display("clock event: %.0f; no event, before sample(): %.0f",
                gc.cp.get_inst_coverage(), gn.cp.get_inst_coverage());
    bump();
    $display("block event: %.0f", gb.cp.get_inst_coverage());
    ga.sample(4);
    $display("sample(4): x %.0f, y %.0f", ga.cx.get_inst_coverage(), ga.cy.get_inst_coverage());
    v = 5;
    gn.sample();
    $display("no event, after sample(): %.0f", gn.cp.get_inst_coverage());
  end
endmodule

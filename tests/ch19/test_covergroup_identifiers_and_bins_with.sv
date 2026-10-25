/*
:name: test_covergroup_identifiers_and_bins_with
:description: A covergroup, its instance, two coverpoints, their bins and a cross of the coverpoints are named by identifiers; the bins of one coverpoint are a single value, one bin per value of a range, and one bin per value of a range kept by a with expression; sampling gives the share of the eleven bins that were hit (IEEE 1800-2023 Sections 19.5.1, 19.5.1.1 and 19.6, footnotes 31 and 33 of A.10)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5.1 19.5.1.1 19.6 A.9.3 A.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_covergroup_identifiers_and_bins_with.expected
*/
// IEEE 1800-2023 A.9.3: the names of the covergroup, the covergroup
// instance, the coverpoints, the bins and the cross are identifiers.
// Footnote 31 of A.10: the with expression has an integral result, here
// item % 2 == 0. Footnote 33 of A.10: a coverage expression follows §19.5;
// x and the with expression are integral. §19.5.1: bins zero = {0} is one
// bin, bins low[] = {[0:1]} is one bin for each value of the range, so two,
// and bins even[] = {[0:3]} with (item % 2 == 0) keeps 0 and 2, so two.
// cp_b has one bin. §19.6: the cross of cp_a with cp_b has one bin for each
// of the 5 bins of cp_a and the 1 bin of cp_b, so 5 bins. The covergroup has
// 5 + 1 + 5 = 11 bins.
//
// The samples are x = 0, then 1, then 3, then 2. The first hits zero, low[0]
// and even[0]; the second hits low[1] and one, and with both coverpoints hit
// it also hits the cross bin (low[1], one); the third hits nothing; the
// fourth hits even[1]. After three samples 6 of the 11 bins are covered, and
// after the fourth 7.
//
// Neither Icarus Verilog 13.0 nor Verilator 5.052 gives these counts, so this
// expected output follows the standard.

`timescale 1ns/1ns

class cg_class;
  bit [1:0] x;

  covergroup cg_inst;
    cp_a: coverpoint x {
      bins zero = {0};
      bins low[] = {[0:1]};
      bins even[] = {[0:3]} with (item % 2 == 0);
    }
    cp_b: coverpoint x { bins one = {1}; }
    cx: cross cp_a, cp_b;
  endgroup

  function new();
    cg_inst = new;
  endfunction
endclass

module test_covergroup_identifiers_and_bins_with;
  cg_class c;
  int cov, tot;

  initial begin
    c = new;
    c.x = 0; c.cg_inst.sample();
    c.x = 1; c.cg_inst.sample();
    c.x = 3; c.cg_inst.sample();
    void'(c.cg_inst.get_inst_coverage(cov, tot));
    $display("cg %0d/%0d", cov, tot);
    c.x = 2; c.cg_inst.sample();
    void'(c.cg_inst.get_inst_coverage(cov, tot));
    $display("cg %0d/%0d", cov, tot);
  end
endmodule

/*
:name: test_cg_cross_bin_counts_retain_auto
:description: A user-defined cross bin counts a hit of any of its products, automatic bins are kept for the other products while cross_retain_auto_bins is 1, its default, and are all removed when it is 0 (IEEE 1800-2023 Section 19.6.1)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.6.1 19.7 19.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_cross_bin_counts_retain_auto.expected
*/
// IEEE 1800-2023 §19.6.1: a cross bin associates a count with a set of cross
// products, and the count is incremented every time any of its products
// matches. User-defined and automatic cross bins coexist: by default the
// automatic bins are kept for the products that no user-defined bin selects;
// cross_retain_auto_bins controls this (19.7: 1 by default, 0 removes all
// automatic bins when there is a user-defined bin). get_inst_coverage(c, t)
// gives the covered bins and the bins (19.8).
//
// ca has 3 bins and cb 2, so each cross has 6 products; the user bin a0
// selects <0,0> and <0,1>. keep keeps the 4 other products as automatic bins,
// 5 bins in all, and has at_least 2, so a bin needs two hits; drop sets
// cross_retain_auto_bins 0 and has a0 only. (0, 0) and then (0, 1) give a0 of
// keep two hits through two different products; (2, 1) twice gives the
// automatic bin <2,1> of keep two hits, while drop has no bin for it.

module test_cg_cross_bin_counts_retain_auto;
  bit [1:0] a;
  bit b;

  covergroup cg;
    ca: coverpoint a { bins v[] = {[0:2]}; }
    cb: coverpoint b { bins v[] = {0, 1}; }
    keep: cross ca, cb {
      option.at_least = 2;
      bins a0 = binsof(ca) intersect {0};
    }
    drop: cross ca, cb {
      option.cross_retain_auto_bins = 0;
      bins a0 = binsof(ca) intersect {0};
    }
  endgroup

  cg g = new;

  task automatic put(bit [1:0] va, bit vb);
    int kc, kt, dc, dt;
    a = va;
    b = vb;
    g.sample();
    void'(g.keep.get_inst_coverage(kc, kt));
    void'(g.drop.get_inst_coverage(dc, dt));
    $display("(%0d,%0d): keep %0d/%0d, drop %0d/%0d", va, vb, kc, kt, dc, dt);
  endtask

  initial begin
    $display("cross_retain_auto_bins: keep %0d, drop %0d", g.keep.option.cross_retain_auto_bins,
             g.drop.option.cross_retain_auto_bins);
    put(0, 0);
    put(0, 1);
    put(2, 1);
    put(2, 1);
  end
endmodule

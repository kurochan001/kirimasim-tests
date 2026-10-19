/*
:name: test_cg_cross_select_bins
:description: user-defined cross bins select cross products with binsof, intersect, !, && and ||, the automatically generated bins are kept only for the products no user-defined bin selects, ignore_bins removes products even from user-defined bins, and the cross coverage is the covered bins over the auto bins plus the significant user bins (IEEE 1800-2023 Sections 19.6.1, 19.6.2, 19.11.2)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.6.1 19.6.1.1 19.6.2 19.11.2 19.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_cross_select_bins.expected
*/
// IEEE 1800-2023 §19.6.1: binsof(cp) gives the bins of a coverpoint and
// binsof(cp.bin) one bin; intersect keeps the bins whose values meet a set, !
// negates, and && and || combine selections. Automatically generated cross
// bins are kept for the cross products that no user-defined bin selects.
// §19.6.2: products in ignore_bins are excluded, even from other cross bins.
// §19.11.2: the cross coverage is the number of covered bins over Bc + Bu,
// where Bc is the number of auto bins left and Bu the number of user bins
// other than ignore_bins and illegal_bins; get_inst_coverage(c, t) returns
// both numbers (§19.8). a has the bins lo and hi, b the bins b0, b1 and b2,
// so each cross has 6 products. In x, lo_any selects <lo,*> and hi_12
// <hi,b1> and <hi,b2>, but <hi,b2> is ignored; one auto bin, <hi,b0>, is
// left, so t is 3. In y, hi_or_b0 selects the 4 products with hi or b0, and
// the auto bins <lo,b1> and <lo,b2> are left.

module test_cg_cross_select_bins;
  bit [1:0] va, vb;

  covergroup cg;
    a: coverpoint va { bins lo = {[0:1]}; bins hi = {[2:3]}; }
    b: coverpoint vb { bins b0 = {0}; bins b1 = {1}; bins b2 = {2}; }
    x: cross a, b {
      bins lo_any = !binsof(a) intersect {[2:3]};
      bins hi_12 = binsof(a.hi) && binsof(b) intersect {[1:2]};
      ignore_bins ig = binsof(a.hi) && binsof(b.b2);
    }
    y: cross a, b {
      bins hi_or_b0 = binsof(a.hi) || binsof(b.b0);
    }
  endgroup

  cg inst;

  task automatic put(bit [1:0] pa, bit [1:0] pb);
    int xc, xt, yc, yt;
    va = pa;
    vb = pb;
    inst.sample();
    void'(inst.x.get_inst_coverage(xc, xt));
    void'(inst.y.get_inst_coverage(yc, yt));
    $display("(%0d,%0d): x %0d/%0d %.2f, y %0d/%0d %.2f", pa, pb, xc, xt,
             inst.x.get_inst_coverage(), yc, yt, inst.y.get_inst_coverage());
  endtask

  initial begin
    inst = new;
    put(3, 2);
    put(0, 1);
    put(2, 0);
    put(1, 2);
    put(2, 1);
  end
endmodule

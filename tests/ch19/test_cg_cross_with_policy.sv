/*
:name: test_cg_cross_with_policy
:description: A cross bin with a with clause selects each bin tuple that has enough value tuples for which the expression, written with the names of the crossed coverpoints, is true: at least one by default, all with matches $ and at least N with matches N (IEEE 1800-2023 Section 19.6.1.2)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.6.1.2 19.6.1 19.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_cross_with_policy.expected
*/
// IEEE 1800-2023 §19.6.1.2: in a with clause of a cross bin, the names of the
// crossed coverpoints stand for the values of a value tuple of a candidate bin
// tuple; the bin tuple is selected when enough of its value tuples make the
// expression true. matches N asks for at least N of them, matches $ for all,
// and without matches one is enough. The cross name used as the select
// expression gives all bin tuples. The products that no user bin selects keep
// automatic bins (19.6.1). get_inst_coverage(c, t) gives the covered bins and
// the bins (19.8).
//
// ca and cb each have the bins lo = {0, 1} and hi = {2, 3}, so each bin tuple
// has 4 value tuples. y1 selects <lo,lo> and <hi,hi>, which have a value
// tuple with ca == cb, and keeps 2 automatic bins: 3 bins. y2 needs
// ca + cb <= 4 for all value tuples, true for all bin tuples but <hi,hi>: 1
// user bin and 1 automatic bin. y3 needs ca + cb >= 4 for at least 2 value
// tuples, true for <hi,hi> only: 1 user bin and 3 automatic bins. Selection
// is by bin tuple, so (2, 3) hits the bin of y1 although 2 != 3.

module test_cg_cross_with_policy;
  bit [1:0] a, b;

  covergroup cg;
    ca: coverpoint a { bins lo = {[0:1]}; bins hi = {[2:3]}; }
    cb: coverpoint b { bins lo = {[0:1]}; bins hi = {[2:3]}; }
    y1: cross ca, cb { bins s = y1 with (ca == cb); }
    y2: cross ca, cb { bins s = y2 with (ca + cb <= 4) matches $; }
    y3: cross ca, cb { bins s = y3 with (ca + cb >= 4) matches 2; }
  endgroup

  cg g = new;

  task automatic put(bit [1:0] va, bit [1:0] vb);
    int c[3], t[3];
    a = va;
    b = vb;
    g.sample();
    void'(g.y1.get_inst_coverage(c[0], t[0]));
    void'(g.y2.get_inst_coverage(c[1], t[1]));
    void'(g.y3.get_inst_coverage(c[2], t[2]));
    $display("(%0d,%0d): y1 %0d/%0d, y2 %0d/%0d, y3 %0d/%0d", va, vb, c[0], t[0], c[1], t[1],
             c[2], t[2]);
  endtask

  initial begin
    put(1, 2);
    put(2, 3);
    put(0, 1);
  end
endmodule

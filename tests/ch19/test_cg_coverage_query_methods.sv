/*
:name: test_cg_coverage_query_methods
:description: get_coverage and get_inst_coverage, without arguments or with two ref int arguments, can be called on a covergroup, a coverpoint and a cross at any time; get_inst_coverage gives one instance, the static get_coverage the type through :: or an instance, and the arguments receive the covered and the total bins of the instance or of all instances (IEEE 1800-2023 Section 19.8)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.8 19.11 19.11.1 19.11.2 19.11.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_coverage_query_methods.expected
*/
// IEEE 1800-2023 §19.8: the methods real get_coverage() and real
// get_inst_coverage(), each also with two ref int arguments, are available on
// a covergroup, a coverpoint and a cross and can be called procedurally at
// any time; they return a coverage from 0 to 100. get_inst_coverage gives the
// coverage of the instance it is called on, through the . operator only;
// get_coverage is static and gives the cumulative (type) coverage of all
// instances, through :: on the type or . on an instance. The first argument
// receives the number of covered bins and the second the number of bins: for
// get_inst_coverage of a coverpoint or cross the numerator and denominator of
// its coverage, for a covergroup the sums over its coverpoints and crosses,
// and for get_coverage the sums over all instances.
//
// With merge_instances 0 and all weights 1 (19.11, 19.11.3), the coverage of
// an instance is the average of its items (19.11.1, 19.11.2) and the type
// coverage the average of the instances. g1 = new(1) has cp 2 bins, cq 2 and
// x 4; g2 = new(3) has 4, 2 and 8. g1 samples (0,0) and (1,0): cp 100, cq 50,
// x 50, so 66.67 and 5 of 8 bins. g2 samples (3,1): cp 25, cq 50, x 12.5, so
// 29.17 and 3 of 14. The type is (66.67 + 29.17) / 2 = 47.92 with 8 of 22
// bins; cp is (100 + 25) / 2 = 62.50 with 3 of 6 and x (50 + 12.5) / 2 = 31.25
// with 3 of 12. The test also calls the methods before any sample.

module test_cg_coverage_query_methods;
  bit [1:0] a;
  bit b;

  covergroup cg (int hi);
    cp: coverpoint a { bins v[] = {[0:hi]}; }
    cq: coverpoint b { bins v[] = {0, 1}; }
    x: cross cp, cq;
  endgroup

  cg g1, g2;

  task automatic put(cg g, bit [1:0] va, bit vb);
    a = va;
    b = vb;
    g.sample();
  endtask

  initial begin
    int c, t;
    real r;
    g1 = new(1);
    g2 = new(3);
    r = g1.get_inst_coverage(c, t);
    $display("before sampling: g1 %.2f (%0d/%0d)", r, c, t);
    r = cg::get_coverage(c, t);
    $display("before sampling: type %.2f (%0d/%0d)", r, c, t);
    put(g1, 0, 0);
    put(g1, 1, 0);
    put(g2, 3, 1);
    r = g1.get_inst_coverage(c, t);
    $display("g1: %.2f (%0d/%0d); cp %.2f, cq %.2f, x %.2f", r, c, t,
             g1.cp.get_inst_coverage(), g1.cq.get_inst_coverage(), g1.x.get_inst_coverage());
    r = g2.get_inst_coverage(c, t);
    $display("g2: %.2f (%0d/%0d)", r, c, t);
    r = g2.cp.get_inst_coverage(c, t);
    $display("g2 cp: %.2f (%0d/%0d)", r, c, t);
    r = g2.x.get_inst_coverage(c, t);
    $display("g2 x: %.2f (%0d/%0d)", r, c, t);
    r = cg::get_coverage(c, t);
    $display("type cg: %.2f (%0d/%0d), through g1 %.2f", r, c, t, g1.get_coverage());
    r = cg::cp::get_coverage(c, t);
    $display("type cp: %.2f (%0d/%0d), through g2 %.2f", r, c, t, g2.cp.get_coverage());
    r = g1.x.get_coverage(c, t);
    $display("type x through g1: %.2f (%0d/%0d), through :: %.2f", r, c, t,
             cg::x::get_coverage());
  end
endmodule

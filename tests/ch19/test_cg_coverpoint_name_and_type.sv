/*
:name: test_cg_coverpoint_name_and_type
:description: An unlabeled coverpoint of a variable is named after the variable and a label names the others; a coverpoint without a type has the self-determined type of its expression; without explicit bins it gets automatic bins, at most auto_bin_max of them, 64 by default (IEEE 1800-2023 Section 19.5)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5 19.5.3 19.7 19.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_coverpoint_name_and_type.expected
*/
// IEEE 1800-2023 §19.5: a coverpoint creates a scope; its label names it, and
// without a label a coverpoint of a single variable takes the name of the
// variable. Without a data type, the type of the coverpoint is the
// self-determined type of its expression. An integral coverpoint without
// explicit bins gets automatic bins, whose number auto_bin_max limits (19.7,
// default 64): with M bits there are min(2**M, auto_bin_max) of them (19.5.3).
// get_inst_coverage(c, t) gives the covered bins and the bins (19.8).
//
// coverpoint n has no label and is reached as g.n; lab covers m. n + m of two
// 4-bit variables is 4 bits wide, so it has 16 automatic bins, and 15 + 1
// wraps to 0. sb >>> 1 of the signed byte sb is a signed byte, so -2 >>> 1 is
// -1. The 8-bit wide gets 64 automatic bins by default, 10 with
// auto_bin_max = 10, and none besides its explicit bin when it has one. The
// covergroup is sampled once with n = 15, m = 1, sb = -2 and wide = 7.

module test_cg_coverpoint_name_and_type;
  bit [3:0] n, m;
  byte sb;
  bit [7:0] wide;

  covergroup cg;
    coverpoint n;
    lab: coverpoint m;
    sum: coverpoint (n + m);
    wrap: coverpoint (n + m) { bins zero = {0}; }
    half: coverpoint (sb >>> 1) { bins minus_one = {-1}; }
    wd: coverpoint wide;
    wl: coverpoint wide { option.auto_bin_max = 10; }
    ex: coverpoint wide { bins seven = {7}; }
  endgroup

  cg g = new;

  initial begin
    int c[8], t[8];
    n = 15;
    m = 1;
    sb = -2;
    wide = 7;
    g.sample();
    void'(g.n.get_inst_coverage(c[0], t[0]));
    void'(g.lab.get_inst_coverage(c[1], t[1]));
    void'(g.sum.get_inst_coverage(c[2], t[2]));
    void'(g.wrap.get_inst_coverage(c[3], t[3]));
    void'(g.half.get_inst_coverage(c[4], t[4]));
    void'(g.wd.get_inst_coverage(c[5], t[5]));
    void'(g.wl.get_inst_coverage(c[6], t[6]));
    void'(g.ex.get_inst_coverage(c[7], t[7]));
    $display("n %0d/%0d, lab %0d/%0d", c[0], t[0], c[1], t[1]);
    $display("sum %0d/%0d, wrap %0d/%0d, half %0d/%0d", c[2], t[2], c[3], t[3], c[4], t[4]);
    $display("wd %0d/%0d, wl %0d/%0d, ex %0d/%0d", c[5], t[5], c[6], t[6], c[7], t[7]);
  end
endmodule

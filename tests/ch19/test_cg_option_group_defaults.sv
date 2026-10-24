/*
:name: test_cg_option_group_defaults
:description: at_least and auto_bin_max set for a covergroup are the defaults of its coverpoints and crosses, which can set their own values, while weight, goal and comment of the covergroup are not passed down; a bin is covered once its count reaches at_least, 1 by default (IEEE 1800-2023 Section 19.7)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.7 19.3 19.11.1 19.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_option_group_defaults.expected
*/
// IEEE 1800-2023 §19.7: an instance option set at the covergroup level, other
// than weight, goal, comment and per_instance, is the default of that option
// for all coverpoints and crosses, which may override it; weight, goal and
// comment set for the covergroup do not become those of the items (19.3 says
// the same of options in general). at_least, 1 by default, is the number of
// hits a bin needs to count as covered (19.11.1); it may be set for a
// coverpoint and for a cross (Table 19-2). get_inst_coverage(c, t) gives the
// covered bins and the bins of an item (19.8).
//
// cg_set sets at_least 2 and auto_bin_max 2 for the covergroup: pa and the
// cross ab inherit at_least 2, pb and the cross ab1 set 1; pc inherits 2
// automatic bins, pd sets 4. cg_plain sets nothing. Both covergroups are
// sampled twice with a = b = 1, and the coverage is printed after each.

module test_cg_option_group_defaults;
  bit [1:0] a, b;

  covergroup cg_plain;
    pa: coverpoint a { bins v[] = {[0:3]}; }
  endgroup

  covergroup cg_set;
    option.at_least = 2;
    option.auto_bin_max = 2;
    option.weight = 5;
    option.goal = 90;
    option.comment = "group";
    pa: coverpoint a { bins v[] = {[0:3]}; }
    pb: coverpoint b { option.at_least = 1; bins v[] = {[0:3]}; }
    pc: coverpoint a;
    pd: coverpoint b { option.auto_bin_max = 4; }
    ab: cross pa, pb;
    ab1: cross pa, pb { option.at_least = 1; }
  endgroup

  cg_plain gp = new;
  cg_set gs = new;

  task automatic show();
    int c[5], t[5];
    void'(gp.pa.get_inst_coverage(c[0], t[0]));
    void'(gs.pa.get_inst_coverage(c[1], t[1]));
    void'(gs.pb.get_inst_coverage(c[2], t[2]));
    void'(gs.ab.get_inst_coverage(c[3], t[3]));
    void'(gs.ab1.get_inst_coverage(c[4], t[4]));
    $display("plain pa %0d/%0d; set pa %0d/%0d, pb %0d/%0d, ab %0d/%0d, ab1 %0d/%0d",
             c[0], t[0], c[1], t[1], c[2], t[2], c[3], t[3], c[4], t[4]);
  endtask

  initial begin
    int c, tc, td;
    a = 1;
    b = 1;
    gp.sample();
    gs.sample();
    show();
    gp.sample();
    gs.sample();
    show();
    void'(gs.pc.get_inst_coverage(c, tc));
    void'(gs.pd.get_inst_coverage(c, td));
    $display("automatic bins: pc %0d, pd %0d", tc, td);
    $display("at_least: plain pa %0d; set pa %0d, pb %0d, ab %0d, ab1 %0d",
             gp.pa.option.at_least, gs.pa.option.at_least, gs.pb.option.at_least,
             gs.ab.option.at_least, gs.ab1.option.at_least);
    $display("not passed down: pa weight %0d, goal %0d, comment \"%s\"; ab weight %0d",
             gs.pa.option.weight, gs.pa.option.goal, gs.pa.option.comment,
             gs.ab.option.weight);
  end
endmodule

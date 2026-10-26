/*
:name: test_cg_option_name_unique_and_retain_scope
:description: Each covergroup instance gets a tool-generated unique name by default, and the definition-only cross_retain_auto_bins option set at the covergroup level is the default of its crosses while a cross can set its own value, changing whether automatic cross bins remain (IEEE 1800-2023 Section 19.7)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.7 19.11.2 19.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_option_name_unique_and_retain_scope.expected
*/
// IEEE 1800-2023 §19.7: option.name is a string whose default is a unique
// name generated for each covergroup instance. Table 19-2 allows
// cross_retain_auto_bins at the covergroup and cross levels only; at the
// covergroup level it is the default of every cross, and a cross may set its
// own value. §19.11.2: with two coverpoints of two bins each there are four
// products; a user bin that selects two of them leaves two automatic bins
// when the option is 1 (3 bins in all) and none when it is 0 (1 bin). The
// test sets 0 for cg and overrides it with 1 in cross w, and leaves cg2 at
// the default 1 while cross v sets 0. Sampling (0,0) hits the user bin of
// each cross, whose covered and total bins are read with
// get_inst_coverage(c,t) (19.8).

module test_cg_option_name_unique_and_retain_scope;
  bit [1:0] a, b;

  covergroup cg;
    option.cross_retain_auto_bins = 0;
    ca: coverpoint a { bins v[] = {[0:1]}; }
    cb: coverpoint b { bins v[] = {[0:1]}; }
    x: cross ca, cb {
      bins sel = binsof(ca) intersect {0};
    }
    w: cross ca, cb {
      option.cross_retain_auto_bins = 1;
      bins sel = binsof(ca) intersect {0};
    }
  endgroup

  covergroup cg2;
    ca: coverpoint a { bins v[] = {[0:1]}; }
    cb: coverpoint b { bins v[] = {[0:1]}; }
    y: cross ca, cb {
      bins sel = binsof(ca) intersect {0};
    }
    v: cross ca, cb {
      option.cross_retain_auto_bins = 0;
      bins sel = binsof(ca) intersect {0};
    }
  endgroup

  covergroup cg3;
    option.name = "named";
    cp: coverpoint a;
  endgroup

  cg g1 = new;
  cg g2 = new;
  cg2 h = new;
  cg3 k = new;

  initial begin
    int c[4], t[4];
    $display("retain x %0d w %0d y %0d v %0d", g1.x.option.cross_retain_auto_bins,
             g1.w.option.cross_retain_auto_bins, h.y.option.cross_retain_auto_bins,
             h.v.option.cross_retain_auto_bins);
    $display("names nonempty %0d %0d different %0d, set \"%s\"", g1.option.name != "",
             g2.option.name != "", g1.option.name != g2.option.name, k.option.name);
    a = 0;
    b = 0;
    g1.sample();
    h.sample();
    void'(g1.x.get_inst_coverage(c[0], t[0]));
    void'(g1.w.get_inst_coverage(c[1], t[1]));
    void'(h.y.get_inst_coverage(c[2], t[2]));
    void'(h.v.get_inst_coverage(c[3], t[3]));
    $display("(0,0): x %0d/%0d w %0d/%0d y %0d/%0d v %0d/%0d", c[0], t[0], c[1], t[1],
             c[2], t[2], c[3], t[3]);
  end
endmodule

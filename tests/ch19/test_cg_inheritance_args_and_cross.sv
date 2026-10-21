/*
:name: test_cg_inheritance_args_and_cross
:description: A derived embedded covergroup takes the constructor and sample arguments and the options of its base, a base cross over a replaced coverpoint still counts until a cross of the same name replaces it, and a derived covergroup can be extended again (IEEE 1800-2023 Section 19.4.1)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.4.1 19.4 19.7 19.11 19.11.1 19.11.2 19.8.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_inheritance_args_and_cross.expected
*/
// IEEE 1800-2023 §19.4.1: a derived covergroup has the argument list of its
// base, here lo, and its coverage event, here the sample method with the
// arguments v and f (19.8.1), and the options of the base that it does not
// override, here auto_bin_max 2, the default for the automatic bins of its
// coverpoints (19.7). A coverpoint of the same name replaces the base one in
// the computation, but a base cross over the replaced coverpoint still counts,
// until a derived covergroup declares a cross of the same name. A derived
// covergroup can be the base of another one in a further derived class. In
// mid, cv has the one bin low, ca two automatic bins and the base cross vf the
// 4 x 2 products of the base cv and cf; in leaf, the new vf crosses the cv of
// mid with cf, 1 x 2 products. Each object samples (1, 0) and (3, 1); the
// coverage of each item follows 19.11.1 and 19.11.2, and that of the
// covergroup is their average.

module test_cg_inheritance_args_and_cross;
  class base;
    covergroup cg (int lo) with function sample (bit [1:0] v, bit f);
      option.auto_bin_max = 2;
      cv: coverpoint v { bins b[] = {[lo:3]}; }
      cf: coverpoint f { bins b[] = {0, 1}; }
      vf: cross cv, cf;
    endgroup
    function new();
      cg = new(0);
    endfunction
  endclass

  class mid extends base;
    covergroup extends cg;
      cv: coverpoint v { bins low = {[lo:lo + 2]}; }
      ca: coverpoint v;
    endgroup
    function new();
      super.new();
    endfunction
  endclass

  class leaf extends mid;
    covergroup extends cg;
      vf: cross cv, cf;
    endgroup
    function new();
      super.new();
    endfunction
  endclass

  mid m;
  leaf l;

  initial begin
    m = new;
    l = new;
    m.cg.sample(1, 0);
    m.cg.sample(3, 1);
    l.cg.sample(1, 0);
    l.cg.sample(3, 1);
    $display("mid: cv %.2f, cf %.2f, vf %.2f, ca %.2f, covergroup %.2f",
             m.cg.cv.get_inst_coverage(), m.cg.cf.get_inst_coverage(),
             m.cg.vf.get_inst_coverage(), m.cg.ca.get_inst_coverage(), m.cg.get_inst_coverage());
    $display("leaf: cv %.2f, cf %.2f, vf %.2f, ca %.2f, covergroup %.2f",
             l.cg.cv.get_inst_coverage(), l.cg.cf.get_inst_coverage(),
             l.cg.vf.get_inst_coverage(), l.cg.ca.get_inst_coverage(), l.cg.get_inst_coverage());
  end
endmodule

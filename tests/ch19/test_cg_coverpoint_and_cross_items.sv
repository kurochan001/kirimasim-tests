/*
:name: test_cg_coverpoint_and_cross_items
:description: Coverpoints cover a variable or an expression with explicit state bins, automatic bins or transition bins, and labeled crosses combine two variables, or coverpoints and a variable, into one bin per combination of their bins (IEEE 1800-2023 Section 19.3)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.3 19.6 19.5.2 19.5.3 19.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_coverpoint_and_cross_items.expected
*/
// IEEE 1800-2023 §19.3: a coverpoint covers a variable or an expression, with
// state bins for sets of values or transition bins for value transitions,
// defined by the user or created automatically; a cross covers two or more
// variables or previously declared coverpoints. §19.6: a variable in a cross
// gets an implicit coverpoint, the cross has one bin per combination of the
// bins of its items, and its label names it and its scope.
// get_inst_coverage(c, t) gives the covered bins and the bins of a
// coverpoint or cross (19.8).
//
// pa covers the variable a with the explicit bins lo, hi[2] and hi[3]; pe the
// 2-bit expression a + b with 4 automatic bins (19.5.3); pt the variable c
// with the transition bins rise and fall (19.5.2). vv crosses the variables a
// and b, 4 x 4 bins; pv crosses the coverpoints pa and pe and the variable c,
// 3 x 4 x 2 bins. The samples (a, b, c) are (0, 0, 0), (3, 2, 1) and (2, 1, 0),
// so a + b takes 0, 1 and 3, and c rises and falls.

module test_cg_coverpoint_and_cross_items;
  bit [1:0] a, b;
  bit c;

  covergroup cg;
    pa: coverpoint a { bins lo = {[0:1]}; bins hi[] = {[2:3]}; }
    pe: coverpoint (a + b);
    pt: coverpoint c { bins rise = (0 => 1); bins fall = (1 => 0); }
    vv: cross a, b;
    pv: cross pa, pe, c;
  endgroup

  cg g = new;

  task automatic put(bit [1:0] va, bit [1:0] vb, bit vc);
    a = va;
    b = vb;
    c = vc;
    g.sample();
  endtask

  task automatic show();
    int pac, pat, pec, pet, ptc, ptt, vvc, vvt, pvc, pvt;
    void'(g.pa.get_inst_coverage(pac, pat));
    void'(g.pe.get_inst_coverage(pec, pet));
    void'(g.pt.get_inst_coverage(ptc, ptt));
    void'(g.vv.get_inst_coverage(vvc, vvt));
    void'(g.pv.get_inst_coverage(pvc, pvt));
    $display("pa %0d/%0d, pe %0d/%0d, pt %0d/%0d, vv %0d/%0d, pv %0d/%0d",
             pac, pat, pec, pet, ptc, ptt, vvc, vvt, pvc, pvt);
  endtask

  initial begin
    put(0, 0, 0);
    show();
    put(3, 2, 1);
    show();
    put(2, 1, 0);
    show();
  end
endmodule

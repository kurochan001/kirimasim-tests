/*
:name: test_cg_cross_iff_guards
:description: A false iff guard of a cross makes the cross ignore the sample, while its coverpoints still take it, and a false iff guard of a cross bin makes only that bin ignore it (IEEE 1800-2023 Section 19.6)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.6 19.6.1 19.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_cross_iff_guards.expected
*/
// IEEE 1800-2023 §19.6: when the iff guard of a cross is false at a sampling
// point, the cross coverage is ignored for that sample; when the iff guard at
// the end of a cross bin is false, that cross bin is ignored. xg has the guard
// en; xb has the user bin both1, <1,1> with the guard bon, and keeps the
// automatic bins of the other three products (19.6.1). Each cross has 4 bins.
// (1, 1) with en = 0 and bon = 0 is taken by ca but by neither cross bin;
// (0, 1) with en = 1 is taken by both crosses; (1, 1) with bon = 1 covers
// both1. get_inst_coverage(c, t) gives the covered bins and the bins (19.8).

module test_cg_cross_iff_guards;
  bit a, b, en, bon;

  covergroup cg;
    ca: coverpoint a { bins v[] = {0, 1}; }
    cb: coverpoint b { bins v[] = {0, 1}; }
    xg: cross ca, cb iff (en);
    xb: cross ca, cb {
      bins both1 = binsof(ca) intersect {1} && binsof(cb) intersect {1} iff (bon);
    }
  endgroup

  cg g = new;

  task automatic put(bit va, bit vb, bit e, bit bo);
    int ac, at, gc, gt, bc, bt;
    a = va;
    b = vb;
    en = e;
    bon = bo;
    g.sample();
    void'(g.ca.get_inst_coverage(ac, at));
    void'(g.xg.get_inst_coverage(gc, gt));
    void'(g.xb.get_inst_coverage(bc, bt));
    $display("(%0d,%0d) en=%0d bon=%0d: ca %0d/%0d, xg %0d/%0d, xb %0d/%0d", va, vb, e, bo,
             ac, at, gc, gt, bc, bt);
  endtask

  initial begin
    put(1, 1, 0, 0);
    put(0, 1, 1, 0);
    put(1, 1, 1, 1);
  end
endmodule

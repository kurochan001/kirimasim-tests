/*
:name: test_cg_item_start_stop
:description: stop() and start() suspend and resume the collection of coverage of a covergroup instance, of one of its coverpoints and of one of its crosses (IEEE 1800-2023 Section 19.8)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_item_start_stop.expected
*/
// IEEE 1800-2023 §19.8: the methods void start() and void stop() start and stop
// the collection of coverage information; Table 19-5 provides them on a
// covergroup, a coverpoint and a cross. get_inst_coverage(c, t) gives the
// covered bins and the bins (19.8).
//
// With cp and the cross x stopped, the sample (0, 0, 0) is collected by c1 and
// c2 only. After cp.start() and x.start(), (1, 1, 1) is collected by all
// items. After stop() of the covergroup, (2, 0, 1) is collected by none; after
// its start(), (3, 0, 1) by all again.

module test_cg_item_start_stop;
  bit [1:0] a;
  bit b, c;

  covergroup cg;
    cp: coverpoint a { bins v[] = {[0:3]}; }
    c1: coverpoint b { bins v[] = {0, 1}; }
    c2: coverpoint c { bins v[] = {0, 1}; }
    x: cross c1, c2;
  endgroup

  cg g = new;

  task automatic put(bit [1:0] va, bit vb, bit vc);
    int n[4], t[4];
    a = va;
    b = vb;
    c = vc;
    g.sample();
    void'(g.cp.get_inst_coverage(n[0], t[0]));
    void'(g.c1.get_inst_coverage(n[1], t[1]));
    void'(g.c2.get_inst_coverage(n[2], t[2]));
    void'(g.x.get_inst_coverage(n[3], t[3]));
    $display("(%0d,%0d,%0d): cp %0d/%0d, c1 %0d/%0d, c2 %0d/%0d, x %0d/%0d", va, vb, vc,
             n[0], t[0], n[1], t[1], n[2], t[2], n[3], t[3]);
  endtask

  initial begin
    g.cp.stop();
    g.x.stop();
    put(0, 0, 0);
    g.cp.start();
    g.x.start();
    put(1, 1, 1);
    g.stop();
    put(2, 0, 1);
    g.start();
    put(3, 0, 1);
  end
endmodule

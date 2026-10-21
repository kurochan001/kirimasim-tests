/*
:name: test_cg_cross_illegal_per_instance
:description: Illegal cross bins given by a with clause that uses a covergroup argument exclude different products in each instance, and the coverage of each cross counts only its legal products (IEEE 1800-2023 Section 19.6.3)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.6.3 19.6.1.2 19.11.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_cross_illegal_per_instance.expected
*/
// IEEE 1800-2023 §19.6.3: the cross products that the select expression of
// illegal_bins selects are excluded from coverage. Here it selects the products
// whose values add up to the covergroup argument bad (19.6.1.2), evaluated
// when each instance is constructed. Of the 3 x 2 products, g1 (bad = 1)
// excludes <0,1> and <1,0>, leaving 4, and g2 (bad = 3) excludes <2,1>,
// leaving 5 (19.11.2). The test prints the covered bins and the bins of each
// cross after each group of samples, and samples each instance only with
// values that are legal for it, as an illegal one would be a run-time error.

module test_cg_cross_illegal_per_instance;
  bit [1:0] a;
  bit b;

  covergroup cg (int bad);
    ca: coverpoint a { bins v[] = {[0:2]}; }
    cb: coverpoint b { bins v[] = {0, 1}; }
    X: cross ca, cb {
      illegal_bins ill = X with (ca + cb == bad);
    }
  endgroup

  cg g1 = new(1);
  cg g2 = new(3);

  task automatic put(bit [1:0] va, bit vb, bit to1, bit to2);
    a = va;
    b = vb;
    if (to1) g1.sample();
    if (to2) g2.sample();
  endtask

  task automatic show(string what);
    int c1, t1, c2, t2;
    void'(g1.X.get_inst_coverage(c1, t1));
    void'(g2.X.get_inst_coverage(c2, t2));
    $display("%s: g1 %0d/%0d %.2f, g2 %0d/%0d %.2f", what, c1, t1, g1.X.get_inst_coverage(),
             c2, t2, g2.X.get_inst_coverage());
  endtask

  initial begin
    put(0, 0, 1, 1);
    put(1, 1, 1, 1);
    put(2, 0, 1, 1);
    show("<0,0>, <1,1>, <2,0> to both");
    put(2, 1, 1, 0);
    show("then <2,1> to g1");
    put(0, 1, 0, 1);
    put(1, 0, 0, 1);
    show("then <0,1>, <1,0> to g2");
  end
endmodule

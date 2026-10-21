/*
:name: test_cg_type_coverage_item_weights
:description: Without merge_instances, the type coverage of a covergroup averages its instances by the weight of each instance, while that of a coverpoint averages the coverpoint of each instance by the coverpoint's own weight in that instance (IEEE 1800-2023 Section 19.11.3)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.11.3 19.11 19.7 19.11.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_type_coverage_item_weights.expected
*/
// IEEE 1800-2023 §19.11.3: when merge_instances is 0, the type coverage of a
// covergroup is the average of the coverage of its instances, weighted by the
// option.weight of each instance, and depends on nothing else; the type
// coverage of a coverpoint is the average of that coverpoint in each instance,
// weighted by the option.weight of the coverpoint in that instance (19.7). The
// instance coverage is the average of cp and cq weighted by their weights
// (19.11): g1 (weights 1, cp 1) has cp 25 and cq 50, so 37.5; g2 (weights 3,
// cp 3) has cp 100 and cq 50, so (3 x 100 + 50) / 4 = 87.5; g3 (weight 0, cp
// 1) has 37.5 as g1. The type coverage of cg is (37.5 + 3 x 87.5) / 4, as g3
// has weight 0; that of cp is (25 + 3 x 100 + 25) / 5, as the weight of g3
// does not matter there; that of cq is the plain average of 50.

module test_cg_type_coverage_item_weights;
  bit [1:0] a;
  bit b;

  covergroup cg (int gw, int pw);
    option.weight = gw;
    cp: coverpoint a { option.weight = pw; bins v[] = {[0:3]}; }
    cq: coverpoint b { bins v[] = {0, 1}; }
  endgroup

  cg g1 = new(1, 1);
  cg g2 = new(3, 3);
  cg g3 = new(0, 1);

  initial begin
    b = 0;
    a = 0;
    g1.sample();
    g3.sample();
    for (int i = 0; i < 4; i++) begin
      a = i;
      g2.sample();
    end
    $display("instances: g1 %.2f, g2 %.2f, g3 %.2f", g1.get_inst_coverage(),
             g2.get_inst_coverage(), g3.get_inst_coverage());
    $display("type: cg %.2f, cp %.2f, cq %.2f", cg::get_coverage(), cg::cp::get_coverage(),
             cg::cq::get_coverage());
  end
endmodule

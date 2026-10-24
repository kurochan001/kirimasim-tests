/*
:name: test_cg_option_levels_readback
:description: name, comment and goal options set for a covergroup, comment and goal for a coverpoint and comment, goal, weight and cross_num_print_missing for a cross keep their values, and type options comment, goal and weight set at each level are static members readable before any instance exists; a cross weight weights the cross in the instance coverage and coverpoint type weights weight the merged type coverage (IEEE 1800-2023 Section 19.7)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.7 19.7.1 19.10 19.11 19.11.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_option_levels_readback.expected
*/
// IEEE 1800-2023 §19.7: Table 19-2 allows name only at the covergroup level,
// comment and goal at the covergroup, coverpoint and cross levels, and weight
// and cross_num_print_missing at the cross level. §19.7.1: Table 19-4 allows
// the type options comment, goal and weight at all three levels; type_option
// is a static member (19.10), so it can be read through the covergroup type
// with :: before an instance is made. The values set here are read back.
//
// §19.11: the instance coverage of cg is the average of its items weighted by
// option.weight; with cp and cq at 50% and the cross x of weight 4 at 25% it
// is (50 + 50 + 4 x 25) / 6 = 33.33. §19.7.1, §19.11.3: with merge_instances,
// the type coverage weights each coverpoint by its type_option.weight, 1 by
// default; cg_m, sampled once with a = 0 and b = 1, has cp of type weight 3
// at 50% and cq of the default weight at 100%, so (3 x 50 + 100) / 4 = 62.50.

module test_cg_option_levels_readback;
  bit [1:0] a, b;

  covergroup cg;
    option.name = "first";
    option.comment = "group note";
    option.goal = 90;
    type_option.comment = "type note";
    type_option.goal = 80;
    cp: coverpoint a {
      option.comment = "point note";
      option.goal = 70;
      type_option.comment = "point type note";
      type_option.goal = 60;
      type_option.weight = 3;
      bins v[] = {[0:1]};
    }
    cq: coverpoint b { bins v[] = {[0:1]}; }
    x: cross cp, cq {
      option.comment = "cross note";
      option.goal = 50;
      option.weight = 4;
      option.cross_num_print_missing = 5;
      type_option.comment = "cross type note";
      type_option.goal = 40;
      type_option.weight = 2;
    }
  endgroup

  covergroup cg_m;
    type_option.merge_instances = 1;
    cp: coverpoint a { type_option.weight = 3; bins v[] = {[0:1]}; }
    cq: coverpoint b { bins one = {1}; }
  endgroup

  cg g;
  cg_m gm;

  initial begin
    $display("type, covergroup: \"%s\" goal %0d", cg::type_option.comment,
             cg::type_option.goal);
    $display("type, coverpoint: \"%s\" goal %0d weight %0d", cg::cp::type_option.comment,
             cg::cp::type_option.goal, cg::cp::type_option.weight);
    $display("type, cross: \"%s\" goal %0d weight %0d", cg::x::type_option.comment,
             cg::x::type_option.goal, cg::x::type_option.weight);
    g = new;
    gm = new;
    $display("covergroup: name \"%s\" \"%s\" goal %0d", g.option.name, g.option.comment,
             g.option.goal);
    $display("coverpoint: \"%s\" goal %0d", g.cp.option.comment, g.cp.option.goal);
    $display("cross: \"%s\" goal %0d weight %0d cross_num_print_missing %0d",
             g.x.option.comment, g.x.option.goal, g.x.option.weight,
             g.x.option.cross_num_print_missing);
    a = 0;
    b = 0;
    g.sample();
    a = 0;
    b = 1;
    gm.sample();
    $display("cg instance %.2f, cg_m type %.2f", g.get_inst_coverage(), cg_m::get_coverage());
  end
endmodule

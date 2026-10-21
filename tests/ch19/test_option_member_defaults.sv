/*
:name: test_option_member_defaults
:description: The members of option and type_option of a covergroup, a coverpoint and a cross start with the default values of the standard, and the options set for the covergroup become those of its coverpoints and crosses, except weight, goal and comment, and of the type options only real_interval (IEEE 1800-2023 Section 19.10)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.10 19.7 19.7.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_option_member_defaults.expected
*/
// IEEE 1800-2023 §19.10: option and type_option are structures with members
// that differ for a covergroup, a coverpoint and a cross. Their defaults are
// given in Tables 19-1 and 19-3 (19.7, 19.7.1): weight 1, goal 100, comment
// "", at_least 1, auto_bin_max 64, cross_num_print_missing 0,
// cross_retain_auto_bins 1, the other bits 0 and real_interval 1.0. The test
// prints every member except name, whose default is left to the tool. §19.7:
// an option set for the covergroup, other than weight, goal, comment and
// per_instance, is the default of that option of its coverpoints and crosses;
// §19.7.1: of the type options set for the covergroup, only real_interval is
// the default of its coverpoints. cg_set sets options for the covergroup only,
// and the test prints what its coverpoint and cross then hold.

module test_option_member_defaults;
  bit [1:0] a, b;

  covergroup cg_plain;
    cp: coverpoint a;
    cq: coverpoint b;
    X: cross cp, cq;
  endgroup

  covergroup cg_set;
    option.weight = 2;
    option.goal = 90;
    option.comment = "set";
    option.at_least = 3;
    option.auto_bin_max = 16;
    option.cross_num_print_missing = 4;
    option.cross_retain_auto_bins = 0;
    option.detect_overlap = 1;
    type_option.weight = 5;
    type_option.goal = 80;
    type_option.comment = "type";
    type_option.real_interval = 0.25;
    cp: coverpoint a;
    cq: coverpoint b;
    X: cross cp, cq;
  endgroup

  cg_plain gp = new();
  cg_set gs = new();

  initial begin
    $display("covergroup option: weight %0d, goal %0d, comment \"%s\", at_least %0d",
             gp.option.weight, gp.option.goal, gp.option.comment, gp.option.at_least);
    $display("  auto_bin_max %0d, cross_num_print_missing %0d, cross_retain_auto_bins %0d",
             gp.option.auto_bin_max, gp.option.cross_num_print_missing,
             gp.option.cross_retain_auto_bins);
    $display("  detect_overlap %0d, per_instance %0d, get_inst_coverage %0d",
             gp.option.detect_overlap, gp.option.per_instance, gp.option.get_inst_coverage);
    $display("coverpoint option: weight %0d, goal %0d, comment \"%s\", at_least %0d",
             gp.cp.option.weight, gp.cp.option.goal, gp.cp.option.comment, gp.cp.option.at_least);
    $display("  auto_bin_max %0d, detect_overlap %0d",
             gp.cp.option.auto_bin_max, gp.cp.option.detect_overlap);
    $display("cross option: weight %0d, goal %0d, comment \"%s\", at_least %0d",
             gp.X.option.weight, gp.X.option.goal, gp.X.option.comment, gp.X.option.at_least);
    $display("  cross_num_print_missing %0d, cross_retain_auto_bins %0d",
             gp.X.option.cross_num_print_missing, gp.X.option.cross_retain_auto_bins);
    $display("covergroup type_option: weight %0d, goal %0d, comment \"%s\"",
             cg_plain::type_option.weight, cg_plain::type_option.goal,
             cg_plain::type_option.comment);
    $display("  strobe %0d, merge_instances %0d, distribute_first %0d, real_interval %.2f",
             cg_plain::type_option.strobe, cg_plain::type_option.merge_instances,
             cg_plain::type_option.distribute_first, cg_plain::type_option.real_interval);
    $display("coverpoint type_option: weight %0d, goal %0d, comment \"%s\", real_interval %.2f",
             cg_plain::cp::type_option.weight, cg_plain::cp::type_option.goal,
             cg_plain::cp::type_option.comment, cg_plain::cp::type_option.real_interval);
    $display("cross type_option: weight %0d, goal %0d, comment \"%s\"",
             cg_plain::X::type_option.weight, cg_plain::X::type_option.goal,
             cg_plain::X::type_option.comment);
    $display("cg_set coverpoint option: weight %0d, goal %0d, comment \"%s\", at_least %0d",
             gs.cp.option.weight, gs.cp.option.goal, gs.cp.option.comment, gs.cp.option.at_least);
    $display("  auto_bin_max %0d, detect_overlap %0d",
             gs.cp.option.auto_bin_max, gs.cp.option.detect_overlap);
    $display("cg_set cross option: weight %0d, goal %0d, comment \"%s\", at_least %0d",
             gs.X.option.weight, gs.X.option.goal, gs.X.option.comment, gs.X.option.at_least);
    $display("  cross_num_print_missing %0d, cross_retain_auto_bins %0d",
             gs.X.option.cross_num_print_missing, gs.X.option.cross_retain_auto_bins);
    $display("cg_set coverpoint type_option: weight %0d, goal %0d, comment \"%s\"",
             cg_set::cp::type_option.weight, cg_set::cp::type_option.goal,
             cg_set::cp::type_option.comment);
    $display("  real_interval %.2f", cg_set::cp::type_option.real_interval);
    $display("cg_set cross type_option: weight %0d, goal %0d, comment \"%s\"",
             cg_set::X::type_option.weight, cg_set::X::type_option.goal,
             cg_set::X::type_option.comment);
  end
endmodule

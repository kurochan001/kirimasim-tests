/*
:name: test_option_struct_member_types
:description: The implicit option and type_option structures of a covergroup, a coverpoint and a cross have the members that the standard lists for each, with the types string, int, bit and real it gives (IEEE 1800-2023 Section 19.10)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.10 20.6.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_option_struct_member_types.expected
*/
// IEEE 1800-2023 §19.10: option and type_option of a covergroup, a coverpoint
// and a cross are implicitly declared structures. The option of a covergroup
// has the string members name and comment, the int members weight, goal,
// at_least, auto_bin_max and cross_num_print_missing, and the bit members
// cross_retain_auto_bins, detect_overlap, per_instance and get_inst_coverage;
// that of a coverpoint has weight, goal, at_least, auto_bin_max (int),
// comment (string) and detect_overlap (bit); that of a cross weight, goal,
// at_least, cross_num_print_missing (int), comment (string) and
// cross_retain_auto_bins (bit). The type_option of a covergroup has weight,
// goal (int), comment (string), strobe, merge_instances, distribute_first
// (bit) and real_interval (real); that of a coverpoint weight, goal, comment
// and real_interval; that of a cross weight, goal and comment. The test
// prints $typename of each member (20.6.1), which for these built-in types is
// the type keyword.

module test_option_struct_member_types;
  bit [1:0] a, b;

  covergroup cg;
    cp: coverpoint a;
    cq: coverpoint b;
    X: cross cp, cq;
  endgroup

  cg g = new;

  initial begin
    $display("covergroup option: %s %s %s %s %s %s %s", $typename(g.option.name),
             $typename(g.option.weight), $typename(g.option.goal),
             $typename(g.option.comment), $typename(g.option.at_least),
             $typename(g.option.auto_bin_max), $typename(g.option.cross_num_print_missing));
    $display("  %s %s %s %s", $typename(g.option.cross_retain_auto_bins),
             $typename(g.option.detect_overlap), $typename(g.option.per_instance),
             $typename(g.option.get_inst_coverage));
    $display("coverpoint option: %s %s %s %s %s %s", $typename(g.cp.option.weight),
             $typename(g.cp.option.goal), $typename(g.cp.option.comment),
             $typename(g.cp.option.at_least), $typename(g.cp.option.auto_bin_max),
             $typename(g.cp.option.detect_overlap));
    $display("cross option: %s %s %s %s %s %s", $typename(g.X.option.weight),
             $typename(g.X.option.goal), $typename(g.X.option.comment),
             $typename(g.X.option.at_least), $typename(g.X.option.cross_num_print_missing),
             $typename(g.X.option.cross_retain_auto_bins));
    $display("covergroup type_option: %s %s %s %s %s %s %s", $typename(cg::type_option.weight),
             $typename(cg::type_option.goal), $typename(cg::type_option.comment),
             $typename(cg::type_option.strobe), $typename(cg::type_option.merge_instances),
             $typename(cg::type_option.distribute_first),
             $typename(cg::type_option.real_interval));
    $display("coverpoint type_option: %s %s %s %s", $typename(cg::cp::type_option.weight),
             $typename(cg::cp::type_option.goal), $typename(cg::cp::type_option.comment),
             $typename(cg::cp::type_option.real_interval));
    $display("cross type_option: %s %s %s", $typename(cg::X::type_option.weight),
             $typename(cg::X::type_option.goal), $typename(cg::X::type_option.comment));
  end
endmodule

/*
:name: test_option_struct_members
:description: The option and type_option members of a covergroup, a coverpoint and a cross are structures with the members and types that the standard lists for each, which can be read and set (IEEE 1800-2023 Section 19.10)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.10 19.7 19.7.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_option_struct_members.expected
*/
// IEEE 1800-2023 §19.10: option and type_option of a covergroup, of a
// coverpoint and of a cross are implicitly declared structures, each with its
// own set of members: for example cross_retain_auto_bins and per_instance in
// the option of a covergroup, detect_overlap in the option of a coverpoint,
// cross_num_print_missing in the option of a cross, and real_interval, a
// real, in the type_option of a covergroup. $bits shows the integral types:
// 1 for a bit and 32 for an int. It is not used on real_interval, because a
// real is not a bit-stream type (6.24.3, 20.6.2); the value 0.5, which no
// integral member can hold, shows the real. per_instance, detect_overlap and
// real_interval are set in the covergroup, as 19.7 and 19.7.1 require; the
// others are set procedurally after the instance is made (19.7).

module test_option_struct_members;
  bit [1:0] a, b;

  covergroup cg;
    option.per_instance = 1;
    type_option.real_interval = 0.5;
    cp_a: coverpoint a {
      option.detect_overlap = 1;
    }
    cp_b: coverpoint b;
    ab: cross cp_a, cp_b;
  endgroup

  cg g;

  initial begin
    g = new();
    g.option.comment = "group";
    g.cp_a.option.weight = 3;
    g.ab.option.cross_num_print_missing = 2;
    $display("group: %s per_instance=%0d bits=%0d,%0d", g.option.comment, g.option.per_instance,
             $bits(g.option.cross_retain_auto_bins), $bits(g.option.auto_bin_max));
    $display("coverpoint: weight=%0d detect_overlap=%0d bits=%0d", g.cp_a.option.weight,
             g.cp_a.option.detect_overlap, $bits(g.cp_a.option.detect_overlap));
    $display("cross: cross_num_print_missing=%0d", g.ab.option.cross_num_print_missing);
    $display("type_option: real_interval=%.1f, strobe bits=%0d",
             cg::type_option.real_interval, $bits(cg::type_option.strobe));
  end
endmodule

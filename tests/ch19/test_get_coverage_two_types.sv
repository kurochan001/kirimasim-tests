/*
:name: test_get_coverage_two_types
:description: $get_coverage gives the overall coverage of the covergroup types, which equals their type coverage when all types have the same coverage, the type coverage of a type with two instances being their average (IEEE 1800-2023 Section 19.9)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.9 19.11 19.11.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_get_coverage_two_types.expected
*/
// IEEE 1800-2023 §19.9: $get_coverage returns the overall coverage of all
// covergroup types, a real from 0 to 100. §19.11.3: with merge_instances 0,
// the type coverage of a covergroup is the average of its instances weighted
// by their option.weight, all 1 here, so cg_a, whose instances reach 100 and
// 50 percent (19.11), has 75. 19.9 does not say how the types are combined,
// whether by their type_option.weight, equally or by instance, so the test
// does not check that weighting: at each print, cg_a, cg_b and each of their
// instances average to the same value, which is then the overall coverage
// under any of these ways of combining them.

module test_get_coverage_two_types;
  bit [1:0] a;

  covergroup cg_a;
    cp: coverpoint a { bins v[] = {[0:3]}; }
  endgroup

  covergroup cg_b;
    cp: coverpoint a { bins v[] = {[0:3]}; }
  endgroup

  cg_a ga1 = new();
  cg_a ga2 = new();
  cg_b gb = new();

  task automatic show();
    $display("cg_a %.2f (instances %.2f, %.2f), cg_b %.2f, $get_coverage %.2f",
             cg_a::get_coverage(), ga1.get_inst_coverage(), ga2.get_inst_coverage(),
             cg_b::get_coverage(), $get_coverage());
  endtask

  initial begin
    $display("before sampling: $get_coverage %.2f", $get_coverage());
    for (int i = 0; i < 2; i++) begin
      a = i;
      ga1.sample();
      ga2.sample();
      gb.sample();
    end
    show();
    a = 2;
    ga1.sample();
    gb.sample();
    a = 3;
    ga1.sample();
    show();
  end
endmodule

/*
:name: test_get_coverage_no_contributing_groups
:description: $get_coverage returns 100.0 when the design has no covergroup instance and when every covergroup has a weight of 0 (IEEE 1800-2023 Section 19.11)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.11 19.9 19.7.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_get_coverage_no_contributing_groups.expected
*/
// IEEE 1800-2023 §19.11: $get_coverage (19.9) returns 100.0 when called on a
// design with no covergroup instances, or in which all covergroups have a
// weight of 0. Before new runs, the design has no instance of cg_w0. Then the
// only covergroup is cg_w0, whose type_option.weight (19.7.1) is 0, so the
// overall coverage is still 100.0, while its own type coverage, one of its 2
// automatic bins, is 50.0.

module test_get_coverage_no_contributing_groups;
  bit a;

  covergroup cg_w0;
    type_option.weight = 0;
    cp: coverpoint a;
  endgroup

  cg_w0 g;

  initial begin
    $display("no instance: %.2f", $get_coverage());
    g = new;
    a = 1;
    g.sample();
    $display("all weights 0: %.2f, cg_w0 type %.2f", $get_coverage(), cg_w0::get_coverage());
  end
endmodule

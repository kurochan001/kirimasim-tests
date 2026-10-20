/*
:name: test_get_coverage_weights
:description: $get_coverage returns the overall coverage of all covergroup types weighted by their type_option.weight, so a covergroup type of weight 0 does not count, while its own get_coverage is unchanged (IEEE 1800-2023 Section 19.9)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.9 19.7.1 19.11 19.11.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_get_coverage_weights.expected
*/
// IEEE 1800-2023 §19.9: $get_coverage returns, as a real from 0 to 100, the
// overall coverage of all covergroup types. §19.7.1: the type_option.weight of
// a covergroup is its weight in that overall coverage. cg_a, of weight 0, has
// one of its four bins hit, 25 percent (19.11, 19.11.1); cg_b, of the default
// weight 1, one of two, 50 percent. The overall coverage is then that of
// cg_b alone.

module test_get_coverage_weights;
  bit [1:0] a;
  bit b;

  covergroup cg_a;
    type_option.weight = 0;
    coverpoint a { bins v[] = {[0:3]}; }
  endgroup

  covergroup cg_b;
    coverpoint b { bins v[] = {0, 1}; }
  endgroup

  cg_a ga = new();
  cg_b gb = new();

  initial begin
    a = 2;
    ga.sample();
    b = 1;
    gb.sample();
    $display("cg_a %0.2f, cg_b %0.2f, $get_coverage %0.2f", cg_a::get_coverage(),
             cg_b::get_coverage(), $get_coverage());
  end
endmodule

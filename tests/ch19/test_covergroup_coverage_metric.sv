/*
:name: test_covergroup_coverage_metric
:description: Functional coverage is the percentage of the user-defined verification objectives that were met, so a coverpoint with four explicit bins of which three were sampled gives a covergroup coverage of 75 (IEEE 1800-2023 Section 19.2)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_covergroup_coverage_metric.expected
*/
// IEEE 1800-2023 §19.2: coverage is the percentage of the verification
// objectives met, and functional coverage counts the features of the test
// plan that a user-defined coverage model has exercised. The coverpoint has
// one bin for each of the values 0, 1, 2 and 3, so there are four bins. The
// three samples with x = 0, 1 and 2 cover three of them, so the coverage of
// the covergroup instance is 3/4 of 100, that is 75.

module test_covergroup_coverage_metric;
  int x = 0;

  covergroup cg;
    a: coverpoint x {
      bins b0 = {0};
      bins b1 = {1};
      bins b2 = {2};
      bins b3 = {3};
    }
  endgroup

  cg g = new;

  initial begin
    x = 0;
    g.sample();
    x = 1;
    g.sample();
    x = 2;
    g.sample();
    $display("covergroup=%0.0f", g.get_inst_coverage());
  end
endmodule

/*
:name: test_cg_type_and_instance_coverage
:description: get_coverage returns the type coverage, as the weighted average of the instances when merge_instances is false and as the union of their bins when it is true, and the counts of its two arguments agree with that percentage (IEEE 1800-2023 Sections 19.11 and 19.11.3)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.11 19.11.3 19.7.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_type_and_instance_coverage.expected
*/
// IEEE 1800-2023 §19.11: get_coverage is the coverage of the covergroup type,
// the contribution of all its instances, and it is a static method of the
// type or of an instance. §19.11.3: with type_option.merge_instances false the
// type coverage is the weighted average of the instances, and with it true it
// is the union of their bins, compared by name. §19.11.3: the two arguments of
// get_coverage are consistent with that weighted sum. Two instances of each of
// two covergroups sample a = 0 in the first and a = 1 and a = 2 in the second,
// out of the four bins b[0] to b[3]: the first instance covers 25 and the
// second 50, so the weighted average is 37.50 and the union of the three
// different bins is 75.00.

module test_cg_type_and_instance_coverage;
  bit [1:0] a;

  covergroup cgavg;
    cp: coverpoint a {
      bins b[] = {[0:3]};
    }
  endgroup

  covergroup cgmerge;
    type_option.merge_instances = 1;
    option.get_inst_coverage = 1;
    cp: coverpoint a {
      bins b[] = {[0:3]};
    }
  endgroup

  cgavg v1 = new;
  cgavg v2 = new;
  cgmerge m1 = new;
  cgmerge m2 = new;

  initial begin
    int c, t;
    real cov;
    bit consistent;
    a = 0;
    v1.sample();
    m1.sample();
    a = 1;
    v2.sample();
    m2.sample();
    a = 2;
    v2.sample();
    m2.sample();
    cov = cgavg::get_coverage();
    void'(cgavg::get_coverage(c, t));
    consistent = t > 0 && c * 100.0 / t - cov < 0.0001 && cov - c * 100.0 / t < 0.0001;
    $display("average: type %0.2f, counts agree: %0d", cov, consistent);
    $display("instance access: %0.2f", v1.get_coverage());
    $display("merge: type %0.2f, instances %0.2f %0.2f",
             cgmerge::get_coverage(), m1.get_inst_coverage(),
             m2.get_inst_coverage());
  end
endmodule

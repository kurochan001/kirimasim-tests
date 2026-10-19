/*
:name: test_cg_type_coverage_merge
:description: type coverage is the average of the instance coverages weighted by option.weight when type_option.merge_instances is 0, and the coverage of the union of the bins of all instances, compared by name, when it is 1; then get_inst_coverage returns the type coverage unless option.get_inst_coverage is set (IEEE 1800-2023 Section 19.11.3)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.11.3 19.7 19.7.1 19.8 19.5.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_type_coverage_merge.expected
*/
// IEEE 1800-2023 §19.11.3: with type_option.merge_instances 0 the type
// coverage is sum(Wi * Ii) / sum(Wi) over the instances, with Wi their
// option.weight; with 1 it is computed on the union of the bins of all
// instances, where bins with the same name, such as b[2] (§19.5.1), are one
// bin. §19.7: option.get_inst_coverage applies only with merge_instances; when
// it is 0, get_inst_coverage returns the same as get_coverage. Each covergroup
// type has two instances, with bins b[0] to b[3] and b[2] to b[5]; the first
// samples 0, 1 and 2 (3 of 4 bins), the second 2 and 5 (2 of 4). The union
// has 6 bins, of which 4 are covered.

module test_cg_type_coverage_merge;
  bit [2:0] a;

  covergroup cg_avg(int l, int h, int w);
    option.weight = w;
    coverpoint a { bins b[] = {[l:h]}; }
  endgroup

  covergroup cg_merge(int l, int h);
    type_option.merge_instances = 1;
    coverpoint a { bins b[] = {[l:h]}; }
  endgroup

  covergroup cg_merge_inst(int l, int h);
    type_option.merge_instances = 1;
    option.get_inst_coverage = 1;
    coverpoint a { bins b[] = {[l:h]}; }
  endgroup

  cg_avg avg1, avg2;
  cg_merge m1, m2;
  cg_merge_inst mi1, mi2;

  task automatic put(int which, bit [2:0] v);
    a = v;
    if (which == 1) begin avg1.sample(); m1.sample(); mi1.sample(); end
    else begin avg2.sample(); m2.sample(); mi2.sample(); end
  endtask

  initial begin
    int c, t;
    avg1 = new(0, 3, 1);
    avg2 = new(2, 5, 3);
    m1 = new(0, 3);
    m2 = new(2, 5);
    mi1 = new(0, 3);
    mi2 = new(2, 5);
    put(1, 0); put(1, 1); put(1, 2);
    put(2, 2); put(2, 5);
    $display("weighted average: type %.2f, instances %.2f %.2f", cg_avg::get_coverage(),
             avg1.get_inst_coverage(), avg2.get_inst_coverage());
    void'(cg_merge::get_coverage(c, t));
    $display("merged: type %.2f (%0d/%0d), instances %.2f %.2f", cg_merge::get_coverage(), c, t,
             m1.get_inst_coverage(), m2.get_inst_coverage());
    $display("merged with get_inst_coverage: type %.2f, instances %.2f %.2f",
             cg_merge_inst::get_coverage(), mi1.get_inst_coverage(), mi2.get_inst_coverage());
  end
endmodule

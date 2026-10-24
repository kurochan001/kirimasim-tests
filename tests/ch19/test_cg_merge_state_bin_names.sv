/*
:name: test_cg_merge_state_bin_names
:description: With merge_instances, the bins of all instances are joined by name: a single bin is the same bin in every instance, a bin of an open array named name[value] is shared by the instances with that value and a fixed array bin name[index] by those with that index, and the counts of a shared bin add up, covering it once the sum reaches the largest at_least of the instances (IEEE 1800-2023 Section 19.11.3)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.11.3 19.11.1 19.5.1 19.7.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_merge_state_bin_names.expected
*/
// IEEE 1800-2023 §19.11.3: when type_option.merge_instances is set (19.7.1),
// the type coverage is computed on the union of the bins of all instances,
// where bins of the same name are the same bin and their counts add up. A bin
// declared as name has that name in all instances; the bins of name[] are
// named name[value] and those of name[N] name[0] to name[N-1] (19.5.1), so
// instances share the open array bins of equal values and the fixed array bins
// of equal indices. §19.11.1: a bin of the union is covered when its count
// reaches the largest at_least of the instances.
//
// i1 = new(0, 3) and i2 = new(2, 5): sc has the bin one in both, so the union
// has 1 bin; op has v[0] to v[3] and v[2] to v[5], 6 bins; fx has f[0] = {0, 1}
// and f[1] = {2, 3} in i1 and f[0] = {2, 3} and f[1] = {4, 5} in i2, 2 bins.
// Only i1 samples, the value 0, which covers one, v[0] and f[0]. j1 (at_least
// 1) and j2 (at_least 3) share v[0] and v[1]: two samples of 0 by j1 give v[0]
// a count of 2, short of 3, and one more by j2 makes it 3.

module test_cg_merge_state_bin_names;
  bit [2:0] a;

  covergroup cg_names (int lo, int hi);
    type_option.merge_instances = 1;
    sc: coverpoint a { bins one = {[lo:hi]}; }
    op: coverpoint a { bins v[] = {[lo:hi]}; }
    fx: coverpoint a { bins f[2] = {[lo:hi]}; }
  endgroup

  covergroup cg_count (int al);
    type_option.merge_instances = 1;
    option.at_least = al;
    cp: coverpoint a { bins v[] = {[0:1]}; }
  endgroup

  cg_names i1 = new(0, 3);
  cg_names i2 = new(2, 5);
  cg_count j1 = new(1);
  cg_count j2 = new(3);

  initial begin
    a = 0;
    i1.sample();
    $display("names: sc %.2f, op %.2f, fx %.2f", cg_names::sc::get_coverage(),
             cg_names::op::get_coverage(), cg_names::fx::get_coverage());
    j1.sample();
    j1.sample();
    $display("counts, j1 samples 0 twice: %.2f", cg_count::get_coverage());
    j2.sample();
    $display("counts, then j2 samples 0: %.2f", cg_count::get_coverage());
  end
endmodule

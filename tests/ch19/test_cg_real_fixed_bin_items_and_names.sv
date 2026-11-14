/*
:name: test_cg_real_fixed_bin_items_and_names
:description: For a fixed number N of real bins, each interval of a range and each single value is an item, repeated items are kept, each bin gets floor(items / N) items but at least one in the order listed and the last bin also the rest, bins left without items are not counted, and the bins are numbered from the first, so with merge_instances the bins of the same index are one type bin (IEEE 1800-2023 Section 19.5.1)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5.1 19.11.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_real_fixed_bin_items_and_names.expected
*/
// IEEE 1800-2023 §19.5.1: for bins binname[N] of a real coverpoint, the items
// to share out are the intervals of the ranges and the single values; a range
// wider than the interval size (1.0 by default) is cut into intervals, the
// last of which includes its high end. Each bin gets B = floor(items / N)
// items, at least 1, in the order listed, and the last bin also takes the
// rest; repeated items are kept, so a value can be in two bins; with more
// bins than items the last bins are empty, and a bin with no value is not
// counted (19.11.1). The bins are named binname[0] to binname[N-1].
// §19.11.3: with type_option.merge_instances, bins of the same name in
// different instances are one type bin; for binname[N] these are the bins of
// the same index. get_inst_coverage(c, t) gives the covered bins and the bins
// of one instance (19.8).
//
// The list {[1.0:3.0], 2.5, [4.0:5.0], 6.0, 6.0} has 6 items: [1.0:2.0),
// [2.0:3.0], 2.5, [4.0:5.0], 6.0 and 6.0. With N = 4, B is 1: f[0] to f[2]
// get the first three items and f[3] the last three. With N = 8, B is 1, f[4]
// and f[5] both hold 6.0 and f[6] and f[7] are empty, so 6 bins count. With
// N = 2, B is 3. m4 and m2 are instances of the same bins with N = 4 and 2
// and merge_instances set, so their type coverpoint has the 4 bins f[0] to
// f[3]: f[0] and f[1] of m2, which hold the first and the last three items,
// are the same type bins as f[0] and f[1] of m4. The origin of the numbers
// is seen only in reports; the union shows that the k-th bin of each
// instance has the same name.
// Icarus Verilog 13.0 does not compile covergroups. Neither the counts of
// get_inst_coverage on a coverpoint nor get_coverage of a coverpoint through
// the covergroup type is supported by the 5.054 release of Verilator.

module test_cg_real_fixed_bin_items_and_names;
  real r;

  covergroup cg_fixed (int n);
    fx: coverpoint r { bins f[n] = {[1.0:3.0], 2.5, [4.0:5.0], 6.0, 6.0}; }
  endgroup

  covergroup cg_named (int n);
    type_option.merge_instances = 1;
    fx: coverpoint r { bins f[n] = {[1.0:3.0], 2.5, [4.0:5.0], 6.0, 6.0}; }
  endgroup

  cg_fixed x4 = new(4);
  cg_fixed x8 = new(8);
  cg_fixed x2 = new(2);
  cg_named m4 = new(4);
  cg_named m2 = new(2);

  task automatic show(string who, cg_fixed g, real v);
    int c, t;
    r = v;
    g.sample();
    void'(g.fx.get_inst_coverage(c, t));
    $display("%s samples %.2f: %0d/%0d", who, v, c, t);
  endtask

  initial begin
    show("x4", x4, 6.0);
    show("x4", x4, 2.5);
    show("x4", x4, 1.5);
    show("x8", x8, 6.0);
    show("x8", x8, 4.5);
    show("x8", x8, 2.0);
    show("x2", x2, 2.0);
    show("x2", x2, 6.0);
    r = 4.5; m2.sample();
    $display("m2 samples 4.50: type %.2f", cg_named::fx::get_coverage());
    r = 1.5; m4.sample();
    $display("m4 samples 1.50: type %.2f", cg_named::fx::get_coverage());
    r = 6.0; m4.sample();
    $display("m4 samples 6.00: type %.2f", cg_named::fx::get_coverage());
    r = 2.5; m4.sample();
    $display("m4 samples 2.50: type %.2f", cg_named::fx::get_coverage());
  end
endmodule

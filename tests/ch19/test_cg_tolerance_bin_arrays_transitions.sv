/*
:name: test_cg_tolerance_bin_arrays_transitions
:description: For an integral coverpoint, a tolerance range [A +/- B] or [A +%- B] is a set of values like [low:high]: an open bin array makes a bin per value, a fixed array splits the values in order, ignore_bins removes values, transition bins expand it, and binsof ... intersect selects the bins it meets (IEEE 1800-2023 Section 19.5.1)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5.1 19.5.2 19.5.5 19.6.1 19.6.2 19.11.1 19.11.2 11.4.13
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_tolerance_bin_arrays_transitions.expected
*/
// IEEE 1800-2023 §19.5.1, §19.5.2 and §19.6.1: a covergroup value range may be
// a tolerance range of §11.4.13, so [10 +/- 2] is the values 8 to 12 and
// [20 +%- 10] the values 18 to 22. For an integral coverpoint:
// - bins a[] = {[10 +/- 2]} is one bin per value, a[8] to a[12];
// - bins f[2] = {[20 +%- 10]} gets 5 values; each bin takes 5/2 = 2 values in
//   order and the last bin also the rest, so f[0] is 18, 19 and f[1] is 20 to
//   22 (§19.5.1);
// - bins g[] = {[30 +/- 2]} makes g[28] to g[32]; ignore_bins {[30 +/- 1]}
//   removes 29 to 31, which empties three bins, and empty bins do not count
//   (§19.5.5, §19.11.1), so g has 2 bins;
// - bins t = ([5 +/- 1] => [40 +/- 1]) covers a transition from any of 4 to 6
//   to any of 39 to 41, and bins u[] = (5 => [40 +/- 1]) makes the three
//   transition bins 5=>39, 5=>40 and 5=>41 (§19.5.2);
// - the cross of arr and p ignores the products whose arr bin meets
//   [11 +/- 1], that is a[10], a[11] and a[12], so 2 x 2 = 4 products remain
//   (§19.6.1, §19.11.2).
// The samples of (v, w) are (9,0) (8,7) (12,0) (13,0) (18,0) (20,0) (30,0)
// (32,0) (5,0) (40,0) (6,0) (41,0). arr covers a[8], a[9] and a[12]: 3/5. fix
// covers f[0] with 18 and f[1] with 20: 2/2 (with 3 values in f[0], 20 would
// fall into f[0]). ign covers g[32]; 30 is ignored: 1/2. tr sees 5 => 40,
// which covers t and u[5=>40]: 2/4. p covers lo and hi: 2/2. The cross covers
// <a[9],lo> and <a[8],hi>; <a[12],lo> is ignored: 2/4.
// get_inst_coverage(c, t) gives the covered bins and the bins (19.8).
// Icarus Verilog 13.0 has no covergroups. The 5.052 release of Verilator does
// not support the tolerance ranges, the fixed bin array or the coverage
// methods of a coverpoint or cross.

module test_cg_tolerance_bin_arrays_transitions;
  bit [7:0] v;
  bit [3:0] w;

  covergroup cg;
    arr: coverpoint v { bins a[] = {[10 +/- 2]}; }
    fix: coverpoint v { bins f[2] = {[20 +%- 10]}; }
    ign: coverpoint v { bins g[] = {[30 +/- 2]}; ignore_bins i = {[30 +/- 1]}; }
    tr: coverpoint v { bins t = ([5 +/- 1] => [40 +/- 1]); bins u[] = (5 => [40 +/- 1]); }
    p: coverpoint w { bins lo = {[0:4]}; bins hi = {[5:9]}; }
    ap: cross arr, p { ignore_bins near11 = binsof(arr) intersect {[11 +/- 1]}; }
  endgroup

  cg g = new;
  int vs[12] = '{9, 8, 12, 13, 18, 20, 30, 32, 5, 40, 6, 41};
  int c[6], t[6];

  initial begin
    foreach (vs[i]) begin
      v = 8'(vs[i]);
      w = (i == 1) ? 4'd7 : 4'd0;
      g.sample();
    end
    void'(g.arr.get_inst_coverage(c[0], t[0]));
    void'(g.fix.get_inst_coverage(c[1], t[1]));
    void'(g.ign.get_inst_coverage(c[2], t[2]));
    void'(g.tr.get_inst_coverage(c[3], t[3]));
    void'(g.p.get_inst_coverage(c[4], t[4]));
    void'(g.ap.get_inst_coverage(c[5], t[5]));
    $display("arr %0d/%0d, fix %0d/%0d, ign %0d/%0d", c[0], t[0], c[1], t[1], c[2], t[2]);
    $display("tr %0d/%0d, p %0d/%0d, cross %0d/%0d", c[3], t[3], c[4], t[4], c[5], t[5]);
  end
endmodule

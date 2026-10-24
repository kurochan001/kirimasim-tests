/*
:name: test_cg_real_bin_intervals
:description: For a real coverpoint, bins without brackets make one bin of the whole list, [] one bin per value and per interval of each range, and [N] N bins sharing the intervals and values out; a range wider than type_option.real_interval, 1.0 by default, is split into intervals from its low end, each including its low end and excluding its high end except the last (IEEE 1800-2023 Section 19.5.1)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5.1 19.7.1 19.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_real_bin_intervals.expected
*/
// IEEE 1800-2023 §19.5.1: a range of integral values is the set of the integers
// in it, while a range of real values holds every real between its bounds,
// both included. For a real coverpoint, bins name = {...} is one bin for the
// whole list, name[] one bin for each single value and for each interval of
// each range, and name[N] N bins that share the intervals and values out. A
// range wider than type_option.real_interval (19.7.1, default 1.0) is
// divided into intervals of that size, starting at the low end of the range,
// the last one possibly shorter; each interval includes its low value and
// excludes its high value, except the last, which includes both. A range no
// wider than the interval gives one bin. get_inst_coverage(c, t) gives the
// covered bins and the bins (19.8).
//
// arr[] of [1.0:3.5] is [1.0:2.0), [2.0:3.0) and [3.0:3.5]. off[] of
// [0.25:2.75] is [0.25:1.25), [1.25:2.25) and [2.25:2.75], plus one bin for
// [5.0:5.5]. eq[] of [1.0:2.0] is one bin, as wide as the interval; half[]
// of the same range with real_interval 0.5 is [1.0:1.5) and [1.5:2.0]. fx[2]
// gets the 4 items [1.0:2.0), [2.0:3.0], 4.0 and 6.0, two in each bin. The
// integral range [1:3] of ints[] gives 3 bins; k stays 2.

module test_cg_real_bin_intervals;
  real r;
  int k = 2;

  covergroup cg;
    one: coverpoint r { bins s = {[1.0:3.0], 7.5}; }
    arr: coverpoint r { bins a[] = {[1.0:3.5]}; }
    off: coverpoint r { bins o[] = {[0.25:2.75], [5.0:5.5]}; }
    eq: coverpoint r { bins e[] = {[1.0:2.0]}; }
    half: coverpoint r { type_option.real_interval = 0.5; bins h[] = {[1.0:2.0]}; }
    fx: coverpoint r { bins f[2] = {[1.0:3.0], 4.0, 6.0}; }
    ints: coverpoint k { bins i[] = {[1:3]}; }
  endgroup

  cg g = new;

  task automatic put(real x);
    int c[7], t[7];
    r = x;
    g.sample();
    void'(g.one.get_inst_coverage(c[0], t[0]));
    void'(g.arr.get_inst_coverage(c[1], t[1]));
    void'(g.off.get_inst_coverage(c[2], t[2]));
    void'(g.eq.get_inst_coverage(c[3], t[3]));
    void'(g.half.get_inst_coverage(c[4], t[4]));
    void'(g.fx.get_inst_coverage(c[5], t[5]));
    void'(g.ints.get_inst_coverage(c[6], t[6]));
    $display("r=%.2f: one %0d/%0d, arr %0d/%0d, off %0d/%0d, eq %0d/%0d, half %0d/%0d, %s",
             x, c[0], t[0], c[1], t[1], c[2], t[2], c[3], t[3], c[4], t[4],
             $sformatf("fx %0d/%0d, ints %0d/%0d", c[5], t[5], c[6], t[6]));
  endtask

  initial begin
    put(1.75);
    put(2.0);
    put(3.5);
    put(1.25);
    put(0.25);
    put(2.75);
    put(5.5);
    put(6.0);
  end
endmodule

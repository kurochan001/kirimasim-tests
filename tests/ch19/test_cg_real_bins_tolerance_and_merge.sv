/*
:name: test_cg_real_bins_tolerance_and_merge
:description: A single real value with +/- or +%- in a real bin is a range, divided into intervals like any range when it is wider than the interval size, and identical intervals from several ranges of an open bin array are one bin while intervals that differ in the inclusion of an end stay apart (IEEE 1800-2023 Section 19.5.1)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5.1 11.4.13 19.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_real_bins_tolerance_and_merge.expected
*/
// IEEE 1800-2023 §19.5.1: +/- and +%- give a single real value of a bin a
// tolerance, which makes it a range (11.4.13: [A+/-B] is [A-B:A+B] and
// [A+%-B] is [A-A*B/100.0:A+A*B/100.0]), so the rules for ranges and
// intervals apply, including the division of a range wider than the interval
// size (type_option.real_interval, 1.0 here) into intervals. In an open bin
// array with several real ranges, identical intervals are merged into one
// bin; an interval that includes its high end differs from one that excludes
// it. get_inst_coverage(c, t) gives the covered bins and the bins (19.8).
//
// t1 is [4.75:5.25] and t2 [98.0:102.0], both ends included. t3 is [19.0:21.0],
// wider than 1.0, so it is [19.0:20.0) and [20.0:21.0]; t4 is [49.5:50.5],
// as wide as the interval, so it is one bin. m1 has [1.0:2.0) twice, merged,
// [2.0:3.0] and [2.0:2.5]: 3 bins. m2 has [1.0:2.0] from its first range,
// which is not divided, and [1.0:2.0) and [2.0:3.0] from the second: 3 bins.

module test_cg_real_bins_tolerance_and_merge;
  real r;

  covergroup cg;
    t1: coverpoint r { bins b = {[5.0+/-0.25]}; }
    t2: coverpoint r { bins b = {[100.0+%-2.0]}; }
    t3: coverpoint r { bins b[] = {[20.0+/-1.0]}; }
    t4: coverpoint r { bins b[] = {[50.0+%-1.0]}; }
    m1: coverpoint r { bins b[] = {[1.0:3.0], [1.0:2.5]}; }
    m2: coverpoint r { bins b[] = {[1.0:2.0], [1.0:3.0]}; }
  endgroup

  cg g = new;

  task automatic put(real v);
    int c[6], t[6];
    r = v;
    g.sample();
    void'(g.t1.get_inst_coverage(c[0], t[0]));
    void'(g.t2.get_inst_coverage(c[1], t[1]));
    void'(g.t3.get_inst_coverage(c[2], t[2]));
    void'(g.t4.get_inst_coverage(c[3], t[3]));
    void'(g.m1.get_inst_coverage(c[4], t[4]));
    void'(g.m2.get_inst_coverage(c[5], t[5]));
    $display("r=%.2f: t1 %0d/%0d, t2 %0d/%0d, t3 %0d/%0d, t4 %0d/%0d, m1 %0d/%0d, m2 %0d/%0d",
             v, c[0], t[0], c[1], t[1], c[2], t[2], c[3], t[3], c[4], t[4], c[5], t[5]);
  endtask

  initial begin
    put(4.5);
    put(5.25);
    put(102.5);
    put(98.0);
    put(19.5);
    put(20.0);
    put(50.5);
    put(2.0);
    put(1.5);
  end
endmodule

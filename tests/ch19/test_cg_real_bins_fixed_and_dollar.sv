/*
:name: test_cg_real_bins_fixed_and_dollar
:description: Fixed real bins share the intervals and single values out in order, floor(items / N) to a bin and the rest to the last one, keep repeated values, and leave the bins after the items empty; a real range with $ is one item that is never split (IEEE 1800-2023 Section 19.5.1)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5.1 19.11.1 19.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_real_bins_fixed_and_dollar.expected
*/
// IEEE 1800-2023 §19.5.1: for bins name[N] of a real coverpoint, each interval
// of a range and each single value is an item; each bin gets floor(items / N)
// items, at least 1, in the order listed, and the last bin also takes the
// rest; repeated values or intervals are kept. With more bins than items the
// last bins are empty, and empty bins are not counted (19.11.1). A real range
// with $ is assigned to one bin and is not divided into intervals.
// get_inst_coverage(c, t) gives the covered bins and the bins (19.8).
//
// fx[3] has the 7 items [1.0:2.0), [2.0:3.0], 2.5, [4.0:5.0), [5.0:6.0], 7.0
// and 8.0, so f[0] gets the first two, f[1] the next two and f[2] the last
// three; 2.5 is in both f[0] and f[1]. ex[4] has the 2 items 1.5 and
// [2.0:2.5]. d1[] of [$:0.5] is one bin, d2[] of 9.0 and [10.0:$] two, and
// d3[3] of the same two items has one empty bin. Instance x samples 2.5, 7.0,
// -100.0, 1.5, 1000.0 and 9.0; instance y samples 4.5 and 5.5.

module test_cg_real_bins_fixed_and_dollar;
  real r;

  covergroup cg;
    fx: coverpoint r { bins f[3] = {[1.0:3.0], 2.5, [4.0:6.0], 7.0, 8.0}; }
    ex: coverpoint r { bins e[4] = {1.5, [2.0:2.5]}; }
    d1: coverpoint r { bins d[] = {[$:0.5]}; }
    d2: coverpoint r { bins d[] = {9.0, [10.0:$]}; }
    d3: coverpoint r { bins d[3] = {9.0, [10.0:$]}; }
  endgroup

  cg x = new;
  cg y = new;

  task automatic put_x(real v);
    int c[5], t[5];
    r = v;
    x.sample();
    void'(x.fx.get_inst_coverage(c[0], t[0]));
    void'(x.ex.get_inst_coverage(c[1], t[1]));
    void'(x.d1.get_inst_coverage(c[2], t[2]));
    void'(x.d2.get_inst_coverage(c[3], t[3]));
    void'(x.d3.get_inst_coverage(c[4], t[4]));
    $display("x r=%.2f: fx %0d/%0d, ex %0d/%0d, d1 %0d/%0d, d2 %0d/%0d, d3 %0d/%0d", v,
             c[0], t[0], c[1], t[1], c[2], t[2], c[3], t[3], c[4], t[4]);
  endtask

  task automatic put_y(real v);
    int c, t;
    r = v;
    y.sample();
    void'(y.fx.get_inst_coverage(c, t));
    $display("y r=%.2f: fx %0d/%0d", v, c, t);
  endtask

  initial begin
    put_x(2.5);
    put_x(7.0);
    put_x(-100.0);
    put_x(1.5);
    put_x(1000.0);
    put_x(9.0);
    put_y(4.5);
    put_y(5.5);
  end
endmodule

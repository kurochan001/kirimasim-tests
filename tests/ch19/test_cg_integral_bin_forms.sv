/*
:name: test_cg_integral_bin_forms
:description: For an integral coverpoint, bins without brackets make one bin of all listed values, [] one bin per distinct value and [N] N bins sharing the values out, with empty bins when there are fewer values than bins, and $ in a range stands for the end of the range of the type (IEEE 1800-2023 Section 19.5.1)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5.1 19.11.1 19.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_integral_bin_forms.expected
*/
// IEEE 1800-2023 §19.5.1: bins name = {...} makes one bin for all the values of
// the list; name[] makes one bin for each value, a value listed twice still
// having one bin; name[N] makes N bins, giving each floor(values / N) values,
// at least 1, in the order listed, the last bin taking the rest, repeated
// values kept; with more bins than values the last bins are empty, and an
// empty bin is not counted (19.11.1). $ in a range is the largest or smallest
// value of the coverpoint. get_inst_coverage(c, t) gives the covered bins and
// the bins (19.8).
//
// For the 4-bit v: one is a single bin of 1, 4, 5, 14, 15; arr[] has a bin for
// each of 2, 3, 4, 5, 6 and 9; fix[3] of the 8 values 0 to 6 and 2 is <0,1>,
// <2,3> and <4,5,6,2>; exc[5] of 7, 8, 9 is <7>, <8>, <9> and two empty
// bins; low[] of [$:2] has bins for 0, 1 and 2.

module test_cg_integral_bin_forms;
  bit [3:0] v;

  covergroup cg;
    one: coverpoint v { bins s = {1, [4:5], [14:$]}; }
    arr: coverpoint v { bins a[] = {[2:4], [3:6], 9}; }
    fix: coverpoint v { bins f[3] = {[0:6], 2}; }
    exc: coverpoint v { bins e[5] = {7, 8, 9}; }
    low: coverpoint v { bins l[] = {[$:2]}; }
  endgroup

  cg g = new;

  task automatic put(bit [3:0] x);
    int c[5], t[5];
    v = x;
    g.sample();
    void'(g.one.get_inst_coverage(c[0], t[0]));
    void'(g.arr.get_inst_coverage(c[1], t[1]));
    void'(g.fix.get_inst_coverage(c[2], t[2]));
    void'(g.exc.get_inst_coverage(c[3], t[3]));
    void'(g.low.get_inst_coverage(c[4], t[4]));
    $display("v=%0d: one %0d/%0d, arr %0d/%0d, fix %0d/%0d, exc %0d/%0d, low %0d/%0d", x,
             c[0], t[0], c[1], t[1], c[2], t[2], c[3], t[3], c[4], t[4]);
  endtask

  initial begin
    put(15);
    put(2);
    put(9);
    put(0);
    put(5);
    put(8);
  end
endmodule

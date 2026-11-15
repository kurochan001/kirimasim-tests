/*
:name: test_cg_real_fixed_bins_listed_order
:description: Fixed real bins take their items in the order in which the values and ranges are listed, not in the order of their values (IEEE 1800-2023 Section 19.5.1)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_real_fixed_bins_listed_order.expected
*/
// IEEE 1800-2023 §19.5.1: for bins binname[N] of a real coverpoint, each
// interval of a range and each single value is one item; a range wider than
// the interval size (1.0 by default) is cut into intervals, each including
// its low end and excluding its high end, except the last, which includes
// both. Each bin gets B = floor(items / N) items, at least 1, the first B
// specified items going to the first bin, the next B to the next bin, and
// so on. get_inst_coverage(c, t) on the coverpoint gives the covered bins
// and the bins of the instance (19.8).
//
// The list {6.0, [1.0:3.0], 0.5} has the 4 items 6.0, [1.0:2.0), [2.0:3.0]
// and 0.5, in that order, so with N = 2 and B = 2 the bin f[0] holds 6.0
// and [1.0:2.0), and f[1] holds [2.0:3.0] and 0.5. Sampling 6.0 and then
// 1.5 hits f[0] twice, and 0.5 then hits f[1]. Items taken in the order of
// their values (0.5, [1.0:2.0), [2.0:3.0], 6.0) would put 6.0 and 1.5 in
// different bins and 0.5 with 1.5, which changes the second line.
// Icarus Verilog 13.0 does not compile covergroups, and the 5.054 release
// of Verilator does not support the arguments of get_inst_coverage on a
// coverpoint.

module test_cg_real_fixed_bins_listed_order;
  real r;

  covergroup cg;
    rx: coverpoint r { bins f[2] = {6.0, [1.0:3.0], 0.5}; }
  endgroup

  cg g = new;

  task automatic put(real v);
    int c, t;
    r = v;
    g.sample();
    void'(g.rx.get_inst_coverage(c, t));
    $display("%.1f: %0d/%0d", v, c, t);
  endtask

  initial begin
    put(6.0);
    put(1.5);
    put(0.5);
  end
endmodule

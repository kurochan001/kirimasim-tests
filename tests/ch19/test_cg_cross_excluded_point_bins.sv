/*
:name: test_cg_cross_excluded_point_bins
:description: A cross has no bins for the default, ignored or illegal bins of its coverpoints, so its products are only those of their other bins (IEEE 1800-2023 Section 19.6)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.6 19.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_cross_excluded_point_bins.expected
*/
// IEEE 1800-2023 §19.6: a cross has one bin for each combination of the bins
// of its coverpoints, but no cross bin is created for coverpoint bins that are
// default, ignored or illegal bins. ca has the bins a0 and a1 and the default
// bin rest; cb has b0 and b1, the ignored value 2 and the illegal value 3. So
// the cross x has the 2 x 2 products of a0, a1 and b0, b1. A sample in the
// default bin of ca, (2, 1), or in the ignored bin of cb, (0, 2), covers no
// bin of x. The test never samples b = 3, which would be a run-time error.
// get_inst_coverage(c, t) gives the covered bins and the bins (19.8).

module test_cg_cross_excluded_point_bins;
  bit [1:0] a, b;

  covergroup cg;
    ca: coverpoint a { bins a0 = {0}; bins a1 = {1}; bins rest = default; }
    cb: coverpoint b {
      bins b0 = {0};
      bins b1 = {1};
      ignore_bins ig = {2};
      illegal_bins il = {3};
    }
    x: cross ca, cb;
  endgroup

  cg g = new;

  task automatic put(bit [1:0] va, bit [1:0] vb);
    int c, t;
    a = va;
    b = vb;
    g.sample();
    void'(g.x.get_inst_coverage(c, t));
    $display("(%0d,%0d): x %0d/%0d", va, vb, c, t);
  endtask

  initial begin
    put(0, 0);
    put(2, 1);
    put(0, 2);
    put(1, 1);
  end
endmodule

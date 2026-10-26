/*
:name: test_cg_auto_bins_only_ignored_and_real
:description: An integral coverpoint with no bins other than ignored and illegal bins gets automatic bins, while a real coverpoint never gets automatic bins (IEEE 1800-2023 Section 19.5.3)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5.3 19.11.1 19.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_auto_bins_only_ignored_and_real.expected
*/
// IEEE 1800-2023 §19.5.3: if an integral coverpoint defines no bins except
// ignored and illegal ones, automatic state bins are created. For the 4-bit
// a there are 16 automatic bins; after the ignored value 1 and the illegal
// value 2 are removed, 14 bins keep a value and the two empty bins are not
// counted (19.11.1). A real coverpoint gets no automatic bins: rp has one
// explicit bin and its total stays 1. Sampling a = 0 and r = 0.5 covers one
// automatic bin and the explicit bin.

module test_cg_auto_bins_only_ignored_and_real;
  bit [3:0] a;
  real r;

  covergroup cg;
    only: coverpoint a {
      ignore_bins skip = {1};
      illegal_bins bad = {2};
    }
    rp: coverpoint r {
      bins v = {[0.0:1.0]};
    }
  endgroup

  cg g = new;

  initial begin
    int c[2], t[2];
    a = 0;
    r = 0.5;
    g.sample();
    void'(g.only.get_inst_coverage(c[0], t[0]));
    void'(g.rp.get_inst_coverage(c[1], t[1]));
    $display("only %0d/%0d, rp %0d/%0d", c[0], t[0], c[1], t[1]);
  end
endmodule

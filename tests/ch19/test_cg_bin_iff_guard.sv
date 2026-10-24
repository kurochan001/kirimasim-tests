/*
:name: test_cg_bin_iff_guard
:description: A bin with an iff guard is not incremented by a sample taken while its guard is false, while the other bins of the coverpoint are (IEEE 1800-2023 Section 19.5.1)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5.1 19.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_bin_iff_guard.expected
*/
// IEEE 1800-2023 §19.5.1: an iff at the end of a bin definition is a guard of
// that bin only: if it is false at a sampling point, the count of the bin is
// not incremented. The guard of lo is en, and hi has no guard. With en = 0,
// the samples 0 and 2 cover hi but not lo; with en = 1, the sample 1 covers
// lo. get_inst_coverage(c, t) gives the covered bins and the bins (19.8).

module test_cg_bin_iff_guard;
  bit [1:0] a;
  bit en;

  covergroup cg;
    cp: coverpoint a {
      bins lo = {[0:1]} iff (en);
      bins hi = {[2:3]};
    }
  endgroup

  cg g = new;

  task automatic put(bit [1:0] v, bit e);
    int c, t;
    a = v;
    en = e;
    g.sample();
    void'(g.cp.get_inst_coverage(c, t));
    $display("a=%0d en=%0d: %0d/%0d", v, e, c, t);
  endtask

  initial begin
    put(0, 0);
    put(2, 0);
    put(1, 1);
  end
endmodule

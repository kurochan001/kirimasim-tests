/*
:name: test_cg_warned_bin_elements_removed
:description: Bin values are cast to the effective type of the coverpoint, its own type or else the self-determined type of its expression; a single value that draws a warning, a range with an x bound and a range of which every value draws a warning are left out of the bin (IEEE 1800-2023 Section 19.5.7)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5.7 19.11.1 19.8
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_cg_warned_bin_elements_removed.expected
*/
// IEEE 1800-2023 §19.5.7: the effective type of a coverpoint expression is the
// coverpoint type if one is given, and otherwise the self-determined type of
// the expression; bin values are statically cast to it. A warning is issued
// for a negative signed value with an unsigned effective type, for a value the
// cast changes, and for a value with x or z bits. A single value with a
// warning does not take part in the bin; a range does not take part if a
// bound has x or z bits or if every value in it draws a warning. A bin left
// with no value is not counted (19.11.1). get_inst_coverage(c, t) gives the
// covered bins and the bins (19.8).
//
// cs has the effective type bit [2:0] of u (0 to 7): keep is {5}; wrap {13}
// (13 would become 5), neg {-3} (negative), xr {[3'b0x1:6]} (x in a bound) and
// hi {[8:12]} (no value fits) are empty; mix {6, 14} keeps only 6. So cs has 2
// bins, and the samples 2 and 0, which the removed elements would have
// matched after a cast, hit none. ct has the type bit [3:0], in which 13 needs
// no change, so its bin stays, although u never reaches 13.

module test_cg_warned_bin_elements_removed;
  bit [2:0] u;

  covergroup cg;
    cs: coverpoint u {
      bins keep = {5};
      bins wrap = {13};
      bins neg = {-3};
      bins xr = {[3'b0x1:6]};
      bins hi = {[8:12]};
      bins mix = {6, 14};
    }
    bit [3:0] ct: coverpoint u { bins b = {13}; }
  endgroup

  cg g = new;

  task automatic put(bit [2:0] x);
    int sc, st, tc, tt;
    u = x;
    g.sample();
    void'(g.cs.get_inst_coverage(sc, st));
    void'(g.ct.get_inst_coverage(tc, tt));
    $display("u=%0d: cs %0d/%0d, ct %0d/%0d", x, sc, st, tc, tt);
  endtask

  initial begin
    put(2);
    put(0);
    put(5);
    put(6);
  end
endmodule

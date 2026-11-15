/*
:name: test_cg_cross_matches_binds_before_or
:description: In a cross bin select expression a with clause and its matches clause bind more tightly than ||, so without parentheses they apply to the right operand of || only (IEEE 1800-2023 Section 19.6)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.6
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_cross_matches_binds_before_or.expected
*/
// IEEE 1800-2023 §19.6 (Syntax 19-4): the matches operator has higher
// precedence than && and ||. In binsof(ca.lo) || x1 with (e) matches 2 the
// operand of the with clause and its matches is therefore x1 alone, and ||
// joins the result to binsof(ca.lo); with parentheses around the || the
// clause filters the joined set instead. The bin tuple selection follows
// 19.6.1 and 19.6.1.2, and the coverage of a cross is its covered bins over
// the automatic bins of the products no user bin selects plus the user bins
// (19.11.2), which get_inst_coverage gives as a percentage (19.8).
//
// ca and cb each have the bins lo = {0, 1} and hi = {2, 3}, so each of the
// 4 bin tuples has 4 value tuples. ca + cb >= 4 holds for 0 value tuples of
// <lo,lo>, 1 of <lo,hi> and of <hi,lo>, and 4 of <hi,hi>, so matches 2
// keeps only <hi,hi>. In x1 the bin p is binsof(ca.lo), that is <lo,lo> and
// <lo,hi>, joined with <hi,hi>: 3 products, leaving <hi,lo> as the one
// automatic bin, 2 bins in all. In x2 the bin q filters all 4 products and
// keeps <hi,hi>, leaving 3 automatic bins, 4 bins in all. The samples (0,0),
// (2,1) and (3,3) then hit p, <hi,lo> and p in x1, and <lo,lo>, <hi,lo> and
// q in x2. A reading that gave the with clause the || as its operand would
// make x1 the same as x2.
// Icarus Verilog 13.0 does not compile covergroups.

module test_cg_cross_matches_binds_before_or;
  bit [1:0] a, b;

  covergroup cg;
    ca: coverpoint a { bins lo = {[0:1]}; bins hi = {[2:3]}; }
    cb: coverpoint b { bins lo = {[0:1]}; bins hi = {[2:3]}; }
    x1: cross ca, cb { bins p = binsof(ca.lo) || x1 with (ca + cb >= 4) matches 2; }
    x2: cross ca, cb { bins q = (binsof(ca.lo) || x2) with (ca + cb >= 4) matches 2; }
  endgroup

  cg g = new;

  task automatic put(bit [1:0] va, bit [1:0] vb);
    a = va;
    b = vb;
    g.sample();
    $display("(%0d,%0d): x1 %.2f, x2 %.2f", va, vb, g.x1.get_inst_coverage(),
             g.x2.get_inst_coverage());
  endtask

  initial begin
    put(0, 0);
    put(2, 1);
    put(3, 3);
  end
endmodule

/*
:name: test_dollar_cross_bin_matches_all_tuples
:description: As the integer covergroup expression of the matches clause of a cross bin, $ requires every value tuple of a bin tuple to satisfy the with expression: the bin selects the two bin tuples whose three value tuples all satisfy it and leaves out the one in which six of nine do, which the default policy of one selects, so the coverage of the cross shows one user bin of two products beside two automatic bins (IEEE 1800-2023 Section 6.20.7)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.20.7 19.6.1.2
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dollar_cross_bin_matches_all_tuples.expected
*/
// IEEE 1800-2023 §6.20.7: in the integer covergroup expression of a cross bin
// select expression, $ means that all value tuples have to satisfy the
// expression. §19.6.1.2: a with clause selects the candidate bin tuples in
// which enough value tuples make the with expression true, the matches clause
// gives that least number, $ asks for all value tuples of the bin tuple, and
// without matches one is enough. A cross identifier as the select expression
// offers every bin tuple of the cross. Products that no user bin selects keep
// automatic bins (19.6.1), and the coverage of a cross is its covered bins
// divided by its automatic bins plus its user bins (19.11.2), in percent from
// get_inst_coverage() (19.8).
// ca and cb have the bins lo = {0} and hi = {[1:3]}, so the bin tuples
// <lo,lo>, <lo,hi>, <hi,lo> and <hi,hi> have 1, 3, 3 and 9 value tuples. The
// expression ca != cb is true for 0 of 1 of them in <lo,lo>, for 3 of 3 in
// <lo,hi> and in <hi,lo>, and for 6 of 9 in <hi,hi> (all but the three with
// equal values).
// - x_all uses matches $: its bin ne selects <lo,hi> and <hi,lo>, and <lo,lo>
//   and <hi,hi> keep automatic bins, 3 bins in all;
// - x_one has no matches clause: its bin ne selects <lo,hi>, <hi,lo> and
//   <hi,hi>, and <lo,lo> keeps an automatic bin, 2 bins in all.
// Neither bin ne is empty, so the expected values do not depend on whether an
// empty user bin would count as a significant bin of 19.11.2.
// The samples (0,2), (3,0), (2,3) and (0,0) fall in <lo,hi>, <hi,lo>, <hi,hi>
// and <lo,lo>. In x_all the first two cover the one bin ne, so the coverage is
// 1 of 3 bins after both, 33.33 percent: the second sample adds nothing,
// which shows that <hi,lo> is in the bin of <lo,hi>, and the denominator 3
// leaves no room for a third product in ne. (2,3) satisfies the expression,
// but <hi,hi> also has value tuples that do not, so in x_all it covers the
// automatic bin of <hi,hi> (66.67) while in x_one it falls in ne (50.00
// stays); (0,0) covers the last automatic bin of each cross.
// Wrong readings of $ change the first line already: as the default policy of
// one, x_all would print the values of x_one; if $ selected no bin tuple,
// x_all would have four automatic bins and print 25, 50, 75 and 100 (20, 40,
// 60 and 80 if the empty bin ne were counted); a fixed count in place of $
// selects <hi,hi> with the other two when it is at most 3 (the values of
// x_one), <hi,hi> alone when it is 4 to 6 (25, 50, 75 and 100), and nothing
// above that.
// Oracle checks: the 5.054 release of Verilator gives the expected output with
// both seeds; Icarus Verilog 13.0 does not parse the covergroup.

module test_dollar_cross_bin_matches_all_tuples;
  bit [1:0] a, b;

  covergroup cg;
    ca: coverpoint a { bins lo = {0}; bins hi = {[1:3]}; }
    cb: coverpoint b { bins lo = {0}; bins hi = {[1:3]}; }
    x_all: cross ca, cb { bins ne = x_all with (ca != cb) matches $; }
    x_one: cross ca, cb { bins ne = x_one with (ca != cb); }
  endgroup

  cg g = new;

  task automatic put(bit [1:0] va, bit [1:0] vb);
    a = va;
    b = vb;
    g.sample();
    $display("(%0d,%0d): x_all %0.2f, x_one %0.2f", va, vb, g.x_all.get_inst_coverage(),
             g.x_one.get_inst_coverage());
  endtask

  initial begin
    put(0, 2);
    put(3, 0);
    put(2, 3);
    put(0, 0);
  end
endmodule

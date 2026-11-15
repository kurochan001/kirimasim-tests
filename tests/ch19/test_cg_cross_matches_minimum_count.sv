/*
:name: test_cg_cross_matches_minimum_count
:description: A cross bin with clause selects a bin tuple when at least one of its value tuples satisfies the expression without matches, at least N with matches N, and all of them with matches $ (IEEE 1800-2023 Section 19.6.1.2)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.6.1.2
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_cross_matches_minimum_count.expected
*/
// IEEE 1800-2023 §19.6.1.2: the matches clause of a with clause gives the
// least number of value tuples of a bin tuple that have to satisfy the
// expression for the bin tuple to be selected; $ asks for all of them, and
// without matches one is enough. A cross name used as the select expression
// gives all bin tuples. The products that no user bin selects keep automatic
// bins (19.6.1), and the coverage of a cross is its covered bins over those
// automatic bins plus the user bins (19.11.2), which get_inst_coverage gives
// as a percentage (19.8).
//
// ca has the five bins v[0] to v[4], one for each value 0 to 4, and cb the
// one bin all = {0, 1, 2, 3}. The bin tuple <v[k], all> has the 4 value
// tuples (k, 0) to (k, 3), and cb < ca holds for exactly k of them (all 4
// for k = 4). So the bin s selects k = 1 to 4 in n1 (no matches), k = 2 to
// 4 in n2 (matches 2), k = 3 and 4 in n3 (matches 3) and k = 4 only in nd
// (matches $): the crosses have 2, 3, 4 and 5 bins, so each covered bin adds
// 50.00, 33.33, 25.00 and 20.00. A policy of exactly N or more than N, or
// all instead of at least N, would change these numbers.
// The samples have a = 1, 2, 4 and 0; (2, 3) hits s of n2 although 3 < 2 is
// false, since the selection is made per bin tuple.
// Icarus Verilog 13.0 does not compile covergroups.

module test_cg_cross_matches_minimum_count;
  bit [2:0] a;
  bit [1:0] b;

  covergroup cg;
    ca: coverpoint a { bins v[] = {[0:4]}; }
    cb: coverpoint b { bins all = {[0:3]}; }
    n1: cross ca, cb { bins s = n1 with (cb < ca); }
    n2: cross ca, cb { bins s = n2 with (cb < ca) matches 2; }
    n3: cross ca, cb { bins s = n3 with (cb < ca) matches 3; }
    nd: cross ca, cb { bins s = nd with (cb < ca) matches $; }
  endgroup

  cg g = new;

  task automatic put(bit [2:0] va, bit [1:0] vb);
    a = va;
    b = vb;
    g.sample();
    $display("(%0d,%0d): n1 %.2f, n2 %.2f, n3 %.2f, nd %.2f", va, vb, g.n1.get_inst_coverage(),
             g.n2.get_inst_coverage(), g.n3.get_inst_coverage(), g.nd.get_inst_coverage());
  endtask

  initial begin
    put(1, 0);
    put(2, 3);
    put(4, 1);
    put(0, 2);
  end
endmodule

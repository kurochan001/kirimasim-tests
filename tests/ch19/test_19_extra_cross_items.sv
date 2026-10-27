/*
:name: test_19_extra_cross_items
:description: A cross of two explicit coverpoints creates one cross bin for each pair of their bins, so the group is not fully covered until every pair has occurred (IEEE 1800-2023 Section 19.6)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.6 19.11.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout_verilator: @test_19_extra_cross_items.expected
*/
// IEEE 1800-2023 §19.6: a cross names at least two cross items, here the
// coverpoints ca and cb. §19.6.1: the cross has a bin for each pair of bins
// of its items, so the pairs <lo,lo>, <lo,hi>, <hi,lo> and <hi,hi>. The first
// three samples cover both bins of ca and both bins of cb but only three of
// the four cross bins, so the cross is not fully covered and the instance
// coverage is below 100. The fourth sample covers the last cross bin, and
// then every item of the group is at 100. The test prints only whether the
// coverage has reached 100, because the exact percentage of the intermediate
// state depends on the weighting of §19.11.

module test_19_extra_cross_items;
  bit [1:0] a, b;

  covergroup cg;
    ca: coverpoint a { bins lo = {[0:1]}; bins hi = {[2:3]}; }
    cb: coverpoint b { bins lo = {[0:1]}; bins hi = {[2:3]}; }
    x: cross ca, cb;
  endgroup

  cg g;

  initial begin
    g = new;
    a = 0; b = 0; g.sample();
    a = 2; b = 1; g.sample();
    a = 0; b = 2; g.sample();
    $display("all point bins, three cross bins, below 100: %0d",
             g.get_inst_coverage() < 100.0);
    a = 2; b = 2; g.sample();
    $display("all four cross bins, 100: %0d", g.get_inst_coverage() == 100.0);
  end
endmodule

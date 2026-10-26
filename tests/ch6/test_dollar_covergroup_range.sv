/*
:name: test_dollar_covergroup_range
:description: a covergroup value range [$:expression] includes every value at or below it and [expression:$] every value at or above it, down to zero and up to the type maximum
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.20.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dollar_covergroup_range.expected
*/
// IEEE 1800-2023 6.20.7: a dollar bound in a covergroup value range has the
// same meaning as in a value range. Six single-bin covergroups separate the
// cases: a sample of 0 or 2 hits [$:2] and a sample of 3 does not; a sample of
// 15 or 3 hits [3:$] and a sample of 2 does not. A hit bin is 100% instance
// coverage and a bin with no hit is 0%. The samples 0 and 15 also show that
// the dollar end reaches the smallest and largest value of the 4-bit
// coverpoint. A tool that excludes the bound, or that makes a dollar range
// empty, prints another truth value.

module test_dollar_covergroup_range;
  logic [3:0] v;

  covergroup cg_lo;
    coverpoint v { bins b = {[$:2]}; }
  endgroup
  covergroup cg_hi;
    coverpoint v { bins b = {[3:$]}; }
  endgroup

  cg_lo l0 = new;
  cg_lo l2 = new;
  cg_lo l3 = new;
  cg_hi h15 = new;
  cg_hi h3 = new;
  cg_hi h2 = new;

  initial begin
    v = 0;
    l0.sample();
    v = 2;
    l2.sample();
    v = 3;
    l3.sample();
    v = 15;
    h15.sample();
    v = 3;
    h3.sample();
    v = 2;
    h2.sample();
    $display("lo0=%0d lo2=%0d lo3=%0d", (l0.get_inst_coverage() == 100.0),
             (l2.get_inst_coverage() == 100.0), (l3.get_inst_coverage() == 0.0));
    $display("hi15=%0d hi3=%0d hi2=%0d", (h15.get_inst_coverage() == 100.0),
             (h3.get_inst_coverage() == 100.0), (h2.get_inst_coverage() == 0.0));
  end
endmodule

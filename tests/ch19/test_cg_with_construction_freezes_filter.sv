/*
:name: test_cg_with_construction_freezes_filter
:description: A bin with expression captures its filter at construction and applies filtering before distribution unless distribute_first reverses the order (IEEE 1800-2023 Section 19.5.1.1)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5.1.1 19.5.1 19.7.1 19.11.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_with_construction_freezes_filter.expected
*/
// 19.5.1.1 B011 evaluates the with expression for the candidates when the
// instance is constructed. ceiling is 5 then and changes to 2 afterwards;
// sampling must still use the values 0..4 captured at construction.
// With the default ordering, 19.5.1 distributes these five values into two
// bins {0,1} and {2,3,4}. distribute_first instead splits the original six
// candidates into {0,1,2} and {3,4,5}, then filters to {0,1,2} and {3,4}.
// Thus samples 2,1,4 give coverages (50,100,100) and (50,50,100).
// Six fresh instances independently sample each candidate 0..5: each value
// 0..4 covers exactly one of two bins, while 5 covers none. This makes each
// candidate's inclusion observable even if another value shares its bin.
// A sample-time filter would exclude 2 and 4 after ceiling
// changes, while reversing either distribution order changes the middle row.
// Each instance has one coverpoint with two ordinary bins; 19.8 and 19.11.1
// give its own 0, 50 or 100 coverage, independent of other instances or goals.
// The 5.054 release of the Verilator simulator reports distribute=100 after
// sample 1 with seeds 1 and 73,
// where the specified distribute-first ordering requires 50. The common
// expectation retains 50; this test therefore has no Verilator oracle.

module test_cg_with_construction_freezes_filter;
  bit [2:0] value;
  int ceiling = 5;

  covergroup filter_before;
    cp: coverpoint value {
      bins selected[2] = {[0:5]} with (item < ceiling);
    }
  endgroup

  covergroup distribute_before;
    type_option.distribute_first = 1;
    cp: coverpoint value {
      bins selected[2] = {[0:5]} with (item < ceiling);
    }
  endgroup

  filter_before gf;
  distribute_before gd;
  filter_before gf_one[6];
  distribute_before gd_one[6];

  task automatic sample_value(input bit [2:0] v);
    value = v;
    gf.sample();
    gd.sample();
    $display("sample=%0d filter=%.0f distribute=%.0f",
             v, gf.cp.get_inst_coverage(), gd.cp.get_inst_coverage());
  endtask

  initial begin
    gf = new;
    gd = new;
    foreach (gf_one[i]) begin
      gf_one[i] = new;
      gd_one[i] = new;
    end
    ceiling = 2;
    $display("before samples filter=%.0f distribute=%.0f",
             gf.cp.get_inst_coverage(), gd.cp.get_inst_coverage());
    sample_value(2);
    sample_value(1);
    sample_value(4);
    sample_value(3);
    sample_value(0);
    foreach (gf_one[i]) begin
      value = 3'(i);
      gf_one[i].sample();
      gd_one[i].sample();
      $display("isolated=%0d filter=%.0f distribute=%.0f", i,
               gf_one[i].cp.get_inst_coverage(), gd_one[i].cp.get_inst_coverage());
    end
  end
endmodule

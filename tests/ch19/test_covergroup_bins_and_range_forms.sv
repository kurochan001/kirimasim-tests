/*
:name: test_covergroup_bins_and_range_forms
:description: Value bins take a range list, an open or fixed array, a set expression, a wildcard pattern or a with filter; ignored, illegal and default bins, transition bins with consecutive, goto and nonconsecutive repetitions, and ranges with a tolerance token each cover the values their definitions select (IEEE 1800-2023 Sections 19.5.1 to 19.5.6)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5.1 19.5.1.1 19.5.1.2 19.5.2 19.5.3 19.5.4 19.5.5 19.5.6 19.11.1 A.2.11
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_covergroup_bins_and_range_forms.expected
*/
// IEEE 1800-2023 §19.5.1 with A.2.11: a value bin is a name with optional
// brackets around a covergroup expression and a covergroup range list; the
// range list holds values and ranges, including [low:high], [low:$], [$:high]
// and the relative tolerance range of 11.4.13. Empty brackets make one bin per
// value and a number makes that many bins. §19.5.1.1 adds with (expression);
// §19.5.1.2 allows an array expression as the set of values; §19.5.4 gives
// wildcard bins; §19.5.5 and §19.5.6 give ignore_bins and illegal_bins, and a
// default bin takes the remaining values. §19.5.2 gives transition bins with
// consecutive, goto and nonconsecutive repetitions, and a default sequence
// bin. Coverage is the covered bins over all bins of a coverpoint (§19.11.1).
//
// x is 1 to 8 at eight samples and y is 6 and then 3 at two samples. The
// covergroups have one coverpoint each, so their coverage is that of the
// coverpoint: ranges 4/4, lists 4/5, the set 1/1, the wildcard pattern 1/1
// (sample 8 matches 4'b1?0?), the with filters 2/2, ignoring 1 and keeping a
// default bin 2/2, the transitions 7/8 (all but 1 => 3 [* 2]), and the
// tolerance ranges 3/3. Icarus Verilog 13.0 has no covergroups. The 5.052
// release of Verilator does not support a set expression, a bin built from a
// coverpoint name with, the tolerance ranges or the goto and nonconsecutive
// transition repetitions, and it makes four bins of fixed [2] instead of two.

module test_covergroup_bins_and_range_forms;
  int x = 0;
  bit [3:0] y = 0;
  bit en = 1;
  int set_vals[2] = '{2, 3};

  covergroup cg_ranges;
    cp: coverpoint x {
      bins low = {[0:2]};
      bins mid = {[3:4]};
      bins high = {[5:$]};
      bins single = {6} iff (en);
    }
  endgroup

  covergroup cg_lists;
    cp: coverpoint x {
      bins even[] = {0, 2, 4};
      bins fixed [2] = {0, 1, 2, 3};
    }
  endgroup

  covergroup cg_set;
    cp: coverpoint x { bins fromset = set_vals; }
  endgroup

  covergroup cg_wild;
    cp: coverpoint x { wildcard bins nib = {4'b1?0?}; }
  endgroup

  covergroup cg_with;
    cp: coverpoint x {
      bins ev = {[0:6]} with (item % 2 == 0);
      bins cpw = cp with (item != 3);
    }
  endgroup

  covergroup cg_ign;
    cp: coverpoint x {
      bins ok = {[0:5]};
      ignore_bins skip = {1};
      illegal_bins bad = {15};
      bins others = default;
    }
  endgroup

  covergroup cg_tr;
    cp: coverpoint x {
      bins t1 = (1 => 2);
      bins t2 = (1 => 3 [* 2]);
      bins t3 = (1 => 4 [-> 1]);
      bins t4 = (1 => 5 [= 1]);
      bins t5 = (5 => 6 [* 1:2]);
      bins tarr[] = (2 => 3), (3 => 4);
      bins allother = default sequence;
    }
  endgroup

  covergroup cg_tol;
    cp: coverpoint y {
      bins abs = {[6 +/- 1]};
      bins rel = {[4 +%- 50]};
      bins all = {[$:15]};
    }
  endgroup

  cg_ranges g_ranges = new;
  cg_lists g_lists = new;
  cg_set g_set = new;
  cg_wild g_wild = new;
  cg_with g_with = new;
  cg_ign g_ign = new;
  cg_tr g_tr = new;
  cg_tol g_tol = new;

  task automatic sample_all();
    g_ranges.sample();
    g_lists.sample();
    g_set.sample();
    g_wild.sample();
    g_with.sample();
    g_ign.sample();
    g_tr.sample();
  endtask

  initial begin
    for (int i = 1; i <= 8; i++) begin
      x = i;
      sample_all();
    end
    y = 6;
    g_tol.sample();
    y = 3;
    g_tol.sample();
    $display("ranges %0.1f, lists %0.1f, set %0.1f, wildcard %0.1f",
             g_ranges.get_inst_coverage(), g_lists.get_inst_coverage(),
             g_set.get_inst_coverage(), g_wild.get_inst_coverage());
    $display("with %0.1f, ignore %0.1f, transitions %0.1f, tolerance %0.1f",
             g_with.get_inst_coverage(), g_ign.get_inst_coverage(),
             g_tr.get_inst_coverage(), g_tol.get_inst_coverage());
    $finish;
  end
endmodule

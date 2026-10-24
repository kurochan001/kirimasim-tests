/*
:name: test_cg_zero_denominator_groups
:description: A covergroup whose coverage has a zero denominator, because it has no items, all its items are excluded or all their weights are zero, gives 0.0 from both coverage queries when its weight is nonzero and 100.0 when it is zero, sets both count arguments to 0 and does not count in the overall coverage, and an excluded item counts in neither the numerator nor the denominator (IEEE 1800-2023 Section 19.11)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.11 19.11.1 19.9 19.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_zero_denominator_groups.expected
*/
// IEEE 1800-2023 §19.11: the coverage of a covergroup is the weighted average
// of its items; an item excluded by its own rules (19.11.1: a coverpoint whose
// bins have no values) counts in neither the numerator nor the denominator.
// The denominator is zero when all items are excluded, when all weights are
// zero, or when there are no items. Then the covergroup does not contribute to
// the overall coverage; get_coverage and get_inst_coverage return 0.0 if the
// weight of the covergroup is nonzero and 100.0 if it is zero; and both
// arguments of the two-argument forms (19.8) are set to 0.
//
// cg_empty has no items, all bins of the only coverpoint of cg_excluded are
// ignored, the only coverpoint of cg_zero_items has weight 0, and
// cg_zero_weight has no items and weight 0 (both option.weight and
// type_option.weight).
// cg_partial has cp at 25% and the excluded ce, so its coverage is 25.00 and
// its counts are those of cp. $get_coverage (19.9) then averages only
// cg_partial: 25.00.

module test_cg_zero_denominator_groups;
  bit [1:0] a;

  covergroup cg_empty;
  endgroup

  covergroup cg_excluded;
    cp: coverpoint a { bins v[] = {[0:1]}; ignore_bins ig = {[0:1]}; }
  endgroup

  covergroup cg_zero_items;
    cp: coverpoint a { option.weight = 0; bins v[] = {[0:3]}; }
  endgroup

  covergroup cg_zero_weight;
    option.weight = 0;
    type_option.weight = 0;
  endgroup

  covergroup cg_partial;
    cp: coverpoint a { bins v[] = {[0:3]}; }
    ce: coverpoint a { bins v[] = {[0:1]}; ignore_bins ig = {[0:1]}; }
  endgroup

  cg_empty ge = new;
  cg_excluded gx = new;
  cg_zero_items gi = new;
  cg_zero_weight gw = new;
  cg_partial gp = new;

  initial begin
    int ic, it, tc, tt;
    real ir, tr;
    a = 1;
    ge.sample();
    gx.sample();
    gi.sample();
    gw.sample();
    gp.sample();
    ir = ge.get_inst_coverage(ic, it);
    tr = cg_empty::get_coverage(tc, tt);
    $display("no items: inst %.2f (%0d/%0d), type %.2f (%0d/%0d)", ir, ic, it, tr, tc, tt);
    ir = gx.get_inst_coverage(ic, it);
    tr = cg_excluded::get_coverage(tc, tt);
    $display("all excluded: inst %.2f (%0d/%0d), type %.2f (%0d/%0d)", ir, ic, it, tr, tc, tt);
    ir = gi.get_inst_coverage(ic, it);
    tr = cg_zero_items::get_coverage(tc, tt);
    $display("item weights 0: inst %.2f (%0d/%0d), type %.2f (%0d/%0d)", ir, ic, it, tr, tc,
             tt);
    ir = gw.get_inst_coverage(ic, it);
    tr = cg_zero_weight::get_coverage(tc, tt);
    $display("weight 0: inst %.2f (%0d/%0d), type %.2f (%0d/%0d)", ir, ic, it, tr, tc, tt);
    ir = gp.get_inst_coverage(ic, it);
    $display("partial: inst %.2f (%0d/%0d)", ir, ic, it);
    $display("$get_coverage: %.2f", $get_coverage());
  end
endmodule

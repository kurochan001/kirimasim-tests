/*
:name: test_cg_zero_denominator_items
:description: A coverpoint with no bin that has a value, or a cross whose products are all ignored, has a zero denominator: it gives 0.0 from both coverage queries when its weight is nonzero and 100.0 when it is zero, sets both count arguments to 0, and does not count in the coverage of its covergroup (IEEE 1800-2023 Sections 19.11.1, 19.11.2)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.11.1 19.11.2 19.11 19.5.5 19.6.2 19.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_zero_denominator_items.expected
*/
// IEEE 1800-2023 §19.11.1: when none of the bins of a coverpoint has a value
// or a transition, the denominator of its coverage is zero; §19.11.2: the
// same for a cross whose denominator Bc + Bu is zero. Such an item does not
// contribute to the coverage of its covergroup; get_coverage and
// get_inst_coverage return 0.0 if its weight is nonzero and 100.0 if it is
// zero; both arguments of the two-argument forms (19.8) are set to 0.
//
// The ignored values 0 and 1 (19.5.5) empty both bins of ce and cz; the
// ignore_bins all of xe and xz selects every product of the cross (19.6.2),
// so no automatic or significant user bin is left. cz and xz have weight 0
// (option.weight and type_option.weight). After one sample with a = 0 and
// b = 0, cp is at 25% and cb at 50%, so the covergroup is at (25 + 50) / 2.

module test_cg_zero_denominator_items;
  bit [1:0] a;
  bit b;

  covergroup cg;
    cp: coverpoint a { bins v[] = {[0:3]}; }
    ce: coverpoint a { bins e[] = {[0:1]}; ignore_bins ig = {[0:1]}; }
    cz: coverpoint a {
      option.weight = 0;
      type_option.weight = 0;
      bins e[] = {[0:1]};
      ignore_bins ig = {[0:1]};
    }
    cb: coverpoint b { bins v[] = {0, 1}; }
    xe: cross cp, cb { ignore_bins all = binsof(cp); }
    xz: cross cp, cb {
      option.weight = 0;
      type_option.weight = 0;
      ignore_bins all = binsof(cp);
    }
  endgroup

  cg g = new;

  initial begin
    int c, t;
    real r;
    a = 0;
    b = 0;
    g.sample();
    r = g.ce.get_inst_coverage(c, t);
    $display("ce: inst %.2f (%0d/%0d), type %.2f", r, c, t, cg::ce::get_coverage());
    r = g.cz.get_inst_coverage(c, t);
    $display("cz: inst %.2f (%0d/%0d), type %.2f", r, c, t, cg::cz::get_coverage());
    r = g.xe.get_inst_coverage(c, t);
    $display("xe: inst %.2f (%0d/%0d), type %.2f", r, c, t, cg::xe::get_coverage());
    r = g.xz.get_inst_coverage(c, t);
    $display("xz: inst %.2f (%0d/%0d), type %.2f", r, c, t, cg::xz::get_coverage());
    r = cg::cz::get_coverage(c, t);
    $display("cz type counts: %0d/%0d", c, t);
    $display("covergroup: %.2f", g.get_inst_coverage());
  end
endmodule

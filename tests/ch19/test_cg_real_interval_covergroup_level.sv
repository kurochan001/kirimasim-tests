/*
:name: test_cg_real_interval_covergroup_level
:description: type_option.real_interval set for a covergroup is the interval of its real coverpoints that do not set their own, so their ranges are divided into intervals of that size, the last one shorter when the range does not divide evenly; a coverpoint that sets its own interval uses it, a range as wide as the interval stays one bin, and integral bins and another covergroup keep their own rules (IEEE 1800-2023 Sections 19.7.1, 19.5.1)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.7.1 19.5.1 19.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_real_interval_covergroup_level.expected
*/
// IEEE 1800-2023 §19.7.1: type options set at the covergroup level are not
// defaults for its coverpoints and crosses, except real_interval (Table 19-4
// allows it for a covergroup and a coverpoint; its default is 1.0).
// §19.5.1: for name[] of a real coverpoint, a range wider than the interval is
// divided into intervals of that size from its low end, each including its low
// end and excluding its high end except the last, which includes both and may
// be shorter; a range no wider than the interval is one bin. An integral range
// gives one bin per value. get_inst_coverage(c, t) gives the covered bins and
// the bins (§19.8).
//
// cg sets real_interval to 0.5. inh [1.0:2.0] is [1.0:1.5) and [1.5:2.0]; odd
// [1.0:2.2] is [1.0:1.5), [1.5:2.0) and [2.0:2.2]; own sets 0.25, so its
// [1.0:2.0] has 4 bins; one [3.0:3.5] is as wide as 0.5 and is one bin; ints
// [1:3] has 3 bins and samples k = 2. plain is in a covergroup without the
// setting, so its [1.0:2.0] is one bin of the default interval 1.0. The
// samples 1.25, 1.5, 2.1, 2.0 and 3.5 then fill the bins in the order below.
// Icarus Verilog 13.0 does not support covergroups, and the 5.054 release
// of the simulator named Verilator does not support the arguments of
// get_inst_coverage, so the expected output follows the cited clauses.

module test_cg_real_interval_covergroup_level;
  real r;
  int k = 2;

  covergroup cg;
    type_option.real_interval = 0.5;
    inh: coverpoint r { bins b[] = {[1.0:2.0]}; }
    odd: coverpoint r { bins b[] = {[1.0:2.2]}; }
    own: coverpoint r { type_option.real_interval = 0.25; bins b[] = {[1.0:2.0]}; }
    one: coverpoint r { bins b[] = {[3.0:3.5]}; }
    ints: coverpoint k { bins b[] = {[1:3]}; }
  endgroup

  covergroup cg_plain;
    plain: coverpoint r { bins b[] = {[1.0:2.0]}; }
  endgroup

  cg g = new;
  cg_plain gp = new;

  task automatic put(real v);
    int c[6], t[6];
    r = v;
    g.sample();
    gp.sample();
    void'(g.inh.get_inst_coverage(c[0], t[0]));
    void'(g.odd.get_inst_coverage(c[1], t[1]));
    void'(g.own.get_inst_coverage(c[2], t[2]));
    void'(g.one.get_inst_coverage(c[3], t[3]));
    void'(g.ints.get_inst_coverage(c[4], t[4]));
    void'(gp.plain.get_inst_coverage(c[5], t[5]));
    $display("r=%.2f: inh %0d/%0d, odd %0d/%0d, own %0d/%0d, one %0d/%0d, ints %0d/%0d, %s",
             v, c[0], t[0], c[1], t[1], c[2], t[2], c[3], t[3], c[4], t[4],
             $sformatf("plain %0d/%0d", c[5], t[5]));
  endtask

  initial begin
    put(1.25);
    put(1.5);
    put(2.1);
    put(2.0);
    put(3.5);
  end
endmodule

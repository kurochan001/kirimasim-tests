/*
:name: test_cg_merge_auto_and_transition_names
:description: With merge_instances, a single transition bin is one bin for all instances, transition array bins are shared by the instances with the same transition, automatic bins keep their auto[low:high] names whatever values are ignored or illegal, a bin they empty in every instance does not count, and automatic cross bins are shared only by instances with the same names of the crossed bins (IEEE 1800-2023 Section 19.11.3)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.11.3 19.5.3 19.5.2 19.6 19.11.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_merge_auto_and_transition_names.expected
*/
// IEEE 1800-2023 §19.11.3: with merge_instances the bins of all instances are
// joined by name. A bin declared as name, here a transition bin, has that name
// in every instance. The bins of a transition array name[] are named
// name[transition] (19.5.2); automatic bins are named auto[value] or
// auto[low:high] (19.5.3), names that ignored and illegal values do not
// change, although they may empty a bin, which then does not count (19.11.1);
// automatic cross bins are named after the crossed bins, <name1,...,nameN>
// (19.6), and only identical names are shared.
//
// cg_tr: k1 and k3 = new(0) have t[0=>1] and t[0=>2], k2 = new(3) t[3=>1] and
// t[3=>2], 4 bins in the union; k1 covers 0 => 1 and k3 0 => 2. one_t holds
// the transitions s => 1 and s => 2 in each instance and is a single bin of
// the union. cg_au: with auto_bin_max 4 the 3-bit a has auto[0:1] to
// auto[6:7]; m1 ignores 2 and 6 and makes 5 and 7 illegal, m2 ignores 3 and 6
// and makes 4 and 7 illegal. The names stay as they are, and auto[6:7], empty
// in both, leaves 3 bins in the union. m1 samples 3 and m2 samples 2, both in
// auto[2:3]; then m2 samples 5. cg_x: n1 and n2 (auto_bin_max 8) have the 16
// products <auto[i],auto[j]> of ca and the 1-bit cb, n3 (auto_bin_max 4) 8
// products with auto[low:high] for ca, so the union of x has 24 bins and that
// of ca 12; each instance samples (0, 0).

module test_cg_merge_auto_and_transition_names;
  bit [2:0] a;
  bit b;

  covergroup cg_tr (int s);
    type_option.merge_instances = 1;
    tr: coverpoint a { bins t[] = (s => 1, 2); }
    ts: coverpoint a { bins one_t = (s => 1, 2); }
  endgroup

  covergroup cg_au (int ig, int il);
    type_option.merge_instances = 1;
    au: coverpoint a {
      option.auto_bin_max = 4;
      ignore_bins skip = {ig, 6};
      illegal_bins bad = {il, 7};
    }
  endgroup

  covergroup cg_x (int abm);
    type_option.merge_instances = 1;
    option.auto_bin_max = abm;
    ca: coverpoint a;
    cb: coverpoint b;
    x: cross ca, cb;
  endgroup

  cg_tr k1 = new(0);
  cg_tr k2 = new(3);
  cg_tr k3 = new(0);
  cg_au m1 = new(2, 5);
  cg_au m2 = new(3, 4);
  cg_x n1 = new(8);
  cg_x n2 = new(8);
  cg_x n3 = new(4);

  initial begin
    a = 0; k1.sample();
    a = 1; k1.sample();
    a = 0; k3.sample();
    a = 2; k3.sample();
    $display("transition bins: t %.2f, one_t %.2f", cg_tr::tr::get_coverage(),
             cg_tr::ts::get_coverage());
    a = 3; m1.sample();
    a = 2; m2.sample();
    $display("automatic bins: %.2f", cg_au::au::get_coverage());
    a = 5; m2.sample();
    $display("automatic bins, then m2 samples 5: %.2f", cg_au::au::get_coverage());
    a = 0;
    b = 0;
    n1.sample();
    n2.sample();
    n3.sample();
    $display("cross: x %.2f, ca %.2f", cg_x::x::get_coverage(), cg_x::ca::get_coverage());
  end
endmodule

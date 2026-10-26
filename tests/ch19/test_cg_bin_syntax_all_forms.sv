/*
:name: test_cg_bin_syntax_all_forms
:description: a coverpoint takes an optional type and label, an optional iff, and every form of bins of Syntax 19-2 creates its bins, while a default bin, ignore_bins and illegal_bins are not counted (IEEE 1800-2023 Section 19.5)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5 19.5.1 19.5.2 19.5.3 19.5.4 19.11.1
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_cg_bin_syntax_all_forms.expected
*/
// IEEE 1800-2023 §19.5, Syntax 19-2: a coverage point is an optional data type
// and label, coverpoint, an optional iff and the bins. A bins declaration is a
// coverage option, a value bin of a range list with an optional with clause,
// a value bin of a coverpoint, a bin of a set expression, a transition bin of
// a trans list, a default bin or a default sequence, and bins, ignore_bins and
// illegal_bins each take one of these. §19.5.1: a bin name without brackets is
// one bin, name[] is one bin per value and name[N] makes N bins. §19.5.2: one
// trans_list is one transition bin and name[] makes one bin per transition.
// §19.5.3: automatic bins do not exist when explicit bins are given. §19.5.4:
// a wildcard bin is one bin. §19.11.1: the coverage of a point is the covered
// bins over all its bins, and a default bin, ignore_bins and illegal_bins are
// not among them. The test prints the number of bins of each point and of a
// cross before anything is sampled, and then the coverage after one sample.

module test_cg_bin_syntax_all_forms;
  bit [3:0] v;
  bit [3:0] w;
  bit en;
  byte setvals[3] = '{1, 2, 3};

  covergroup cg;
    int typed: coverpoint v {
      bins one = {[0:3]};
    }
    lab: coverpoint v iff (en) {
      bins range = {1, [3:5]};
      bins each[] = {6, 7};
      bins fixed[2] = {[8:11]};
      bins top = {[12:$]};
      bins wc = wildcard {4'b0?1?};
      bins trans = (1 => 2);
      bins other = default;
      ignore_bins skip = {14};
      illegal_bins bad = {15};
      option.weight = 3;
    }
    fromset: coverpoint w {
      bins chosen = setvals;
    }
    seq: coverpoint w {
      bins ts[] = (4 => 5);
      bins rest = default sequence;
    }
    cx: cross lab, fromset;
  endgroup

  cg g = new;

  initial begin
    int t[5];
    real c[5];
    void'(g.typed.get_inst_coverage(c[0], t[0]));
    void'(g.lab.get_inst_coverage(c[1], t[1]));
    void'(g.fromset.get_inst_coverage(c[2], t[2]));
    void'(g.seq.get_inst_coverage(c[3], t[3]));
    void'(g.cx.get_inst_coverage(c[4], t[4]));
    $display("bins: typed %0d lab %0d fromset %0d seq %0d cross %0d",
             t[0], t[1], t[2], t[3], t[4]);
    en = 1;
    v = 4'b0101;
    w = 1;
    g.sample();
    $display("after one sample: typed %0.2f lab %0.2f fromset %0.2f",
             g.typed.get_inst_coverage(), g.lab.get_inst_coverage(),
             g.fromset.get_inst_coverage());
  end
endmodule

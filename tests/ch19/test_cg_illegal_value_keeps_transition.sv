/*
:name: test_cg_illegal_value_keeps_transition
:description: An illegal transition removes the transition bin sequences that cannot match without it, while an illegal value leaves the transitions that go through it in their bins (IEEE 1800-2023 Section 19.5.6)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5.6 19.11.1 19.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_illegal_value_keeps_transition.expected
*/
// IEEE 1800-2023 §19.5.6: a covered sequence of a transition bin is removed
// when it cannot be matched without also matching an illegal sequence, but
// specifying an illegal value has no effect on a transition that includes the
// value. A bin left with no value or sequence is not counted (19.11.1).
//
// The illegal transition 5 => 6 removes the only sequence of t_bad,
// 4 => 5 => 6, so t_bad is empty. The illegal value 2 does not remove
// 1 => 2 => 3 from t_thru, so t_thru stays and is counted. The coverpoint has
// the bins v0, t_thru and t_ok: 3 bins. The test never samples 2 or 5
// followed by 6, which would be run-time errors, so t_thru stays uncovered.
// get_inst_coverage(c, t) gives the covered bins and the bins (19.8).

module test_cg_illegal_value_keeps_transition;
  bit [2:0] a;

  covergroup cg;
    cp: coverpoint a {
      bins v0 = {0};
      bins t_thru = (1 => 2 => 3);
      bins t_bad = (4 => 5 => 6);
      bins t_ok = (6 => 7);
      illegal_bins ill_v = {2};
      illegal_bins ill_t = (5 => 6);
    }
  endgroup

  cg g = new;

  task automatic put(bit [2:0] x);
    int c, t;
    a = x;
    g.sample();
    void'(g.cp.get_inst_coverage(c, t));
    $display("a=%0d: %0d/%0d", x, c, t);
  endtask

  initial begin
    put(0);
    put(6);
    put(7);
  end
endmodule

/*
:name: test_cg_illegal_transition_error
:description: A sampled transition in an illegal transition bin issues a run-time error even when the same sequence is also in an ordinary transition bin, and the sequence is removed from that bin (IEEE 1800-2023 Section 19.5.6)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5.6 19.11.1 19.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_illegal_transition_error.expected
:expected_stderr_regex: test_cg_illegal_transition_error\.sv:(46|47):
*/
// IEEE 1800-2023 §19.5.6: an illegal transition bin removes the covered
// sequences that cannot match without it, and the occurrence of an illegal
// transition issues a run-time error; illegal bins take precedence even when
// the sequence is also in another bin. The transition 1=>2 is both bin t and
// illegal_bins b, so t is left with no sequence and does not count; the only
// bin of cp is other = 3=>4. Before the illegal sequence, sampling 3 then 4
// covers other, so cp is 1/1. The error is caused by 1 then 2.

module test_cg_illegal_transition_error;
  bit [2:0] a;

  covergroup cg;
    cp: coverpoint a {
      bins t = (1 => 2);
      bins other = (3 => 4);
      illegal_bins b = (1 => 2);
    }
  endgroup

  cg g = new;

  initial begin
    int c, t;
    a = 3;
    g.sample();
    a = 4;
    g.sample();
    void'(g.cp.get_inst_coverage(c, t));
    $display("before illegal");
    $display("cp %0d/%0d", c, t);
    a = 1;
    g.sample();
    a = 2;
    g.sample();
  end
endmodule

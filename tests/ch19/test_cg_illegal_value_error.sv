/*
:name: test_cg_illegal_value_error
:description: A sampled value in an illegal bin issues a run-time error even when the same value is also in an ordinary bin, and the illegal value is removed from that bin before sampling it (IEEE 1800-2023 Section 19.5.6)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5.6 19.11.1 19.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_illegal_value_error.expected
:expected_stderr_regex: (?i:\berror\b)
*/
// IEEE 1800-2023 §19.5.6: all values of illegal bins are excluded from
// coverage and are removed from the other bins after the values are
// distributed. If an illegal value occurs, a run-time error is issued, and
// illegal bins take precedence even when the value is also in another bin.
// Coverpoint bad has bins v = {2, 3} and illegal_bins b = {3}: after the
// removal the only value of v is 2, so before the illegal sample bad is 1/1.
// The error is caused by sampling 3, which is in both v and b; a tool that
// does not treat illegal bins as taking precedence reports no error there.
// The standard does not fix the form of the run-time error, such as a source
// location in it, so the messages of the run are checked only for an error.

module test_cg_illegal_value_error;
  bit [2:0] a;

  covergroup cg;
    ok: coverpoint a { bins v = {0}; }
    bad: coverpoint a {
      bins v = {2, 3};
      illegal_bins b = {3};
    }
  endgroup

  cg g = new;

  initial begin
    int c, t;
    a = 2;
    g.sample();
    void'(g.bad.get_inst_coverage(c, t));
    $display("before illegal");
    $display("bad %0d/%0d", c, t);
    a = 3;
    g.sample();
  end
endmodule

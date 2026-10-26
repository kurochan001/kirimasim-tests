/*
:name: test_illegal_cg_self_cross_other
:description: the enclosing cross identifier may denote all of its bin tuples, while another cross identifier shall not be used in a select expression (IEEE 1800-2023 Section 19.6.1.2)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.6.1.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the bin bad of cross X2 names X1, another cross of the covergroup
:expected_stderr_regex: test_illegal_cg_self_cross_other\.sv:30:
*/
// IEEE 1800-2023 §19.6.1.2: when a cross_identifier is used as a select
// expression, it selects all possible bin tuples, and only the identifier of
// the enclosing cross may be used; other cross identifiers are disallowed.
// Cross X1 uses its own name X1 for bin all, which is legal. Cross X2 uses
// X1 for bin bad, which is another cross and is the one error.

module test_illegal_cg_self_cross_other;
  bit [1:0] a, b;

  covergroup cg;
    ca: coverpoint a { bins v[] = {[0:1]}; }
    cb: coverpoint b { bins v[] = {[0:1]}; }
    X1: cross ca, cb {
      bins all = X1 with (1);
    }
    X2: cross ca, cb {
      bins bad = X1 with (1);   // illegal: another cross identifier
    }
  endgroup

  cg g = new;

  initial begin
    $display("not reached");
  end
endmodule

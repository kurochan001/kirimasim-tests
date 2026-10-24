/*
:name: test_illegal_replication_on_assignment_lhs
:description: an expression that contains a replication cannot be the left-hand side of an assignment, unlike a plain concatenation (IEEE 1800-2023 Section 11.4.12.1)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.4.12.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the left-hand side {b, {2{a}}} of the assignment contains the replication {2{a}}
:expected_stderr_regex: test_illegal_replication_on_assignment_lhs\.sv:27:
*/
// IEEE 1800-2023 §11.4.12.1: unlike regular concatenations, expressions that
// contain replications shall not appear on the left-hand side of an
// assignment. The concatenation {b, a} as a left-hand side and a replication
// on the right-hand side are legal; {b, {2{a}}} on the left is not.
// The design is accepted by the 5.052 release of Verilator.

module test_illegal_replication_on_assignment_lhs;
  logic a, b;
  logic [3:0] x;

  initial begin
    {b, a} = 2'b10;
    x = {2{b, a}};
    {b, {2{a}}} = 3'b101;   // illegal: a replication on the left-hand side
    $display("%b", x);
  end
endmodule

/*
:name: test_illegal_local_variable_unassigned_compound_assignment
:description: a local variable has to be assigned before it is updated with an assignment operator other than = (IEEE 1800-2023 Section 16.10)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the match item x += d of p_bad updates the local variable x before any assignment to it
:expected_stderr_regex: test_illegal_local_variable_unassigned_compound_assignment\.sv:(38|42):
*/
// IEEE 1800-2023 §16.10: a sequence or property shall assign a value to a
// local variable before the place where it is referenced, by an
// initialization assignment or an assignment attached to a subsequence; an
// increment, a decrement or an assignment operator other than = also
// references the variable, so the variable shall be assigned before it too.
// p_ok assigns y in a match item and then compares it, and p_init updates the
// initialized z with +=; p_bad updates x with +=, and nothing has assigned x.
// A tool can report the error in p_bad or at its assertion a_bad.
// Icarus Verilog 13.0 does not support concurrent assertions, and Verilator
// 5.052 accepts the design.

module test_illegal_local_variable_unassigned_compound_assignment;
  logic clk = 0, a = 0, b = 0, c = 0;
  int d = 0;
  property p_ok;
    int y;
    (a, y = d) ##1 (c == y);
  endproperty
  property p_init;
    int z = 0;
    (a, z += d) ##1 (c == z);
  endproperty
  property p_bad;
    int x;
    (a, x += d) ##1 (c == x);   // illegal
  endproperty
  a_ok: assert property (@(posedge clk) p_ok);
  a_init: assert property (@(posedge clk) p_init);
  a_bad: assert property (@(posedge clk) p_bad);
endmodule

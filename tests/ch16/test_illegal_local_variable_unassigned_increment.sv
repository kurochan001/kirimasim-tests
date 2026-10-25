/*
:name: test_illegal_local_variable_unassigned_increment
:description: a local variable has to be assigned before it is incremented (IEEE 1800-2023 Section 16.10)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.10
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the match item x++ of p_bad updates the local variable x before any assignment to it
:expected_stderr_regex: test_illegal_local_variable_unassigned_increment\.sv:(38|42):
*/
// IEEE 1800-2023 §16.10: a sequence or property shall assign a value to a
// local variable before the place where it is referenced, by an
// initialization assignment or an assignment attached to a subsequence; an
// increment, a decrement or an assignment operator other than = also
// references the variable, so the variable shall be assigned before it too.
// p_ok assigns y in a match item and then compares it, and p_init increments
// the initialized z; p_bad increments x, which nothing has assigned.
// A tool can report the error in p_bad or at its assertion a_bad.
// Icarus Verilog 13.0 does not support concurrent assertions, and Verilator
// 5.052 accepts the design.

module test_illegal_local_variable_unassigned_increment;
  logic clk = 0, a = 0, b = 0, c = 0;
  int d = 0;
  property p_ok;
    int y;
    (a, y = d) ##1 (c == y);
  endproperty
  property p_init;
    int z = 0;
    (a, z++) ##1 (c == z);
  endproperty
  property p_bad;
    int x;
    (a, x++) ##1 (c == x);   // illegal
  endproperty
  a_ok: assert property (@(posedge clk) p_ok);
  a_init: assert property (@(posedge clk) p_init);
  a_bad: assert property (@(posedge clk) p_bad);
endmodule

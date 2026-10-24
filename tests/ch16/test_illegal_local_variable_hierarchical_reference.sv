/*
:name: test_illegal_local_variable_hierarchical_reference
:description: a local variable of a sequence cannot be referenced by a hierarchical name (IEEE 1800-2023 Section 16.10)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the initial procedure references the local variable x of the sequence s by the hierarchical name s.x
:expected_stderr_regex: test_illegal_local_variable_hierarchical_reference\.sv:28:
*/
// IEEE 1800-2023 §16.10: hierarchical references to a local variable are not
// allowed. The sequence s declares and uses x, and the module asserts it;
// the initial procedure then reads s.x.
// Icarus Verilog 13.0 does not support concurrent assertions, and the 5.052
// release of Verilator stops with an internal error; neither counts.

module test_illegal_local_variable_hierarchical_reference;
  logic clk = 0, a = 0, b = 0, c = 0;
  int d = 0;
  sequence s;
    int x;
    (a, x = d) ##1 (c == x);
  endsequence
  a_s: assert property (@(posedge clk) s);
  initial $display("%0d", s.x);   // illegal
endmodule

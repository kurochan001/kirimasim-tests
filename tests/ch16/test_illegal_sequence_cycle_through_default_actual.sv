/*
:name: test_illegal_sequence_cycle_through_default_actual
:description: a default actual argument that instantiates a named sequence counts as a dependency for the cycle rule (IEEE 1800-2023 Section 16.8)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the default actual of the formal x of s3 instantiates s4, and s4 instantiates s3 in its declaration
:expected_stderr_regex: test_illegal_sequence_cycle_through_default_actual\.sv:(31|35|38):
*/
// IEEE 1800-2023 §16.8: in the graph of the cycle rule, a named sequence also
// depends on each one it instantiates in the declaration of a default actual
// argument. The default of x in s3 instantiates s4, and s4 instantiates s3
// with an explicit actual, so the two make a cycle although no instance
// uses the default. s5 uses s_leaf as its default, which is legal. A tool
// can report the error in either declaration or at the instance of s4.
// Icarus Verilog 13.0 does not support concurrent assertions, and Verilator
// 5.052 does not support default actual arguments; neither error counts.

module test_illegal_sequence_cycle_through_default_actual;
  logic clk = 0, a = 0, b = 0;
  sequence s_leaf;
    b ##1 a;
  endsequence
  sequence s5(x = s_leaf);
    a ##1 x;
  endsequence
  sequence s3(x = s4);   // illegal
    a ##1 x;
  endsequence
  sequence s4;
    a ##1 s3(b);
  endsequence
  p_s5: assert property (@(posedge clk) s5);
  p_s4: assert property (@(posedge clk) s4);
endmodule

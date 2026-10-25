/*
:name: test_illegal_sequence_cycle_through_bodies
:description: named sequences cannot depend on each other in a cycle through their declarations (IEEE 1800-2023 Section 16.8)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: s1 instantiates s2 in its declaration and s2 instantiates s1 in its declaration
:expected_stderr_regex: test_illegal_sequence_cycle_through_bodies\.sv:(32|35|38):
*/
// IEEE 1800-2023 §16.8: it shall be an error if the instantiations of named
// sequences make a cycle in the graph whose edges go from a named sequence
// to each one it instantiates in its declaration, or in an actual argument
// of one of its instances. s0 instantiates s_leaf, which is legal; s1
// instantiates s2 and s2 instantiates s1, a cycle. A tool can report the
// error in either declaration or at the instance of s1.
// Icarus Verilog 13.0 does not support concurrent assertions, and Verilator
// 5.052 stops with an internal fault; neither counts.

module test_illegal_sequence_cycle_through_bodies;
  logic clk = 0, a = 0, b = 0;
  sequence s_leaf;
    b ##1 a;
  endsequence
  sequence s0;
    a ##1 s_leaf;
  endsequence
  sequence s1;
    b ##1 s2;   // illegal
  endsequence
  sequence s2;
    a ##1 s1;
  endsequence
  p_s0: assert property (@(posedge clk) s0);
  p_s1: assert property (@(posedge clk) s1);
endmodule

/*
:name: test_illegal_local_variable_redeclares_formal
:description: a formal argument of a sequence used as a local variable cannot be declared again as a local variable (IEEE 1800-2023 Section 16.10)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the sequence s_bad declares a local variable lv with the name of its formal argument lv
:expected_stderr_regex: test_illegal_local_variable_redeclares_formal\.sv:28:
*/
// IEEE 1800-2023 §16.10: when a local variable is a formal argument of a
// sequence, declaring the variable in the sequence is illegal. s_ok assigns
// its formal lv, to which the local variable w of p_ok is bound, without
// declaring it; s_bad has the formal lv and declares lv as well.
// Icarus Verilog 13.0 does not support concurrent assertions, and Verilator
// 5.052 accepts the design.

module test_illegal_local_variable_redeclares_formal;
  logic clk = 0, a = 0, b = 0, c = 0;
  int d = 0;
  sequence s_ok(lv);
    (a, lv = d) ##1 (c == lv);
  endsequence
  sequence s_bad(lv);
    int lv;   // illegal
    (a, lv = d) ##1 (c == lv);
  endsequence
  property p_ok;
    int w;
    s_ok(w) ##1 (b == w);
  endproperty
  a_ok: assert property (@(posedge clk) p_ok);
endmodule

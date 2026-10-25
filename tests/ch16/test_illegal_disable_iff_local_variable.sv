/*
:name: test_illegal_disable_iff_local_variable
:description: a disable condition cannot reference a local variable of the property (IEEE 1800-2023 Section 16.6)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the disable condition of the property p_bad references its local variable k
:expected_stderr_regex: test_illegal_disable_iff_local_variable\.sv:32:
*/
// IEEE 1800-2023 §16.6: the expression of a disable condition is evaluated
// with the current values of variables and may use the sequence method
// triggered, but it shall not reference local variables or the method
// matched. a_trig uses s.triggered and a_rst the variable rst in their
// disable conditions, which is legal; p_bad, a property with the local
// variable k, references k in its disable condition.
// Icarus Verilog 13.0 does not support these assertions, and Verilator 5.052
// does not support the sequence methods; their errors do not count.

module test_illegal_disable_iff_local_variable;
  logic clk = 0, rst = 0, a = 0, b = 0;
  sequence s;
    @(posedge clk) a ##1 b;
  endsequence
  a_trig: assert property (@(posedge clk) disable iff (s.triggered) a |=> b);
  a_rst: assert property (@(posedge clk) disable iff (rst) a |=> b);
  property p_bad;
    int k;
    @(posedge clk) disable iff (k == 3) (a, k = 3) ##1 b;   // illegal
  endproperty
  a_bad: assert property (p_bad);
endmodule

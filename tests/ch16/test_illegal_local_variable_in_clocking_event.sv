/*
:name: test_illegal_local_variable_in_clocking_event
:description: a local variable can be used in expressions like a static variable, but not in a clocking event expression (IEEE 1800-2023 Section 16.10)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the clocking event of the second part of p_bad is posedge of the local variable c2
:expected_stderr_regex: test_illegal_local_variable_in_clocking_event\.sv:(35|38):
*/
// IEEE 1800-2023 §16.10: a local variable can be used to form expressions as
// a static variable of the same type can, including bit-selects, part-selects
// and array indices, but it shall not be used in a clocking event expression.
// p_ok uses the local variable k as the index of a bit-select and of an array
// element; p_bad uses the local variable c2 in a clocking event.
// A tool can report the error in p_bad or at its assertion a_bad.
// Icarus Verilog 13.0 does not support concurrent assertions, and Verilator
// 5.052 does not support a clocking event inside a property; neither error
// counts.

module test_illegal_local_variable_in_clocking_event;
  logic clk = 0, clk2 = 0, a = 0, b = 0;
  logic [3:0] v = 0;
  int arr [4];
  int d = 0;
  property p_ok;
    int k;
    (a, k = d) ##1 (v[k] && arr[k] == 0);
  endproperty
  property p_bad;
    logic c2;
    @(posedge clk) (a, c2 = clk2) ##1 @(posedge c2) b;   // illegal
  endproperty
  a_ok: assert property (@(posedge clk) p_ok);
  a_bad: assert property (p_bad);
endmodule

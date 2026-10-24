/*
:name: test_illegal_local_variable_implicit_type
:description: the data type of an assertion variable declaration has to be given explicitly (IEEE 1800-2023 Section 16.10)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the local variable x of p_bad is declared with var and no data type
:expected_stderr_regex: test_illegal_local_variable_implicit_type\.sv:33:
*/
// IEEE 1800-2023 §16.10: the data type of an assertion variable declaration
// shall be given explicitly and be one of the types allowed in assertions
// (16.6), followed by a list of one or more identifiers with optional
// declaration assignments, whose expressions need not be constant.
// p_ok declares int u = d + 1, whose initial value need not be constant, and
// logic v, w = a, a list of two variables; p_bad declares var x = a, which
// the grammar allows but which has no explicit data type.
// Icarus Verilog 13.0 does not support concurrent assertions, and Verilator
// 5.052 accepts the design.

module test_illegal_local_variable_implicit_type;
  logic clk = 0, a = 0, b = 0, c = 0;
  int d = 0;
  property p_ok;
    int u = d + 1;
    logic v, w = a;
    (b, v = w) ##1 (c == v) ##1 (d == u);
  endproperty
  property p_bad;
    var x = a;   // illegal
    a ##1 b;
  endproperty
  a_ok: assert property (@(posedge clk) p_ok);
  a_bad: assert property (@(posedge clk) p_bad);
endmodule

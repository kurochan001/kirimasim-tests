/*
:name: test_illegal_disable_iff_nested_through_instance
:description: A property with its own disable iff cannot be instantiated under another disable iff (IEEE 1800-2023 Section 16.12)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.12
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the disable iff of the assertion encloses the instance of p_in, whose body has its own disable iff
:expected_stderr_regex: test_illegal_disable_iff_nested_through_instance\.sv:29:
*/
// IEEE 1800-2023 §16.12: disable iff clauses shall not be nested, either
// directly or through property instances. p_in has a disable iff in its
// body, and the assertion puts its own disable iff in front of an instance
// of p_in. Each of the two properties alone would be legal.
// Icarus Verilog 13.0 does not support concurrent assertions, so the errors
// it reports here do not count.

module test_illegal_disable_iff_nested_through_instance;
  logic clk, clk2, a, b, r1, r2;
  int d, k;

  property p_in;
    @(posedge clk) disable iff (r2) a |=> b;
  endproperty

  a_nest: assert property (@(posedge clk) disable iff (r1) p_in);   // illegal: nested
endmodule

/*
:name: test_illegal_nettype_declares_variable
:description: A variable declared with a user-defined nettype is rejected (IEEE 1800-2023 Section 6.6.7)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.6.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: sum_t is a nettype, which can only be used to declare nets, but it is used in a variable declaration
:expected_stderr_regex: test_illegal_nettype_declares_variable\.sv:32:
*/
// IEEE 1800-2023 §6.6.7: a nettype names a data type and an optional
// resolution function, like a typedef, but shall only be used in declaring
// a net. The net n of nettype sum_t, driven by two continuous assignments,
// is legal; the declaration on the marked line uses sum_t for a variable
// (var), an error.
// Neither Icarus Verilog 13.0 nor Verilator 5.052 supports nettype
// declarations; both stop at the first of them, so their errors are not
// this rule.

module test_illegal_nettype_declares_variable;
  function automatic int sum_res(input int d[]);
    sum_res = 0;
    foreach (d[i]) sum_res += d[i];
  endfunction

  nettype int sum_t with sum_res;

  sum_t n;
  var sum_t v;   // illegal: a nettype in a variable declaration

  assign n = 2;
  assign n = 3;

  initial #1 $display("n=%0d", n);
endmodule

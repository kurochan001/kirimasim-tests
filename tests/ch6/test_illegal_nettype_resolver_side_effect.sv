/*
:name: test_illegal_nettype_resolver_side_effect
:description: A resolution function that writes a variable of the module, a side effect, is rejected (IEEE 1800-2023 Section 6.6.7)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.6.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the resolution function of the nettype writes the module variable calls, so it has a side effect
:expected_stderr_regex: test_illegal_nettype_resolver_side_effect\.sv:(33|39):
*/
// IEEE 1800-2023 §6.6.7: a resolution function shall be automatic (or keep
// no state) and shall have no side effects. sum_res writes only its own
// return variable and is a legal resolver; counting_res, the resolver of
// counting_t, also increments the module variable calls on the marked
// line, a side effect and an error, which can also be reported where
// counting_t names it as its resolver.
// Neither Icarus Verilog 13.0 nor Verilator 5.052 supports nettype
// declarations; both stop at the first of them, so their errors are not
// this rule.

module test_illegal_nettype_resolver_side_effect;
  int calls = 0;

  function automatic int sum_res(input int d[]);
    sum_res = 0;
    foreach (d[i]) sum_res += d[i];
  endfunction

  function automatic int counting_res(input int d[]);
    calls++;   // illegal: a side effect in a resolution function
    counting_res = 0;
    foreach (d[i]) counting_res += d[i];
  endfunction

  nettype int sum_t with sum_res;
  nettype int counting_t with counting_res;

  sum_t s;
  counting_t c;

  assign s = 2;
  assign s = 3;
  assign c = 4;
  assign c = 5;

  initial #1 $display("s=%0d c=%0d", s, c);
endmodule

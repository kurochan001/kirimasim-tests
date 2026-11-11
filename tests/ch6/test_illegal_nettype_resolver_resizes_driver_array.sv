/*
:name: test_illegal_nettype_resolver_resizes_driver_array
:description: A resolution function that resizes its driver array is rejected (IEEE 1800-2023 Section 6.6.7)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.6.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the resolution function of the nettype deletes the elements of its dynamic-array input argument
:expected_stderr_regex: test_illegal_nettype_resolver_resizes_driver_array\.sv:(32|36):
*/
// IEEE 1800-2023 §6.6.7: the resolution function of a nettype takes the
// values of the drivers in a dynamic array, and it shall not resize that
// input argument. sum_res only reads its array and is a legal resolver;
// first_res, the resolver of first_t, calls delete on the array on the
// marked line, an error, which can also be reported where first_t names it
// as its resolver.
// Neither Icarus Verilog 13.0 nor Verilator 5.052 supports nettype
// declarations; both stop at the first of them, so their errors are not
// this rule.

module test_illegal_nettype_resolver_resizes_driver_array;
  function automatic int sum_res(input int d[]);
    sum_res = 0;
    foreach (d[i]) sum_res += d[i];
  endfunction

  function automatic int first_res(input int d[]);
    first_res = (d.size() > 0) ? d[0] : 0;
    d.delete();   // illegal: resizes the driver array
  endfunction

  nettype int sum_t with sum_res;
  nettype int first_t with first_res;

  sum_t s;
  first_t f;

  assign s = 2;
  assign s = 3;
  assign f = 4;
  assign f = 5;

  initial #1 $display("s=%0d f=%0d", s, f);
endmodule

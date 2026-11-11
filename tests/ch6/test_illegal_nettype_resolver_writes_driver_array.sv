/*
:name: test_illegal_nettype_resolver_writes_driver_array
:description: A resolution function that writes an element of its driver array is rejected (IEEE 1800-2023 Section 6.6.7)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.6.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the resolution function of the nettype writes an element of its dynamic-array input argument
:expected_stderr_regex: test_illegal_nettype_resolver_writes_driver_array\.sv:(33|39):
*/
// IEEE 1800-2023 §6.6.7: the resolution function of a nettype takes the
// values of the drivers in a dynamic array, and it shall not write to any
// part of that input argument. sum_res only reads its array and is a legal
// resolver; clip_res, the resolver of clip_t, assigns to an element of the
// array on the marked line, an error, which can also be reported where
// clip_t names it as its resolver.
// Neither Icarus Verilog 13.0 nor Verilator 5.052 supports nettype
// declarations; both stop at the first of them, so their errors are not
// this rule.

module test_illegal_nettype_resolver_writes_driver_array;
  function automatic int sum_res(input int d[]);
    sum_res = 0;
    foreach (d[i]) sum_res += d[i];
  endfunction

  function automatic int clip_res(input int d[]);
    clip_res = 0;
    foreach (d[i]) begin
      if (d[i] > 9) d[i] = 9;   // illegal: writes the driver array
      clip_res += d[i];
    end
  endfunction

  nettype int sum_t with sum_res;
  nettype int clip_t with clip_res;

  sum_t s;
  clip_t c;

  assign s = 2;
  assign s = 30;
  assign c = 4;
  assign c = 30;

  initial #1 $display("s=%0d c=%0d", s, c);
endmodule

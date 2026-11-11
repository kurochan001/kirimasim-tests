/*
:name: test_illegal_nettype_resolver_return_type
:description: A nettype whose resolution function returns a type other than the data type of the nettype is rejected (IEEE 1800-2023 Section 6.6.7)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.6.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the resolution function wide_res returns longint, but the data type of the nettype is int
:expected_stderr_regex: test_illegal_nettype_resolver_return_type\.sv:(30|36):
*/
// IEEE 1800-2023 §6.6.7: the return type of the resolution function shall
// match the data type of the nettype; for a nettype of type T it returns T
// and takes a dynamic array of T. sum_res returns int and is a legal
// resolver of the int nettype sum_t; wide_res returns longint, so naming it
// as the resolver of the int nettype wide_t on the marked line is an error,
// which can also be reported at the header of wide_res.
// Neither Icarus Verilog 13.0 nor Verilator 5.052 supports nettype
// declarations; both stop at the first of them, so their errors are not
// this rule.

module test_illegal_nettype_resolver_return_type;
  function automatic int sum_res(input int d[]);
    sum_res = 0;
    foreach (d[i]) sum_res += d[i];
  endfunction

  function automatic longint wide_res(input int d[]);
    wide_res = 0;
    foreach (d[i]) wide_res += d[i];
  endfunction

  nettype int sum_t with sum_res;
  nettype int wide_t with wide_res;   // illegal: the resolver does not return int

  sum_t s;
  wide_t w;

  assign s = 2;
  assign s = 3;
  assign w = 4;
  assign w = 5;

  initial #1 $display("s=%0d w=%0d", s, w);
endmodule

/*
:name: test_illegal_nettype_unresolved_two_drivers
:description: A net of a nettype without a resolution function that has two continuous drivers is rejected (IEEE 1800-2023 Section 6.6.7)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.6.7 10.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the net r of the unresolved nettype raw_t has two continuous assignments as drivers
:expected_stderr_regex: test_illegal_nettype_unresolved_two_drivers\.sv:(36|41|42):
*/
// IEEE 1800-2023 §6.6.7: a nettype may be declared without a resolution
// function, and then it shall be an error for a net of that nettype to
// have multiple drivers. The net one of the unresolved nettype raw_t has
// a single driver and is legal, as is the net s of the resolved nettype
// sum_t with two drivers. The net r of raw_t has a second driver on the
// marked line, an error, which can also be reported at the declaration of
// r or at its first driver.
// Neither Icarus Verilog 13.0 nor Verilator 5.052 supports nettype
// declarations; both stop at the first of them, so their errors are not
// this rule.

module test_illegal_nettype_unresolved_two_drivers;
  function automatic int sum_res(input int d[]);
    sum_res = 0;
    foreach (d[i]) sum_res += d[i];
  endfunction

  nettype int sum_t with sum_res;
  nettype int raw_t;

  sum_t s;
  raw_t one;
  raw_t r;

  assign s = 2;
  assign s = 3;
  assign one = 6;
  assign r = 7;
  assign r = 8;   // illegal: a second driver of an unresolved net

  initial #1 $display("s=%0d one=%0d", s, one);
endmodule

/*
:name: test_illegal_continuous_assign_member_of_user_nettype
:description: a continuous assignment to a net of a user-defined nettype drives its whole value and cannot select a member of its data type (IEEE 1800-2023 Section 10.3.2)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.3.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the continuous assignment writes the member lo of the net pn_bad of the user-defined nettype pair_net
:expected_stderr_regex: test_illegal_continuous_assign_member_of_user_nettype\.sv:34:
*/
// IEEE 1800-2023 §10.3.2: a continuous assignment to an atomic net shall drive
// the entire nettype value, so its left-hand side shall not select into the
// data type of a user-defined nettype. pn_ok is driven as a whole, which is
// legal; the assignment to pn_bad selects its member lo.
// Icarus Verilog 13.0 gives a syntax error at the nettype declaration, and
// the 5.052 release of Verilator reports nettype as unsupported, so neither
// error counts.

typedef struct packed {
  logic [3:0] hi;
  logic [3:0] lo;
} pair_t;

nettype pair_t pair_net;

module test_illegal_continuous_assign_member_of_user_nettype;
  pair_t pv = '{hi: 4'h1, lo: 4'h2};
  pair_net pn_ok, pn_bad;

  assign pn_ok = pv;
  assign pn_bad.lo = 4'h3;   // illegal: selects a member of the nettype value

  initial #1 $display("%h", pn_ok);
endmodule

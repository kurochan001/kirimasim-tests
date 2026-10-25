/*
:name: test_illegal_alias_given_twice
:description: the same alias cannot be specified more than once, although the same nets can appear in several alias statements (IEEE 1800-2023 Section 10.11)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.11
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the alias of the nets p and q is given by two alias statements
:expected_stderr_regex: test_illegal_alias_given_twice\.sv:(29|30):
*/
// IEEE 1800-2023 §10.11: the same nets can appear in several alias statements,
// with cumulative effects, but a given alias shall not be specified more than
// once. The net s appears in two alias statements, with r and with t, which
// is legal; the alias of p and q is given twice. A tool can report either
// statement.
// Icarus Verilog 13.0 does not parse alias statements.
// The 5.052 release of Verilator also rejects the legal second alias
// statement of s, so its error does not count.

module test_illegal_alias_given_twice;
  wire r, s, t;
  wire p, q;

  alias r = s;
  alias s = t;
  alias p = q;   // (or reported here)
  alias p = q;   // illegal: the same alias a second time

  assign r = 1'b1;
  initial #1 $display("%b %b", s, t);
endmodule

/*
:name: test_illegal_alias_hierarchical_reference
:description: a hierarchical reference cannot be a member of an alias statement (IEEE 1800-2023 Section 10.11)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.11
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the alias statement names u_sub.n, a net of another instance reached through a hierarchical reference
:expected_stderr_regex: test_illegal_alias_hierarchical_reference\.sv:30:
*/
// IEEE 1800-2023 §10.11: variables and hierarchical references cannot be used
// in alias statements, and a violation is a fatal error. The nets a and b of
// the module are aliased, which is legal; the net n of the instance u_sub is
// named through the hierarchical reference u_sub.n.
// Icarus Verilog 13.0 does not parse alias statements.

module sub_m;
  wire n;
endmodule

module test_illegal_alias_hierarchical_reference;
  wire a, b;
  wire w;

  sub_m u_sub ();
  alias a = b;
  alias w = u_sub.n;   // illegal: a hierarchical reference

  assign a = 1'b1;
  initial #1 $display("%b", b);
endmodule

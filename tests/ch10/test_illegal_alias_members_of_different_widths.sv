/*
:name: test_illegal_alias_members_of_different_widths
:description: the members of an alias statement have to have the same number of bits (IEEE 1800-2023 Section 10.11)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.11
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the alias statement joins the 8-bit net x8 and the 4-bit net n4
:expected_stderr_regex: test_illegal_alias_members_of_different_widths\.sv:29:
*/
// IEEE 1800-2023 §10.11: the bits of the members of an alias statement are
// overlaid as for a packed union, so each member shall have the same size;
// a violation is a fatal error. w8 aliased to the concatenation of two 4-bit
// nets is legal; x8 aliased to the 4-bit n4 is not.
// Icarus Verilog 13.0 does not parse alias statements.
// The 5.052 release of Verilator reports the legal alias of a concatenation
// as unsupported, so its error does not count.

module test_illegal_alias_members_of_different_widths;
  wire [7:0] w8;
  wire [3:0] hi4, lo4;
  wire [7:0] x8;
  wire [3:0] n4;

  alias w8 = {hi4, lo4};
  alias x8 = n4;   // illegal: 8 bits and 4 bits

  assign w8 = 8'h5a;
  initial #1 $display("%h %h", hi4, lo4);
endmodule

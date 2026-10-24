/*
:name: test_illegal_charge_strength_in_tri_declaration
:description: a charge strength in a net declaration is allowed only with the trireg keyword, so a tri declaration cannot have one (IEEE 1800-2023 Section 6.7)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:should_fail_because: the tri net t is declared with the charge strength medium
:expected_stderr_regex: test_illegal_charge_strength_in_tri_declaration\.sv:29:
*/
// IEEE 1800-2023 §6.7 (Syntax 6-2, footnote 16): a charge strength (small,
// medium or large) shall be used only when the net type keyword is trireg.
// The trireg nets ts, with the charge strength small, and tv, a 4-bit vector
// with large, are legal, and the legal design prints their sizes: 1 4. The tri
// net t is declared with the charge strength medium.
// Icarus Verilog 13.0 reports the trireg nets as not supported (a message that
// is not an error) and rejects the charge strength of the tri declaration with
// a syntax error on its line, as its grammar accepts a charge strength only
// after trireg. The 5.052 release reports trireg as not supported and rejects
// every charge strength, also on the trireg nets, so its errors do not count.

module test_illegal_charge_strength_in_tri_declaration;
  trireg (small) ts;
  trireg (large) [3:0] tv;
  initial $display("%0d %0d", $bits(ts), $bits(tv));
  tri (medium) t;   // illegal: charge strength on a tri net
endmodule

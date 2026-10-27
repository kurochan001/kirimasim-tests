/*
:name: test_34_extra_nested_envelopes
:description: An end_protected closes the most recent open envelope, so decryption envelopes nest, and eight nested pairs are accepted, the minimum depth an implementation shall support (IEEE 1800-2023 Section 34.2)
:tags: ch34
:type: simulation
:lrm: 1800-2023 34.2 34.4 34.5.3.1 34.5.4.1 34.5.3.2 34.5.4.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_34_extra_nested_envelopes.expected
*/
// IEEE 1800-2023 §34.2: end_protected closes the envelope of the most recent
// begin_protected that is still open, and an implementation shall support at
// least eight levels of nesting. The design opens eight envelopes and closes
// them in the reverse order, then elaborates a design after the outermost
// close. Both simulators accept the file with the eight levels and run the
// design.
// The nesting that §34.2 describes is that of envelopes whose contents are
// encrypted: an encryptor produces such a file, and a decrypting tool must
// recover the nested envelopes from the decrypted bytes (§34.3.2). Neither
// simulator here decrypts anything (Icarus Verilog 13.0 ignores every
// `pragma protect line; Verilator 5.052 only drops data_block and key_block
// bytes), so this test observes the delimiter depth the tools tolerate, not
// the nesting of encrypted envelopes. Each pair is empty for that reason.

module test_34_extra_nested_envelopes;
  `pragma protect begin_protected
  `pragma protect begin_protected
  `pragma protect begin_protected
  `pragma protect begin_protected
  `pragma protect begin_protected
  `pragma protect begin_protected
  `pragma protect begin_protected
  `pragma protect begin_protected
  `pragma protect end_protected
  `pragma protect end_protected
  `pragma protect end_protected
  `pragma protect end_protected
  `pragma protect end_protected
  `pragma protect end_protected
  `pragma protect end_protected
  `pragma protect end_protected

  initial $display("nested envelope levels: 8");
endmodule

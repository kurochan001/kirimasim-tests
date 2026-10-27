/*
:name: test_34_extra_envelope_keywords
:description: begin_protected and end_protected are bare protect keywords that open and close a decryption envelope, and a pair with no content pragmas is accepted (IEEE 1800-2023 Sections 34.5.3.1 and 34.5.4.1)
:tags: ch34
:type: simulation
:lrm: 1800-2023 34.5.3.1 34.5.4.1 34.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_34_extra_envelope_keywords.expected
*/
// IEEE 1800-2023 §34.5.3.1, §34.5.4.1: begin_protected opens a decryption
// envelope and end_protected closes one, and each is a bare protect keyword,
// written without an argument. The design writes an empty pair between two
// localparam declarations. Both simulators accept the file and elaborate the
// declarations on either side (Icarus ignores the lines, Verilator recognises
// them and drops nothing, since the pair is empty).
// Neither simulator decrypts anything here. Icarus Verilog 13.0 ignores
// every `pragma protect line, so its run shows only that the line is legal
// text it ignores; Verilator 5.052 rejects `pragma protect begin_protected
// with an argument ("Unknown '`pragma protect' error") and removes only the
// bytes of a data_block or key_block, so its run shows that the bare keyword
// is recognized. An empty pair does not show that a protected region was
// decrypted, and neither run does.

module test_34_extra_envelope_keywords;
  localparam int unsigned FIRST = 6;
  `pragma protect begin_protected
  `pragma protect end_protected
  localparam int unsigned SECOND = 7;

  initial $display("envelope keywords: %0d", FIRST + SECOND);
endmodule

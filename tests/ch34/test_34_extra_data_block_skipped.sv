/*
:name: test_34_extra_data_block_skipped
:description: A data_block introduces the encoded encrypted body on the line after the directive, and Verilator 5.052 removes those bytes from the source before analysis (IEEE 1800-2023 Sections 34.5.15.2 and 34.5.9.2)
:tags: ch34
:type: simulation
:lrm: 1800-2023 34.5.15.2 34.5.9.2 34.2 34.5.3.1 34.5.4.1 34.5.4.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_34_extra_data_block_skipped.expected
*/
// IEEE 1800-2023 §34.5.15.2: data_block begins on the next line, and the
// content of the begin-end region is encrypted, encoded and written there.
// §34.5.9.2: encoding names the binary-to-text representation, and bytes is
// the count of the original data. The file below holds an envelope whose body
// is 24 arbitrary bytes written as 32 base64 characters on the line after
// `pragma protect data_block, with encoding=(enctype="base64",
// line_length=76, bytes=24).
// Here Verilator 5.052 consumes exactly those 24 bytes, warns that the
// encrypted section is skipped, and then elaborates and runs the module that
// follows, so the payload was not read as source-language text: a bare
// 32-character identifier there would otherwise be a syntax error. The bytes
// are not a ciphertext of any design text and nothing is decrypted, so this
// test does not show that a protected body can be recovered; it shows only
// where the encoded body sits and that the tool excludes it from analysis.
// Icarus Verilog 13.0 treats the base64 line as source and rejects the file
// ("syntax error" at the payload line), so the expected output is the one
// that Verilator 5.052 produces.

`pragma protect encoding=(enctype="base64", line_length=76, bytes=24)
`pragma protect begin_protected
`pragma protect data_block
QUJDREVGR0hJSktMTU5PUFFSU1RVVldY
`pragma protect end_protected

module test_34_extra_data_block_skipped;
  localparam int unsigned BODY_BYTES = 24;

  initial $display("data_block skipped, bytes=%0d", BODY_BYTES);
endmodule

/*
:name: test_34_extra_include_envelope
:description: The scope of a protect directive is lexical, so a decryption envelope may begin in an included file and end in the file that includes it (IEEE 1800-2023 Section 34.4)
:tags: ch34
:type: simulation
:lrm: 1800-2023 34.4 22.4 34.5.3.2 34.5.15.2 34.5.3.1 34.5.4.1 34.5.9.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:incdirs: ch34_include
:expected_stdout: @test_34_extra_include_envelope.expected
*/
// IEEE 1800-2023 §34.4: the scope of a protect directive is lexical and is
// not tied to a declaration, so it may cross file and `include boundaries.
// §34.5.3.2, §34.5.15.2: begin_protected starts the encrypted region and the
// bytes of its data_block follow on the next line.
// The included file ch34_include/lexical_env.svh writes begin_protected, the
// encoding and a 24-byte base64 data_block but no end_protected; this file
// writes end_protected after the `include and then the design. Verilator
// 5.052 carries the envelope state and the remaining base64 byte count
// across the end of the included file: it consumes the 24 bytes there, takes
// the end_protected written here as the close of that envelope, and runs the
// module. If the state had stopped at the file boundary, the base64 line
// would have been read as source and the file would not have compiled.
// Nothing is decrypted, and the bytes are not a ciphertext of any design
// text, so this shows the lexical extent of the directive, not the recovery
// of protected content. Icarus Verilog 13.0 ignores every `pragma protect
// line and reads the base64 line as source, so it rejects the file and the
// expected output is the one Verilator 5.052 produces.

`include "lexical_env.svh"
`pragma protect end_protected

module test_34_extra_include_envelope;
  localparam int unsigned BODY_BYTES = 24;

  initial $display("cross-file envelope, bytes=%0d", BODY_BYTES);
endmodule

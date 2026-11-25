/*
:name: test_protect_digests_authenticate_key_and_data
:description: protect digest requests with default and explicit digest keys
:tags: ch34
:type: simulation
:lrm: 1800-2023 34.4 34.5.16.2 34.5.17.2 34.5.18.2 34.5.21.2 34.5.22.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_protect_digests_authenticate_key_and_data
:expected_stdout: digest bodies=39,72
*/
`timescale 1ns/1ns
`pragma protect data_method = "aes256-cbc"
`pragma protect digest_method = "sha1"
`pragma protect encoding = (enctype="base64")

module protect_digest_default(output wire [7:0] result);
`pragma protect begin
`ifdef PROTECT_DIGEST_ENCRYPTION_INPUT
`pragma protect digest_block
`endif
assign result = 8'h39;
`pragma protect end
endmodule

module protect_digest_explicit(output wire [7:0] result);
`pragma protect begin
`ifdef PROTECT_DIGEST_ENCRYPTION_INPUT
`pragma protect digest_key_method = "aes128-cbc"
`pragma protect digest_keyowner = "Digest Fixture"
`pragma protect digest_keyname = "digest-aes128"
`pragma protect encoding = (enctype="uuencode")
`pragma protect digest_block
`endif
assign result = 8'h72;
`pragma protect end
endmodule

module test_protect_digests_authenticate_key_and_data;
  wire [7:0] first, second;
  protect_digest_default a(first);
  protect_digest_explicit b(second);
  initial begin
    #1 $display("digest bodies=%h,%h", first, second);
    $finish;
  end
endmodule

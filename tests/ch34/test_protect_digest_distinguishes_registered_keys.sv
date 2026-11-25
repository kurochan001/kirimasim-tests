/*
:name: test_protect_digest_distinguishes_registered_keys
:description: protect digest authentication with distinct registered owners and key names
:tags: ch34
:type: simulation
:lrm: 1800-2023 34.4 34.5.16.2 34.5.17.2 34.5.18.2 34.5.21.2 34.5.22.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_protect_digest_distinguishes_registered_keys
:expected_stdout: digest registered=2b,58
*/
`timescale 1ns/1ns
`pragma protect data_method = "aes256-cbc"
`pragma protect digest_method = "sha1"
`pragma protect encoding = (enctype="base64")

module protect_digest_backup(output wire [7:0] result);
`pragma protect begin
`ifdef PROTECT_DIGEST_ENCRYPTION_INPUT
`pragma protect digest_key_method = "aes128-cbc"
`pragma protect digest_keyowner = "Digest Fixture"
`pragma protect digest_keyname = "digest-backup"
`pragma protect digest_block
`endif
assign result = 8'h2b;
`pragma protect end
endmodule

module protect_digest_other_owner(output wire [7:0] result);
`pragma protect begin
`ifdef PROTECT_DIGEST_ENCRYPTION_INPUT
`pragma protect digest_key_method = "aes128-cbc"
`pragma protect digest_keyowner = "Other Digest Fixture"
`pragma protect digest_keyname = "digest-aes128"
`pragma protect encoding = (enctype="uuencode")
`pragma protect digest_block
`endif
assign result = 8'h58;
`pragma protect end
endmodule

module test_protect_digest_distinguishes_registered_keys;
  wire [7:0] first, second;
  protect_digest_backup a(first);
  protect_digest_other_owner b(second);
  initial begin
    #1 $display("digest registered=%h,%h", first, second);
    $finish;
  end
endmodule

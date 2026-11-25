/*
:name: test_protect_author_digest_wraps_explicit_key
:description: Author ciphertext with a digest key distinct from the data key
:tags: ch34
:type: simulation
:lrm: 1800-2023 34.5.11.2 34.5.14.2 34.5.20.2 34.5.27.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_protect_author_digest_wraps_explicit_key
:expected_stdout: author digest explicit=9b
*/
`timescale 1ns/1ns
`pragma protect data_method = "aes256-cbc"
`pragma protect digest_method = "sha1"
`pragma protect digest_key_method = "aes128-cbc"
`pragma protect encoding=(enctype="base64")
`pragma protect begin
module protect_author_explicit_payload(output wire [7:0] value);
  assign value = 8'h9b;
endmodule
`pragma protect end

module test_protect_author_digest_wraps_explicit_key;
  wire [7:0] value;
  protect_author_explicit_payload payload(value);
  initial begin
    #1 $display("author digest explicit=%02h", value);
    $finish;
  end
endmodule

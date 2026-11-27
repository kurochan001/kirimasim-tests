/*
:name: test_protect_digest_metadata_placement
:description: Digest metadata changes placement between unsigned and signed protected envelopes
:tags: ch34
:type: simulation
:lrm: 1800-2023 34.5.16.2 34.5.17.2 34.5.18.2 34.5.21.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_protect_digest_metadata_placement
:expected_stdout: digest metadata payload=6d
*/
`timescale 1ns/1ns
`pragma protect data_method = "aes256-cbc"
`pragma protect digest_keyowner = "Fixture East"
`pragma protect digest_keyname = "assembly"
`pragma protect digest_key_method = "aes128-cbc"
`pragma protect digest_method = "md5"
`pragma protect encoding = (enctype="base64")
`pragma protect begin
module protect_digest_metadata_payload(output wire [7:0] value);
  assign value = 8'h6d;
endmodule
`pragma protect end

module test_protect_digest_metadata_placement;
  wire [7:0] value;
  protect_digest_metadata_payload payload(value);
  initial begin
    #1 $display("digest metadata payload=%02h", value);
    $finish;
  end
endmodule

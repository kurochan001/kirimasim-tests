/*
:name: test_protect_recipients_reject_changed_body_key_metadata
:description: An alternate recipient cannot change the body's decryption metadata
:tags: ch34
:type: simulation
:lrm: 1800-2023 34.5.10.2 34.5.12.2 34.5.23.2 34.5.24.2 34.5.27.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_protect_recipients_reject_changed_body_key_metadata
:expected_stdout: recipient metadata=a6
*/
`timescale 1ns/1ns
`pragma protect author = "Fixture HDL Author"
`pragma protect data_method = "aes128-cbc"
`pragma protect data_keyowner = "Fixture Archive"
`pragma protect data_keyname = "nightly"
`pragma protect key_method = "aes128-cbc"
`pragma protect key_keyowner = "Fixture West"
`pragma protect key_keyname = "delivery"
`pragma protect encoding = (enctype="base64")
// Alternate exchange recipient
`pragma protect key_method = "rsa"
`pragma protect key_keyowner = "Fixture East"
`pragma protect key_keyname = "delivery"
`pragma protect encoding = (enctype="uuencode")
`pragma protect begin
module protect_metadata_recipient_body(output wire [7:0] value);
  assign value = 8'h5a ^ 8'hfc;
endmodule
`pragma protect end

module test_protect_recipients_reject_changed_body_key_metadata;
  wire [7:0] value;
  protect_metadata_recipient_body body(value);
  initial begin
    #1 $display("recipient metadata=%02h", value);
    $finish;
  end
endmodule

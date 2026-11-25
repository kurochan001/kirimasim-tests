/*
:name: test_protect_recipients_wrap_the_same_body_key
:description: Two named recipients wrap identical data keys using different methods
:tags: ch34
:type: simulation
:lrm: 1800-2023 34.5.10.2 34.5.12.2 34.5.23.2 34.5.24.2 34.5.27.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_protect_recipients_wrap_the_same_body_key
:expected_stdout: recipient shared=36,49
*/
`timescale 1ns/1ns
`pragma protect author = "Fixture HDL Author"
`pragma protect data_method = "aes256-cbc"
`pragma protect data_keyowner = "Fixture Data"
`pragma protect data_keyname = "design"
`pragma protect key_method = "rsa"
`pragma protect key_keyowner = "Fixture East"
`pragma protect key_keyname = "delivery"
`pragma protect encoding = (enctype="base64")
// Alternate exchange recipient
`pragma protect key_method = "aes128-cbc"
`pragma protect key_keyowner = "Fixture West"
`pragma protect key_keyname = "delivery"
`pragma protect encoding = (enctype="uuencode")
`pragma protect begin
module protect_shared_recipient_body(output wire [7:0] left, right);
  assign left = 8'h36;
  assign right = left + 8'h13;
endmodule
`pragma protect end

module test_protect_recipients_wrap_the_same_body_key;
  wire [7:0] left, right;
  protect_shared_recipient_body body(left, right);
  initial begin
    #1 $display("recipient shared=%02h,%02h", left, right);
    $finish;
  end
endmodule

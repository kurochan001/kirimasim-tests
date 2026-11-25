/*
:name: test_protect_public_key_roles_remain_separate_between_envelopes
:description: Separate data digest and exchange keys in adjacent envelopes
:tags: ch34
:type: simulation
:lrm: 1800-2023 34.5.10.2 34.5.12.2 34.5.13.2 34.5.19.2 34.5.25.2 34.5.26.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_protect_public_key_roles_remain_separate_between_envelopes
:expected_stdout: public adjacent=64,af
*/
`timescale 1ns/1ns
`pragma protect encoding = (enctype="base64")
`pragma protect data_method = "rsa"
`pragma protect data_keyowner = "Fixture West"
`pragma protect data_keyname = "assembly"
`pragma protect digest_key_method = "rsa"
`pragma protect digest_keyowner = "Fixture East"
`pragma protect digest_keyname = "backup"
`pragma protect digest_method = "sha1"
`pragma protect begin
module protect_owner_direct(output wire [7:0] value);
  assign value = 8'h64;
endmodule
`pragma protect end

`pragma protect encoding = (enctype="uuencode")
`pragma protect data_method = "aes256-cbc"
`pragma protect key_method = "rsa"
`pragma protect key_keyowner = "Fixture East"
`pragma protect key_keyname = "assembly"
`pragma protect begin
module protect_owner_wrapped(output wire [7:0] value);
  assign value = 8'haf;
endmodule
`pragma protect end

module test_protect_public_key_roles_remain_separate_between_envelopes;
  wire [7:0] direct, wrapped;
  protect_owner_direct a(direct);
  protect_owner_wrapped b(wrapped);
  initial begin
    #1 $display("public adjacent=%02h,%02h", direct, wrapped);
    $finish;
  end
endmodule

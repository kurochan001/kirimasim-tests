/*
:name: test_protect_exchange_public_key_matches_owner_and_name
:description: Exchange public key selection for a wrapped data encryption key
:tags: ch34
:type: simulation
:lrm: 1800-2023 34.4 34.5.25.2 34.5.26.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_protect_exchange_public_key_matches_owner_and_name
:expected_stdout: public exchange=b2
*/
`timescale 1ns/1ns
`pragma protect data_method = "aes256-cbc"
`pragma protect key_method = "rsa"
`pragma protect key_keyowner = "Fixture West"
`pragma protect key_keyname = "assembly"
`pragma protect encoding = (enctype="base64")
`pragma protect begin
module protect_owner_exchange(output wire [7:0] value);
  assign value = 8'hb2;
endmodule
`pragma protect end

module test_protect_exchange_public_key_matches_owner_and_name;
  wire [7:0] value;
  protect_owner_exchange u(value);
  initial begin
    #1 $display("public exchange=%02h", value);
    $finish;
  end
endmodule

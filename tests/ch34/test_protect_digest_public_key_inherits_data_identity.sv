/*
:name: test_protect_digest_public_key_inherits_data_identity
:description: Explicit digest public keys and inheritance from the data key
:tags: ch34
:type: simulation
:lrm: 1800-2023 34.4 34.5.16.2 34.5.18.2 34.5.19.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_protect_digest_public_key_inherits_data_identity
:expected_stdout: public digest=79
*/
`timescale 1ns/1ns
`pragma protect author = "Fixture HDL Author"
`pragma protect data_method = "rsa"
`pragma protect data_keyowner = "Fixture East"
`pragma protect data_keyname = "assembly"
`pragma protect digest_method = "sha1"
`pragma protect digest_key_method = "rsa"
`pragma protect digest_keyowner = "Fixture West"
`pragma protect digest_keyname = "assembly"
`pragma protect encoding = (enctype="uuencode")
`pragma protect begin
module protect_owner_digest(output wire [7:0] value);
  assign value = 8'h79;
endmodule
`pragma protect end

module test_protect_digest_public_key_inherits_data_identity;
  wire [7:0] value;
  protect_owner_digest u(value);
  initial begin
    #1 $display("public digest=%02h", value);
    $finish;
  end
endmodule

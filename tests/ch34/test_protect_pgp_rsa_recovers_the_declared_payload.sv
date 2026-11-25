/*
:name: test_protect_pgp_rsa_recovers_the_declared_payload
:description: OpenPGP RSA protects a body with separate author and encryptor metadata
:tags: ch34
:type: simulation
:lrm: 1800-2023 34.4 34.5.5.2 34.5.6.2 34.5.8.2 34.5.11.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_protect_pgp_rsa_recovers_the_declared_payload
:expected_stdout: protect pgp rsa=2d,5a
*/
`timescale 1ns/1ns
`pragma protect data_method = "pgp-rsa"
`pragma protect encoding = (enctype="base64")
`pragma protect author = "Outside author A"
`pragma protect author_info = "Outside note A"
`pragma protect begin
`pragma protect author = "Protected author PGP"
`pragma protect author_info = "Protected note PGP"
// author=ordinary HDL comment; author_info=untouched
module protect_pgp_payload(output wire [7:0] left, right);
  assign left = 8'h2d;
  assign right = left << 1;
endmodule
`pragma protect end

module test_protect_pgp_rsa_recovers_the_declared_payload;
  wire [7:0] left, right;
  protect_pgp_payload payload(left, right);
  initial begin
    #1 $display("protect pgp rsa=%02h,%02h", left, right);
    $finish;
  end
endmodule

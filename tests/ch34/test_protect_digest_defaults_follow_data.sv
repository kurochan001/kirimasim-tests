/*
:name: test_protect_digest_defaults_follow_data
:description: Omitted digest settings inherit the current data settings
:tags: ch34
:type: simulation
:lrm: 1800-2023 34.4 34.5.16.2 34.5.17.2 34.5.18.2 34.5.19.2 34.5.20.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_protect_digest_defaults_follow_data
:expected_stdout: digest defaults=18,26,37,4b
*/
`timescale 1ns/1ns

`pragma protect encoding = (enctype="base64")
`pragma protect data_method = "aes128-cbc"
`pragma protect digest_method = "sha1"
`pragma protect begin
module digest_default_first(output wire [7:0] value);
  assign value = 8'h18;
endmodule
`pragma protect end

`pragma protect reset
`pragma protect encoding = (enctype="uuencode")
`pragma protect data_method = "aes256-cbc"
`pragma protect digest_method = "md5"
`pragma protect begin
module digest_default_second(output wire [7:0] value);
  assign value = 8'h26;
endmodule
`pragma protect end

`pragma protect reset
`pragma protect encoding = (enctype="base64")
`pragma protect data_method = "rsa"
`pragma protect data_keyowner = "Fixture East"
`pragma protect data_keyname = "assembly"
`pragma protect digest_method = "sha1"
`pragma protect begin
module digest_default_third(output wire [7:0] value);
  assign value = 8'h37;
endmodule
`pragma protect end

`pragma protect reset
`pragma protect encoding = (enctype="uuencode")
`pragma protect data_method = "rsa"
`pragma protect data_keyowner = "Fixture West"
`pragma protect data_keyname = "backup"
`pragma protect digest_method = "md5"
`pragma protect begin
module digest_default_fourth(output wire [7:0] value);
  assign value = 8'h4b;
endmodule
`pragma protect end

module test_protect_digest_defaults_follow_data;
  wire [7:0] first, second, third, fourth;
  digest_default_first u0(first);
  digest_default_second u1(second);
  digest_default_third u2(third);
  digest_default_fourth u3(fourth);
  initial begin
    #1 $display("digest defaults=%02h,%02h,%02h,%02h", first, second, third, fourth);
    $finish;
  end
endmodule

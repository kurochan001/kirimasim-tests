/*
:name: test_protect_key_values_unique_within_owner
:description: Protection key names and material are unique within each key owner
:tags: ch34
:type: simulation
:lrm: 1800-2023 34.5.10.2 34.5.16.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_protect_key_values_unique_within_owner
:expected_stdout: owner keys=21,56,9a
*/
`timescale 1ns/1ns

`pragma protect data_keyowner = "Fixture East", data_keyname = "assembly"
`pragma protect digest_keyowner = "Fixture West", digest_keyname = "signing"
`pragma protect begin
module owner_first(output wire [7:0] value);
  assign value = 8'h21;
endmodule
`pragma protect end

`pragma protect reset
`pragma protect data_keyowner = "Fixture East", data_keyname = "backup"
`pragma protect digest_keyowner = "Fixture West", digest_keyname = "archive"
`pragma protect begin
module owner_second(output wire [7:0] value);
  assign value = 8'h56;
endmodule
`pragma protect end

`pragma protect reset
`pragma protect data_keyowner = "Fixture West", data_keyname = "assembly"
`pragma protect digest_keyowner = "Fixture East", digest_keyname = "signing"
`pragma protect begin
module owner_third(output wire [7:0] value);
  assign value = 8'h9a;
endmodule
`pragma protect end

module test_protect_key_values_unique_within_owner;
  wire [7:0] first, second, third;
  owner_first u0(first);
  owner_second u1(second);
  owner_third u2(third);
  initial begin
    #1 $display("owner keys=%02h,%02h,%02h", first, second, third);
    $finish;
  end
endmodule

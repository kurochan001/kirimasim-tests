/*
:name: test_protect_data_public_key_matches_owner_and_name
:description: Data key selection with equal aliases under different owners
:tags: ch34
:type: simulation
:lrm: 1800-2023 34.4 34.5.10.2 34.5.11.2 34.5.12.2 34.5.13.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_protect_data_public_key_matches_owner_and_name
:expected_stdout: public data=3d,18
*/
`timescale 1ns/1ns
`pragma protect author = "Fixture HDL Author"
`pragma protect data_method = "rsa"
`pragma protect data_keyowner = "Fixture East"
`pragma protect data_keyname = "assembly"
`pragma protect encoding = (enctype="base64")
`pragma protect begin
module protect_owner_data(output wire [7:0] value, output wire [7:0] check);
  assign value = 8'h3d;
  assign check = value ^ 8'h25;
endmodule
`pragma protect end

module test_protect_data_public_key_matches_owner_and_name;
  wire [7:0] value, check;
  protect_owner_data u(value, check);
  initial begin
    #1 $display("public data=%02h,%02h", value, check);
    $finish;
  end
endmodule

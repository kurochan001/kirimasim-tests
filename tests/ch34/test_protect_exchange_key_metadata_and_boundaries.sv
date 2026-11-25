/*
:name: test_protect_exchange_key_metadata_and_boundaries
:description: protect envelope boundaries, exchange key identifiers, and the independently decrypted contents
:tags: ch34
:type: simulation
:lrm: 1800-2023 34.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_protect_exchange_key_metadata_and_boundaries
:expected_stdout: first=a5 second=3c third=5d
*/
`timescale 1ns/1ns
`pragma protect data_method = "aes256-cbc"
`pragma protect encoding = (enctype="base64", line_length=32)

module protect_exchange_first(output wire [7:0] value);
  assign value[7:4] = 4'ha;
`pragma protect begin
`pragma protect author = "Fixture Author East"
`pragma protect author_info = "Fixture edition A"
`pragma protect comment = "literal note A: data_block"
  assign value[3:0] = 4'h5;
endmodule

module protect_exchange_second(output wire [7:0] value);
  assign value[7:4] = 4'h3;
`pragma protect end
  assign value[3:0] = 4'hc;
endmodule

`pragma protect data_method = "aes128-cbc"
`pragma protect encoding = (enctype="uuencode", line_length=64)
`pragma protect begin
`pragma protect author = "Fixture Author West"
`pragma protect author_info = "Fixture edition B"
`pragma protect comment = "literal note B: end_protected"
module protect_exchange_third(output wire [7:0] value);
  assign value = 8'h5d;
endmodule
`pragma protect end

module test_protect_exchange_key_metadata_and_boundaries;
  wire [7:0] first, second, third;
  protect_exchange_first a(first);
  protect_exchange_second b(second);
  protect_exchange_third c(third);
  initial begin
    #1 $display("first=%h second=%h third=%h", first, second, third);
    $finish;
  end
endmodule

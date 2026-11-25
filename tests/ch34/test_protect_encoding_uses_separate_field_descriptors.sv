/*
:name: test_protect_encoding_uses_separate_field_descriptors
:description: distinct encoding descriptors for protected key digest and data fields
:tags: ch34
:type: simulation
:lrm: 1800-2023 34.5.9.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_protect_encoding_uses_separate_field_descriptors
:expected_stdout: encoding fields=29,71
*/
`timescale 1ns/1ns
`pragma protect data_method = "aes256-cbc"
`pragma protect encoding=(enctype="base64")
`pragma protect begin
module protect_encoding_first(output wire [7:0] value);
  assign value = 8'd29;
endmodule
`pragma protect end

`pragma protect encoding=(enctype="uuencode")
`pragma protect begin
module protect_encoding_second(output wire [7:0] value);
  assign value = 8'd71;
endmodule
`pragma protect end

module test_protect_encoding_uses_separate_field_descriptors;
  wire [7:0] first, second;
  protect_encoding_first a(first);
  protect_encoding_second b(second);
  initial begin
    #1 $display("encoding fields=%0d,%0d", first, second);
    $finish;
  end
endmodule

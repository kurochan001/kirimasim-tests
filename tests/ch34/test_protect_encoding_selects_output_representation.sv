/*
:name: test_protect_encoding_selects_output_representation
:description: explicit encoding requests for the protected key and data payloads
:tags: ch34
:type: simulation
:lrm: 1800-2023 34.5.9.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_protect_encoding_selects_output_representation
:expected_stdout: encoding body=94
*/
`timescale 1ns/1ns
`pragma protect data_method = "aes256-cbc"
`pragma protect encoding=(enctype="base64")
`pragma protect begin
module protect_encoding_payload(output wire [7:0] value);
  assign value = 8'd94;
endmodule
`pragma protect end

module test_protect_encoding_selects_output_representation;
  wire [7:0] value;
  protect_encoding_payload body(value);
  initial begin
    #1 $display("encoding body=%0d", value);
    $finish;
  end
endmodule

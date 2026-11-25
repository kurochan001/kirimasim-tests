/*
:name: test_protect_data_method_cipher_selection
:description: protect data method selection for consecutive identical encrypted bodies
:tags: ch34
:type: simulation
:lrm: 1800-2023 34.5.11.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_protect_data_method_cipher_selection
:expected_stdout: first=93 second=93 control=a5
*/
`timescale 1ns/1ns
// The qualification runner replaces this single request for each CBC case.
`pragma protect data_method = "des-cbc"
`pragma protect encoding = (enctype="base64")

module protect_cipher_first(output wire [7:0] result);
`pragma protect begin
assign result = 8'h93;
`pragma protect end
endmodule

module protect_cipher_second(output wire [7:0] result);
`pragma protect begin
assign result = 8'h93;
`pragma protect end
endmodule

module test_protect_data_method_cipher_selection;
  wire [7:0] first, second;
  wire [7:0] control = 8'ha5;
  protect_cipher_first first_model(first);
  protect_cipher_second second_model(second);
  initial begin
    #1 $display("first=%h second=%h control=%h", first, second, control);
    $finish;
  end
endmodule

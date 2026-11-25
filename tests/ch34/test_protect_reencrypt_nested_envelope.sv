/*
:name: test_protect_reencrypt_nested_envelope
:description: lexical boundaries and CBC key metadata for a previously protected inner envelope
:tags: ch34
:type: simulation
:lrm: 1800-2023 34.4 34.3.1 34.5.1.2 34.5.15.2 34.5.27.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_protect_reencrypt_nested_envelope
:expected_stdout: outer=24,69 clear=17
*/
`timescale 1ns/1ns
`pragma protect data_method = "aes256-cbc"
`pragma protect encoding = (enctype="base64")

`pragma protect begin
module protect_outer_before(output wire [7:0] value);
  assign value = 8'h24;
endmodule
// Nested envelope qualification position
module protect_outer_after(output wire [7:0] value);
  assign value = 8'h69;
endmodule
`pragma protect end

module test_protect_reencrypt_nested_envelope;
  wire [7:0] first, second;
  wire [7:0] clear = 8'h17;
  protect_outer_before a(first);
  protect_outer_after b(second);
  initial begin
    #1 $display("outer=%h,%h clear=%h", first, second, clear);
    $finish;
  end
endmodule

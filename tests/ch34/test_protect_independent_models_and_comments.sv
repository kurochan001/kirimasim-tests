/*
:name: test_protect_independent_models_and_comments
:description: Protected models remain independent and export comments from included source
:tags: ch34
:type: simulation
:lrm: 1800-2023 34.5.1.2 34.5.30.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: protected_model_inputs/notice.svh
:top_module: test_protect_independent_models_and_comments
:expected_stdout: protected independent=49,a2
*/
`timescale 1ns/1ns

`pragma protect encoding = (enctype="base64")
`pragma protect data_method = "aes128-cbc"
`pragma protect key_keyowner = "Fixture East"
`pragma protect key_keyname = "assembly"
`pragma protect comment = "First model prefix"
`pragma protect begin
`include "notice.svh"
module protect_independent_first(output wire [7:0] value);
  assign value = 8'h49;
endmodule
`pragma protect end

`pragma protect reset
`pragma protect encoding = (enctype="uuencode")
`pragma protect data_method = "aes256-cbc"
`pragma protect key_keyowner = "Fixture West"
`pragma protect key_keyname = "assembly"
`pragma protect begin
module protect_independent_second(output wire [7:0] value);
  assign value = 8'ha2;
endmodule
`pragma protect comment = "Second model suffix"
`pragma protect end

module test_protect_independent_models_and_comments;
  wire [7:0] first, second;
  protect_independent_first left(first);
  protect_independent_second right(second);
  initial begin
    #1 $display("protected independent=%02h,%02h", first, second);
    $finish;
  end
endmodule

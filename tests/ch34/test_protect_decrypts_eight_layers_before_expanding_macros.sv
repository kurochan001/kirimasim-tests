/*
:name: test_protect_decrypts_eight_layers_before_expanding_macros
:description: Macros spanning eight encrypted envelope replacements
:tags: ch34
:type: simulation
:lrm: 1800-2023 34.2 34.3 34.3.2 34.5.3.2 34.5.4.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_protect_decrypts_eight_layers_before_expanding_macros
:expected_stdout: nested macro value=47
*/
`timescale 1ns/1ns
`define PROTECT_DEPTH_ADD(left, right) ((left) + (right))
module test_protect_decrypts_eight_layers_before_expanding_macros;
  wire [7:0] value;

`pragma protect key_method = "aes128-cbc"
`pragma protect key_keyowner = "Depth Outer"
`pragma protect key_keyname = "assembly"
`pragma protect data_method = "aes256-cbc"
`pragma protect encoding = (enctype="base64")
`pragma protect begin
`define PROTECT_DEPTH_OFFSET 8'd11
// Nested payload starts
  assign value = `PROTECT_DEPTH_ADD(8'd36, `PROTECT_DEPTH_OFFSET);
`define PROTECT_DEPTH_READY
// Nested payload ends
// Outer tail stays protected
`pragma protect end

  initial begin
`ifdef PROTECT_DEPTH_READY
    #1 $display("nested macro value=%0d", value);
`else
    #1 $display("nested macro missing");
`endif
    $finish;
  end
endmodule
`undef PROTECT_DEPTH_ADD
`undef PROTECT_DEPTH_OFFSET
`undef PROTECT_DEPTH_READY

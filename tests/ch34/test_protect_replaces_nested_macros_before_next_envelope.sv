/*
:name: test_protect_replaces_nested_macros_before_next_envelope
:description: Nested macro replacement and separate metadata in the next envelope
:tags: ch34
:type: simulation
:lrm: 1800-2023 34.2 34.3 34.3.2 34.5.3.2 34.5.4.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_protect_replaces_nested_macros_before_next_envelope
:expected_stdout: nested sibling values=33,50
*/
`timescale 1ns/1ns
`define PROTECT_CHAIN_LEFT 8'd33
module test_protect_replaces_nested_macros_before_next_envelope;
  wire [7:0] first, second;

`pragma protect key_method = "aes128-cbc"
`pragma protect key_keyowner = "Sibling First"
`pragma protect key_keyname = "assembly"
`pragma protect data_method = "aes256-cbc"
`pragma protect encoding = (enctype="base64")
`pragma protect begin
// Nested payload starts
  assign first = `PROTECT_CHAIN_LEFT;
`define PROTECT_CHAIN_STEP 8'd17
// Nested payload ends
// Outer tail stays protected
`pragma protect end

`pragma protect key_method = "aes128-cbc"
`pragma protect key_keyowner = "Sibling Second"
`pragma protect key_keyname = "assembly"
`pragma protect data_method = "aes128-cbc"
`pragma protect encoding = (enctype="uuencode")
`pragma protect begin
`ifdef PROTECT_CHAIN_STEP
  assign second = first + `PROTECT_CHAIN_STEP;
`endif
`pragma protect end

  initial begin
    #1 $display("nested sibling values=%0d,%0d", first, second);
    $finish;
  end
endmodule
`undef PROTECT_CHAIN_LEFT
`undef PROTECT_CHAIN_STEP

/*
:name: test_protect_reject_plaintext_payload_blocks
:description: key and data block placement in plaintext encryption input
:tags: ch34
:type: simulation
:lrm: 1800-2023 34.3.1 34.5.15.2 34.5.27.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_protect_reject_plaintext_payload_blocks
:expected_stdout: plaintext control=31
*/
`timescale 1ns/1ns
`pragma protect data_method = "aes256-cbc"
`pragma protect encoding = (enctype="base64")
// Qualification inserts one key_block or data_block at either marker.
// Plaintext file payload position
`pragma protect begin
// Plaintext envelope payload position
module protect_payload_visible(output wire [7:0] value);
  assign value = 8'h31;
endmodule
`pragma protect end

module test_protect_reject_plaintext_payload_blocks;
  wire [7:0] value;
  protect_payload_visible visible(value);
  initial begin
    #1 $display("plaintext control=%h", value);
    $finish;
  end
endmodule

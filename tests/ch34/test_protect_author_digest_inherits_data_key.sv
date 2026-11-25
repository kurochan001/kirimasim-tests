/*
:name: test_protect_author_digest_inherits_data_key
:description: Author ciphertext using the data decryption key for its digest
:tags: ch34
:type: simulation
:lrm: 1800-2023 34.5.11.2 34.5.14.2 34.5.20.2 34.5.27.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_protect_author_digest_inherits_data_key
:expected_stdout: author digest inherited=32,4f
*/
`timescale 1ns/1ns
`pragma protect data_method = "aes256-cbc"
`pragma protect digest_method = "md5"
`pragma protect encoding=(enctype="uuencode")
`pragma protect begin
module protect_author_inherited_payload(output wire [7:0] left, right);
  assign left = 8'h32;
  assign right = left + 8'h1d;
endmodule
`pragma protect end

module test_protect_author_digest_inherits_data_key;
  wire [7:0] left, right;
  protect_author_inherited_payload payload(left, right);
  initial begin
    #1 $display("author digest inherited=%02h,%02h", left, right);
    $finish;
  end
endmodule

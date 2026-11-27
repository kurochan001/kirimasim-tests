/*
:name: test_protect_registered_algorithm_extensions
:description: Protection algorithms with implementation-defined identifiers require explicit registration
:tags: ch34
:type: simulation
:lrm: 1800-2023 34.5.9.2 34.5.11.2 34.5.21.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_protect_registered_algorithm_extensions
:expected_stdout: protection extension body=73
*/
`timescale 1ns/1ns
`pragma protect encoding = (enctype="fixture-hex")
`pragma protect data_method = "fixture-aes128-ctr"
`pragma protect digest_method = "fixture-sha256"
`pragma protect begin
module protect_algorithm_extension_body(output wire [7:0] value);
  assign value = 8'h73;
endmodule
`pragma protect end

module test_protect_registered_algorithm_extensions;
  wire [7:0] value;
  protect_algorithm_extension_body payload(value);
  initial begin
    #1 $display("protection extension body=%02h", value);
    $finish;
  end
endmodule

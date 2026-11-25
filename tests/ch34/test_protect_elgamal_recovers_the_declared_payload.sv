/*
:name: test_protect_elgamal_recovers_the_declared_payload
:description: ElGamal protects an independently selected body in uuencode
:tags: ch34
:type: simulation
:lrm: 1800-2023 34.4 34.5.5.2 34.5.6.2 34.5.8.2 34.5.11.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_protect_elgamal_recovers_the_declared_payload
:expected_stdout: protect elgamal=6c
*/
`timescale 1ns/1ns
`pragma protect data_method = "elgamal"
`pragma protect encoding = (enctype="uuencode")
`pragma protect author = "Outside author B"
`pragma protect author_info = "Outside note B"
`pragma protect begin
`pragma protect author_info = "Protected note ELG"
// author_info=ordinary HDL comment; author=untouched
module protect_elgamal_payload(output wire [7:0] value);
  assign value = 8'ha9 ^ 8'hc5;
endmodule
`pragma protect author = "Protected author ELG"
`pragma protect end

module test_protect_elgamal_recovers_the_declared_payload;
  wire [7:0] value;
  protect_elgamal_payload payload(value);
  initial begin
    #1 $display("protect elgamal=%02h", value);
    $finish;
  end
endmodule

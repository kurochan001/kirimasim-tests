/*
:name: test_param_literal_initializers_follow_type
:description: parameter, localparam and specparam constants initialized with literals take the values the literals have after conversion to the declared type (IEEE 1800-2023 Section 6.20)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.20 5.9 6.12.1 6.16
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_param_literal_initializers_follow_type.expected
*/
// IEEE 1800-2023 §6.20: parameter constants can be initialized with a
// literal, which is converted to the type of the constant as in an
// assignment. A one-character string literal in a byte is its code (35 for
// "#"); in a 16-bit vector a string literal is padded with zeros on the left
// (§5.9); 8'ha5 is cut to 4'h5 in bit [3:0]; 1 in a logic is one bit;
// 16'hffff in a shortint is -1; the real 3.7 in an int rounds to 4 and the
// integer 2 in a real is 2.0 (§6.12.1); a string literal with \0 in a string
// constant loses the \0 (§6.16). The specparam keeps the literal value 25.
// Icarus Verilog 13.0 keeps the \0 in the string parameter (it prints
// "ab c" with len 7) instead of "abc" with len 3.

module test_param_literal_initializers_follow_type;
  localparam byte HASH = "#";
  parameter logic FLAG = 1;
  parameter bit [3:0] NIB = 8'ha5;
  localparam bit [15:0] TXT = "A";
  localparam shortint NEG = 16'hffff;
  parameter int I = 3.7;
  localparam real R = 2;
  parameter string S = "ab\0c";
  specparam SP = 25;

  initial begin
    $display("byte: %0d bits=%0d", HASH, $bits(HASH));
    $display("logic: %0d bits=%0d", FLAG, $bits(FLAG));
    $display("bit [3:0]: %h bits=%0d", NIB, $bits(NIB));
    $display("bit [15:0]: %h", TXT);
    $display("shortint: %0d", NEG);
    $display("int: %0d real: %0.2f", I, R);
    $display("string: \"%s\" len=%0d", S, S.len());
    $display("specparam: %0d", SP);
  end
endmodule

/*
:name: test_type_operator_matching_types
:description: type(a) == type(b) is true for matching types such as byte and bit signed [7:0], in procedural code as in a constant (IEEE 1800-2023 Section 6.23)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.23 6.22.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_type_operator_matching_types.expected
*/
// IEEE 1800-2023 §6.23: two type references compared with == or != are equal
// when the types match. §6.22.1 (e): byte matches bit signed [7:0], a 2-state
// signed vector of the same width with the range [7:0], but not
// bit signed [0:7], whose range differs, nor logic signed [7:0], which is
// 4-state. The comparison gives the same result in procedural code and in a
// localparam.

module test_type_operator_matching_types;
  byte a;
  bit signed [7:0] b;
  bit signed [0:7] c;
  logic signed [7:0] l;
  int i;
  localparam bit LP_EQ = type(a) == type(b);

  initial begin
    $display("byte == bit signed [7:0]: %0d", type(a) == type(b));
    $display("byte != bit signed [7:0]: %0d", type(a) != type(b));
    $display("byte == bit signed [0:7]: %0d", type(a) == type(c));
    $display("byte == logic signed [7:0]: %0d", type(a) == type(l));
    $display("byte == int: %0d", type(a) == type(i));
    $display("localparam byte == bit signed [7:0]: %0d", LP_EQ);
  end
endmodule

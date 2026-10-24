/*
:name: test_illegal_unsized_constant_in_concatenation
:description: an unsized constant number cannot be an operand of a concatenation (IEEE 1800-2023 Section 11.4.12)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.4.12
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the concatenation {a, 5} has the unsized constant number 5 as an operand
:expected_stderr_regex: test_illegal_unsized_constant_in_concatenation\.sv:27:
*/
// IEEE 1800-2023 §11.4.12: unsized constant numbers shall not be allowed in
// concatenations, since the size of each operand is needed for the size of
// the concatenation. {a, 4'd5} with a sized constant and {a, b} are legal;
// {a, 5} has the unsized constant 5.
// The 5.052 release of Verilator only warns (WIDTHCONCAT) and accepts it.

module test_illegal_unsized_constant_in_concatenation;
  logic [3:0] a = 4'h1, b = 4'h2;
  logic [7:0] x, y, z;

  initial begin
    x = {a, 4'd5};
    y = {a, b};
    z = {a, 5};   // illegal: unsized constant in a concatenation
    $display("%h %h", x, y);
  end
endmodule

/*
:name: test_illegal_select_of_concatenation_as_lvalue
:description: bits of a concatenation can be selected for reading, but such a select cannot be the left-hand side of an assignment (IEEE 1800-2023 Section 11.4.12)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.4.12
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the assignment writes {a, b}[3:2], a part-select of a concatenation
:expected_stderr_regex: test_illegal_select_of_concatenation_as_lvalue\.sv:31:
*/
// IEEE 1800-2023 §11.4.12: bits of a concatenation can be selected as if it
// were a packed array [n-1:0], but such a select shall not be legal as a
// variable or net lvalue, for example on the left-hand side of an
// assignment. Reading {a, b}[3:2] and {a + b}[1:0] and writing the whole
// concatenation {a, b} are legal; writing {a, b}[3:2] is not.
// Icarus Verilog 13.0 gives syntax errors also on the legal selects of a
// concatenation, so its error does not count; the design is accepted by the
// 5.052 release of Verilator.

module test_illegal_select_of_concatenation_as_lvalue;
  logic [3:0] a = 4'h9, b = 4'h6;
  logic [1:0] c, d;

  initial begin
    c = {a, b}[3:2];
    d = {a + b}[1:0];
    {a, b} = 8'h3c;
    {a, b}[3:2] = 2'b11;   // illegal: a select of a concatenation as an lvalue
    $display("%b %b", c, d);
  end
endmodule

/*
:name: test_sformat_assignment_rules
:description: $sformat assigns its text to its first argument by the rules for assigning a string literal: a string variable takes it whole, and an integral variable right-justified with zeros on the left or with the leftmost characters cut off (IEEE 1800-2023 Section 21.3.3)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.3 5.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sformat_assignment_rules.expected
*/
// IEEE 1800-2023 §21.3.3: output_var of $sformat is assigned by the rules for
// assigning a string literal to a variable (5.9). An integral variable wider
// than the text gets it right-justified with zero bits on the left, and one
// narrower than the text keeps the rightmost characters, and one of exactly
// the size of the text holds it; a string variable gets the whole text,
// however long it is. The 5.052 release of Verilator keeps the leftmost
// characters ABC in the narrower variable.

module test_sformat_assignment_rules;
  logic [8*6-1:0] wide;
  logic [8*3-1:0] narrow;
  logic [8*2-1:0] exact;
  string sv;

  initial begin
    $sformat(wide, "%0d", 42);
    $display("wider integral: %h", wide);
    $sformat(narrow, "%s", "ABCDE");
    $display("narrower integral: %h %s", narrow, narrow);
    $sformat(exact, "%h", 8'h9c);
    $display("exact integral: %s", exact);
    $sformat(sv, "x=%0d;", 7);
    $display("string: [%s] len=%0d", sv, sv.len());
    $sformat(sv, "%0d-%s", 123456, "long text");
    $display("string: [%s] len=%0d", sv, sv.len());
  end
endmodule

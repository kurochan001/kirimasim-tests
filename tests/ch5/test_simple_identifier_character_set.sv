/*
:name: test_simple_identifier_character_set
:description: A simple identifier is made of letters, digits, dollar signs and underscores, starts with a letter or an underscore and is case sensitive, so another character ends it, while an escaped identifier can hold that character (IEEE 1800-2023 Section 5.6)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.6 5.6.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_simple_identifier_character_set.expected
*/
// IEEE 1800-2023 §5.6: an identifier is a simple identifier or an escaped
// one (§5.6.1). A simple identifier is a sequence of letters, digits, $ and
// _, whose first character is a letter or _, and identifiers are case
// sensitive.
// The names a_b, a$b, a1b and _a hold an underscore, a dollar sign, a digit
// and a leading underscore and are separate variables from a and b. A minus
// or plus sign is not part of a simple identifier, so a-b and a+b are
// operations on a and b. A and B are other variables than a and b. The
// escaped identifier \a-b is one name that holds the minus sign.

module test_simple_identifier_character_set;
  int a = 50, b = 8;
  int a_b = 1000, a$b = 2000, a1b = 3000, _a = 4000;
  int A = 60, B = 70;
  int \a-b = 7 ;

  initial begin
    $display("parts: %0d %0d %0d %0d", a_b, a$b, a1b, _a);
    $display("operators: %0d %0d", a-b, a+b);
    $display("case: %0d %0d %0d %0d", a, A, b, B);
    $display("escaped: %0d", \a-b );
  end
endmodule

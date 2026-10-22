/*
:name: test_lexical_comments_and_keyword_identifiers
:description: Comments and whitespace separate tokens while escaped keywords and uppercase identifiers remain usable (IEEE 1800-2023 Section 5.2)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.2 5.3 5.6.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_lexical_comments_and_keyword_identifiers.expected
*/
// IEEE 1800-2023 5.2 5.3 5.6.2: Separating declaration tokens with comments or
// newlines preserves meaning; an escaped keyword and an uppercase spelling are
// identifiers.

module test_lexical_comments_and_keyword_identifiers;
  int/* separator */\before = 6;
  int Before = 9;
  initial begin
    $display("values=%0d,%0d text=%s", \before , Before, "a  b");
  end
endmodule

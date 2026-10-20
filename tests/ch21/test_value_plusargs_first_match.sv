/*
:name: test_value_plusargs_first_match
:description: $value$plusargs takes the first plusarg, in the order given, whose beginning matches, and a plusarg that only shares a shorter beginning does not match (IEEE 1800-2023 Section 21.6)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:args: +countdown=3 +count=5 +count=9
:expected_stdout: @test_value_plusargs_first_match.expected
*/
// IEEE 1800-2023 §21.6: the plusargs are searched in the order given, and the
// first one whose prefix matches the text before the format specification is
// used. For "count=%d", +countdown=3 does not match, since its seventh
// character is not "=", and of +count=5 and +count=9 the first one counts.

module test_value_plusargs_first_match;
  int n, m;

  initial begin
    if ($value$plusargs("count=%d", n)) $display("count=%0d", n);
    if ($value$plusargs("countdown=%d", m)) $display("countdown=%0d", m);
  end
endmodule

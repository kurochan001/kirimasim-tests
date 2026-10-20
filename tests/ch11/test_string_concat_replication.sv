/*
:name: test_string_concat_replication
:description: A concatenation with a string operand is a string concatenation, a string replication can have a non-constant count, and the result is not truncated: the string variable grows to hold it (IEEE 1800-2023 Section 11.4.12.2)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.12.2 6.16 11.4.12.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_concat_replication.expected
*/
// IEEE 1800-2023 §11.4.12.2: a concatenation is treated as a string when an
// operand is a string, and a replication of strings may have a count that is
// not a constant. The result is never truncated; the string variable is
// resized to fit it. n is a variable, so {n{s}} repeats s three times, and
// {t, "-", s} and the nested replication grow t.

module test_string_concat_replication;
  int n = 3;
  string s = "ab", t;

  initial begin
    t = {n{s}};
    $display("%s len=%0d", t, t.len());
    t = {t, "-", s};
    $display("%s len=%0d", t, t.len());
    n = 2;
    t = {n{{s, "!"}}};
    $display("%s len=%0d", t, t.len());
  end
endmodule

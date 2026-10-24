/*
:name: test_illegal_string_replication_empty_braces
:description: a string replication needs at least one operand inside its inner braces (IEEE 1800-2023 Section 6.16)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.16
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the replication {2{}} has no operand inside its inner braces
:expected_stderr_regex: test_illegal_string_replication_empty_braces\.sv:26:
*/
// IEEE 1800-2023 §6.16 (Table 6-9): in a string replication
// {multiplier{Str1, ..., Strn}}, there shall be at least one operand in the
// inner pair of braces. The legal replications have one string operand and
// two operands; the last one has nothing inside the inner braces.

module test_illegal_string_replication_empty_braces;
  string s, t = "ab";
  initial begin
    s = {2{t}};
    $display("%s", s);
    s = {3{t, "-"}};
    $display("%s", s);
    s = {2{}};   // illegal: no operand in the inner braces
  end
endmodule

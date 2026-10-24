/*
:name: test_illegal_string_replication_int_operand
:description: the operands inside the braces of a string replication are string literals or expressions of string type; an int operand is an error (IEEE 1800-2023 Section 6.16)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.16
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the replication {2{s, k}} has the string s and the int variable k as its inner operands
:expected_stderr_regex: test_illegal_string_replication_int_operand\.sv:35:
*/
// IEEE 1800-2023 §6.16 (Table 6-9): in the replication of strings, each operand
// inside the inner braces can be a string literal or an expression of string
// type; when one of them has string type, the string literals among them are
// converted to string and the result is the inner concatenation repeated. An
// integral value becomes a string only through a cast.
// The replications {2{s, "-"}}, {n{s}} with the variable n = 3, and {2{s,
// string'(k)}} with a cast of the int k are legal, and the legal design prints
// their results: ab-ab- ababab abBabB. The last replication has s and the int k
// as inner operands, without a cast.
// Icarus Verilog 13.0 rejects the legal replication {n{s}} because its
// multiplier is not a constant, which does not count. The 5.052 release accepts
// the design.

module test_illegal_string_replication_int_operand;
  string s = "ab";
  string t;
  int n = 3;
  int k = 66;
  initial begin
    t = {2{s, "-"}};
    $display("%s %s %s", t, {n{s}}, {2{s, string'(k)}});
    t = {2{s, k}};   // illegal: an int operand in a string replication
  end
endmodule

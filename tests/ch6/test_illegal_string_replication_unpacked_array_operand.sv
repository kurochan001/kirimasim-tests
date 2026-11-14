/*
:name: test_illegal_string_replication_unpacked_array_operand
:description: Each operand inside the braces of a string replication has to be a string literal or an expression of string type; an unpacked array of strings is neither, so the replication is illegal (IEEE 1800-2023 Section 6.16)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.16
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the inner operands of the string replication are the string s and the unpacked array parts, which is neither a string literal nor an expression of string type
:expected_stderr_regex: test_illegal_string_replication_unpacked_array_operand\.sv:33:
*/
// IEEE 1800-2023 §6.16 (Table 6-9): in a string replication, each operand in
// the inner braces can be a string literal or an expression of string type.
// parts is an unpacked array of two strings: its elements are strings, but
// the array itself is not an expression of string type, and there is no
// conversion from it to a string (11.4.12.2 converts the other operands of a
// string concatenation to string as 6.16 describes). The replication on the
// marked line uses the whole array as an operand next to the string s, which
// is illegal. With the element parts[0] in its place, the design is legal and
// prints acac.
// Oracle checks: Icarus Verilog 13.0 rejects the marked line because the
// array is used without an index; the 5.054 release of Verilator accepts the
// design and fails only later, when the C++ compiler builds the generated
// model, which is not a diagnosis of the rule.

module test_illegal_string_replication_unpacked_array_operand;
  string s = "a";
  string parts [2] = '{"c", "d"};
  string r;
  initial begin
    r = {2{s, parts}};    // illegal: an unpacked array inside a string replication
    $display("%s", r);
  end
endmodule

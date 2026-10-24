/*
:name: test_string_concat_replication_typing
:description: A concatenation or constant replication of string literals only is an integral value, converted to a string only where a string is needed, while a string operand or a nonconstant multiplier makes the result a string, and a zero multiplier gives the empty string (IEEE 1800-2023 Section 6.16)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16 11.4.12 11.4.12.2 5.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_concat_replication_typing.expected
*/
// IEEE 1800-2023 §6.16, Table 6-9: a concatenation whose operands are all
// string literals behaves as a concatenation of integral values (11.4.12),
// and so does a replication of literals with a nonzero constant multiplier;
// such a result becomes a string only when it is used where a string is
// needed. With at least one operand of string type, or a nonconstant
// multiplier, the literals are converted to strings first and the result is a
// string (11.4.12.2). A multiplier of zero gives the empty string.
// The type shows in the width ($bits), in the zero byte that "" (8'h00, 5.9)
// leaves in an integral value but not in a string, and in comparisons with the
// literal "ab" or "abc": two integral values compare as numbers (16'h0062 is
// below 16'h6162, 16'h6262 below 24'h616263), a string compares in
// lexicographic order ("b" is after "ab"). The replications with the variable
// multipliers n2 and n0 are assigned to a string.
// Oracle checks: Icarus Verilog 13.0 rejects the nonconstant multiplier, which
// 11.4.12.2 allows for a string replication.

module test_string_concat_replication_typing;
  string s = "";
  string x;
  int n2 = 2, n0 = 0;
  logic [23:0] r;

  initial begin
    r = {"H", ""};
    $display("literals as integral: %h bits=%0d", r, $bits({"H", ""}));
    x = {"H", ""};
    $display("literals as string: \"%s\" len=%0d", x, x.len());
    $display("literals compared: %0d", {"", "b"} < "ab");
    x = {s, "", "b"};
    $display("with a string: \"%s\" len=%0d", x, x.len());
    $display("with a string compared: %0d", {s, "b"} < "ab");
    $display("literal replication: bits=%0d compared=%0d", $bits({2{"b"}}), {2{"b"}} < "abc");
    x = {3{"ab"}};
    $display("literal replication as string: \"%s\" len=%0d", x, x.len());
    x = {n2{"ab"}};
    $display("nonconstant replication: \"%s\" len=%0d", x, x.len());
    x = {0{"ab"}};
    $display("zero replication: \"%s\" len=%0d", x, x.len());
    x = {n0{"ab"}};
    $display("nonconstant zero replication: \"%s\" len=%0d", x, x.len());
  end
endmodule

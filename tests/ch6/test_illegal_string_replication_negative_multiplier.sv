/*
:name: test_illegal_string_replication_negative_multiplier
:description: the multiplier of a string replication cannot be negative (IEEE 1800-2023 Section 6.16)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.16
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the string replication {-1{t}} has the negative multiplier -1
:expected_stderr_regex: test_illegal_string_replication_negative_multiplier\.sv:30:
*/
// IEEE 1800-2023 §6.16 (Table 6-9): the multiplier of a string replication
// shall be a nonnegative expression of integral type without x or z bits,
// and it need not be a constant expression. The legal replications use the
// variable n and the constant 0, which gives the empty string.
// The last replication has the multiplier -1.
// Icarus Verilog 13.0 also rejects the replications with the variable
// multiplier n and with the multiplier 0, which are legal for strings.

module test_illegal_string_replication_negative_multiplier;
  string s, t = "ab";
  int n = 3;
  initial begin
    s = {n{t}};
    $display("[%s]", s);
    s = {0{t}};
    $display("[%s]", s);
    s = {-1{t}};   // illegal: negative multiplier
  end
endmodule

/*
:name: test_illegal_string_replication_real_multiplier
:description: the multiplier of a string replication has to be of integral type; a real expression is illegal (IEEE 1800-2023 Section 6.16)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.16
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the multiplier of the string replication is the real variable r
:expected_stderr_regex: test_illegal_string_replication_real_multiplier\.sv:33:
*/
// IEEE 1800-2023 §6.16 (Table 6-9): the multiplier of a string replication
// shall be a nonnegative expression of integral type without x or z bits,
// and it need not be a constant expression. The legal replications use the
// variable n and the constant 0, which gives the empty string.
// The multiplier of the last replication is a real variable.
// Icarus Verilog 13.0 rejects every replication with a variable multiplier
// as not constant, and the one with the multiplier 0, the legal ones
// included, so its error on the real multiplier does not count; the 5.052
// release accepts the real multiplier.

module test_illegal_string_replication_real_multiplier;
  string s, t = "ab";
  int n = 3;
  real r = 2.0;
  initial begin
    s = {n{t}};
    $display("[%s]", s);
    s = {0{t}};
    $display("[%s]", s);
    s = {r{t}};   // illegal: real multiplier
  end
endmodule

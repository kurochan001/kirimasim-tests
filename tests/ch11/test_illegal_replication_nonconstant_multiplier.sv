/*
:name: test_illegal_replication_nonconstant_multiplier
:description: the multiplier of a replication of integral values has to be a constant expression (IEEE 1800-2023 Section 11.4.12.1)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.4.12.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the multiplier of the replication {n{a}} is the variable n
:expected_stderr_regex: test_illegal_replication_nonconstant_multiplier\.sv:34:
*/
// IEEE 1800-2023 §11.4.12.1: the multiplier of a replication is a
// non-negative, non-x and non-z constant expression; only a replication of
// strings (11.4.12.2) may have a non-constant one. {3{a}} and {P{a}} with
// the parameter P are legal, and so is the string replication {n{s}}; the
// integral replication {n{a}} has the variable n as multiplier.
// Icarus Verilog 13.0 also rejects the legal string replication {n{s}}, so
// its error does not count.

module test_illegal_replication_nonconstant_multiplier;
  localparam int P = 2;
  logic [1:0] a = 2'b10;
  int n = 3;
  string s = "ab", t;
  logic [5:0] x;
  logic [3:0] y;

  initial begin
    x = {3{a}};
    y = {P{a}};
    t = {n{s}};
    x = {n{a}};   // illegal: a variable as multiplier of an integral replication
    $display("%b %b %s", x, y, t);
  end
endmodule

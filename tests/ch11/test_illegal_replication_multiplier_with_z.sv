/*
:name: test_illegal_replication_multiplier_with_z
:description: the multiplier of a replication cannot contain an z bit (IEEE 1800-2023 Section 11.4.12.1)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.4.12.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:should_fail_because: the multiplier of the replication {2'b1z{a}} is a constant with an z bit
:expected_stderr_regex: test_illegal_replication_multiplier_with_z\.sv:24:
*/
// IEEE 1800-2023 §11.4.12.1: the multiplier of a replication shall be a
// non-negative, non-x and non-z constant expression. {2'b10{a}} has the
// multiplier 2, which is legal; 2'b1z has an z bit.

module test_illegal_replication_multiplier_with_z;
  logic [1:0] a = 2'b11;
  logic [3:0] x;

  initial begin
    x = {2'b10{a}};
    x = {2'b1z{a}};   // illegal: an z bit in the multiplier
    $display("%b", x);
  end
endmodule

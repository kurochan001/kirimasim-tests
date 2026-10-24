/*
:name: test_illegal_replication_negative_multiplier
:description: the multiplier of a replication cannot be negative (IEEE 1800-2023 Section 11.4.12.1)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.4.12.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the multiplier of the replication {M{a}} is the parameter M, whose value is -1
:expected_stderr_regex: test_illegal_replication_negative_multiplier\.sv:30:
*/
// IEEE 1800-2023 §11.4.12.1: the multiplier of a replication shall be a
// non-negative constant expression. {P{a}} with P = 2 is legal, and so is a
// replication by zero inside a concatenation that has another operand; the
// replication by M = -1 is not.

module test_illegal_replication_negative_multiplier;
  localparam int P = 2;
  localparam int Z = 0;
  localparam int M = -1;
  logic [1:0] a = 2'b01;
  logic [3:0] x;
  logic [1:0] y;

  initial begin
    x = {P{a}};
    y = {{Z{a}}, a};
    x = {{M{a}}, a};   // illegal: a negative multiplier
    $display("%b %b", x, y);
  end
endmodule

/*
:name: test_illegal_zero_replication_alone
:description: a replication with a zero multiplier is ignored, but it has to be inside a concatenation that also has an operand of positive size (IEEE 1800-2023 Section 11.4.12.1)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.4.12.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the concatenation {{Z{a}}} has the zero replication {Z{a}} as its only operand
:expected_stderr_regex: test_illegal_zero_replication_alone\.sv:26:
*/
// IEEE 1800-2023 §11.4.12.1: a replication with a zero multiplier has a size
// of zero and is ignored; it shall appear only within a concatenation in
// which at least one operand has a positive size. {{Z{a}}, b} is legal and
// equals b; in {{Z{a}}} the zero replication is the only operand.

module test_illegal_zero_replication_alone;
  localparam int Z = 0;
  logic [1:0] a = 2'b11, b = 2'b01;
  logic [1:0] x, y;

  initial begin
    x = {{Z{a}}, b};
    y = {{Z{a}}};   // illegal: no operand of positive size
    $display("%b", x);
  end
endmodule

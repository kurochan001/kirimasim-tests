/*
:name: test_illegal_clocking_cycle_delay_negative_integer
:description: A procedural clocking cycle delay rejects a negative integer expression
:tags: ch14
:type: elaboration
:lrm: 1800-2023 14.11
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the procedural cycle-delay expression evaluates to minus one
:expected_stderr_regex: test_illegal_clocking_cycle_delay_negative_integer\.sv:23:(?:\d+:)?[^\n]*(?i:(?:negative|greater than or equal|cycle delay|nonnegative)[^\n]*)
*/
`timescale 1ns/1ns
module test_illegal_clocking_cycle_delay_negative_integer;
  bit clock;
  always #5 clock = ~clock;
  default clocking cb @(posedge clock);
  endclocking

  localparam int NEGATIVE = -1;
  initial begin
    ##(NEGATIVE) $display("after negative delay"); // illegal
    $finish;
  end
  initial #20 $finish;
endmodule

/*
:name: test_illegal_time_literal_space_before_unit
:description: White space between the number and the unit of a time literal is rejected (IEEE 1800-2023 Section 5.7)
:tags: ch5
:type: elaboration
:lrm: 1800-2023 5.7 5.8
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the number 10 of the time literal is followed by white space before its unit ns
:expected_stderr_regex: test_illegal_time_literal_space_before_unit\.sv:27:
*/
// IEEE 1800-2023 §5.7 (Syntax 5-2, footnote 49): the number of a time
// literal shall not be followed by white space, so the unit has to follow it
// directly. 2ns and 1.5ns are legal time literals (§5.8); on the marked line
// 10 ns is a number followed by an identifier, which is an error.

`timescale 1ns / 1ps

module test_illegal_time_literal_space_before_unit;
  realtime t1, t2, t3;

  initial begin
    t1 = 2ns;
    t2 = 1.5ns;
    t3 = 10 ns;   // illegal: white space between the number and the unit
    $display("%0t %0t %0t", t1, t2, t3);
  end
endmodule

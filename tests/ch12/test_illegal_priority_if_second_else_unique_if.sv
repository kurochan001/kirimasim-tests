/*
:name: test_illegal_priority_if_second_else_unique_if
:description: unique cannot be inserted after the second else of a priority-if series (IEEE 1800-2023 Section 12.4.2)
:tags: ch12
:type: elaboration
:lrm: 1800-2023 12.4.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: unique is written after the second else of a series of if-else-if conditions qualified by priority
:expected_stderr_regex: test_illegal_priority_if_second_else_unique_if\.sv:27:
*/
// IEEE 1800-2023 §12.4.2: unique, unique0 and priority qualify the whole series
// of if-else-if conditions, and none of them may be written after any else of
// that series. The series below starts with priority; its first else is plain,
// and its second else is followed by unique, which is illegal.
// Icarus Verilog 13.0 does not support unique-if, so the syntax error it
// reports on the line of the error does not count; Verilator 5.052 accepts
// the design.

module test_illegal_priority_if_second_else_unique_if;
  int a = 3;
  initial begin
    priority if (a == 0) $display("zero");
    else if (a == 1) $display("one");
    else unique if (a == 3) $display("three");   // illegal
    else $display("other");
  end
endmodule

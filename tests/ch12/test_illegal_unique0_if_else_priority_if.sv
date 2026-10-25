/*
:name: test_illegal_unique0_if_else_priority_if
:description: priority cannot be inserted after else in a unique0-if series (IEEE 1800-2023 Section 12.4.2)
:tags: ch12
:type: elaboration
:lrm: 1800-2023 12.4.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: priority is written after an else of a series of if-else-if conditions qualified by unique0
:expected_stderr_regex: test_illegal_unique0_if_else_priority_if\.sv:26:
*/
// IEEE 1800-2023 §12.4.2: unique, unique0 and priority qualify the whole series
// of if-else-if conditions, and none of them may be written after an else of
// that series. The series below starts with unique0, and its first else is
// followed by priority, which is illegal.
// Icarus Verilog 13.0 does not support unique-if, so the syntax error it
// reports on the line of the error does not count; Verilator 5.052 accepts
// the design.

module test_illegal_unique0_if_else_priority_if;
  int a = 2;
  initial begin
    unique0 if (a == 0) $display("zero");
    else priority if (a == 2) $display("two");   // illegal
  end
endmodule

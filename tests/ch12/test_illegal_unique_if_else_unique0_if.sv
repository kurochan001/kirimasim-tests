/*
:name: test_illegal_unique_if_else_unique0_if
:description: unique0 cannot be inserted after else in a unique-if series (IEEE 1800-2023 Section 12.4.2)
:tags: ch12
:type: elaboration
:lrm: 1800-2023 12.4.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: unique0 is written after an else of a series of if-else-if conditions qualified by unique
:expected_stderr_regex: test_illegal_unique_if_else_unique0_if\.sv:32:
*/
// IEEE 1800-2023 §12.4.2: unique, unique0 and priority qualify the whole series
// of if-else-if conditions, and none of them may be written after an else of
// that series. The series below starts with unique, and its first else is
// followed by unique0, which is illegal. A qualified if nested in such a series
// has to be put in a begin-end block, as the first statement of the initial
// block does; that form is legal.
// Icarus Verilog 13.0 does not support unique-if, so the syntax error it
// reports on the line of the error does not count; Verilator 5.052 accepts
// the design.

module test_illegal_unique_if_else_unique0_if;
  int a = 1;
  initial begin
    unique if (a == 0) $display("zero");
    else begin
      unique0 if (a == 1) $display("one");
    end
    unique if (a == 0) $display("zero");
    else unique0 if (a == 1) $display("one");   // illegal
    else $display("other");
  end
endmodule

/*
:name: test_illegal_display_format_missing_argument
:description: a format specification other than %m, %l and %% without a corresponding argument is an error (IEEE 1800-2023 Section 21.2.1)
:tags: ch21
:type: elaboration
:lrm: 1800-2023 21.2.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the string literal of the second $display has two %0d specifications but only one argument follows it
:expected_stderr_regex: test_illegal_display_format_missing_argument\.sv:28:
*/
// IEEE 1800-2023 §21.2.1: every % in a string literal of a display task
// starts a format specification, and each one, except %m, %l and %%, needs
// an expression argument after the string literal. The first $display uses
// only %m, %l and %%, so it needs no argument and is legal. The second has
// two %0d specifications and only the argument a, so the second %0d has no
// argument, which is the error.
// Icarus Verilog 13.0 accepts the design and only warns when the task runs.

module test_illegal_display_format_missing_argument;
  int a = 3;

  initial begin
    $display("%m %l 100%%");
    $display("a=%0d", a);
    $display("a=%0d b=%0d", a);   // illegal: the second %0d has no argument
  end
endmodule

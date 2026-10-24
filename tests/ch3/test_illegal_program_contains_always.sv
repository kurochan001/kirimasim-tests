/*
:name: test_illegal_program_contains_always
:description: A program that contains an always procedure is rejected (IEEE 1800-2023 Section 3.4)
:tags: ch3
:type: elaboration
:lrm: 1800-2023 3.4 24.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the program contains an always procedure, which a program cannot contain
:expected_stderr_regex: test_illegal_program_contains_always\.sv:24:
*/
// IEEE 1800-2023 §3.4 lists what a program can contain (data, classes,
// subroutines, object instances, initial and final procedures) and says that
// it cannot contain always procedures; §24.3 repeats the rule. The program
// below is otherwise legal: it has a variable and an initial procedure, and
// only the always procedure on the marked line breaks the rule. The program is
// not instantiated, so it is a top-level block (§24.3).

program test_illegal_program_contains_always;
  int ticks;

  always #1 ticks++;   // illegal: always procedure in a program

  initial #5 $display("ticks=%0d", ticks);
endprogram

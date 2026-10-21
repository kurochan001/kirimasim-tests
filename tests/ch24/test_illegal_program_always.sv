/*
:name: test_illegal_program_always
:description: A program cannot contain an always procedure (IEEE 1800-2023 Section 24.3)
:tags: ch24
:type: elaboration
:lrm: 1800-2023 24.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the program contains an always procedure
:expected_stderr_regex: test_illegal_program_always\.sv:20:
*/
// IEEE 1800-2023 §24.3: a program can hold data, subroutines and initial and
// final procedures, but it shall not contain always procedures, primitives,
// UDPs, or declarations or instances of modules, interfaces or programs.

program test_illegal_program_always_p(input logic clk);
  int n;
  always @(posedge clk) n++;   // illegal: always in a program
  initial #20 $display("n=%0d", n);
endprogram

module test_illegal_program_always;
  logic clk = 0;
  always #5 clk = ~clk;
  test_illegal_program_always_p p(clk);
endmodule

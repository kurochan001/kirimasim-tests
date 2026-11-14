/*
:name: test_illegal_checker_instantiates_program
:description: A program cannot be instantiated in the body of a checker (IEEE 1800-2023 Section 17.2)
:tags: ch17
:type: elaboration
:lrm: 1800-2023 17.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the checker body instantiates a program
:expected_stderr_regex: test_illegal_checker_instantiates_program\.sv:32:
*/
// IEEE 1800-2023 17.2: modules, interfaces, programs and packages shall not be
// declared inside checkers, and modules, interfaces and programs shall not be
// instantiated there.
// The checker below instantiates the program leaf_prog declared outside it.
// The grammar of the checker body (Syntax 17-1) has no program
// instantiation; the only instantiation it has is that of a checker, and
// leaf_prog is not a checker. Without that instance the design is legal.
// Icarus Verilog 13.0 does not support checkers. The 5.054 release of
// the Verilator simulator reports a syntax error on that line, but it does
// so for a legal checker instance inside a checker as well, so its error
// does not count.

`timescale 1ns/1ns

program leaf_prog;
endprogram : leaf_prog

checker with_program_instance(input logic a, output logic y);
  leaf_prog u_leaf();   // illegal
  assign y = a;
endchecker : with_program_instance

module test_illegal_checker_instantiates_program;
  logic a = 1'b1, y;

  with_program_instance u(.a(a), .y(y));

  initial #1 $display("y=%b", y);
endmodule

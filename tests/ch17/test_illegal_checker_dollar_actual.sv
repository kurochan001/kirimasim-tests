/*
:name: test_illegal_checker_dollar_actual
:description: The terminal $ can be an actual argument only of an untyped checker formal (IEEE 1800-2023 Section 17.3)
:tags: ch17
:type: elaboration
:lrm: 1800-2023 17.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the instance passes $ as the actual of the typed formal n
:expected_stderr_regex: test_illegal_checker_dollar_actual\.sv:31:
*/
// IEEE 1800-2023 17.3: the terminal $ may be an actual argument of a checker
// instance, but then the corresponding formal argument shall be untyped and
// each of its references shall be an upper bound in a cycle_delay_const_range
// or another actual argument. The formal n below has the type int, so the
// instance that passes $ to it is not legal. The rest of the design is legal.
// Icarus Verilog 13.0 does not support checkers at all and Verilator 5.052
// does not support a checker declared in a module, so no release is named.

`timescale 1ns/1ns

checker typed_arg(input int n, output int y);
  assign y = n;
endchecker : typed_arg

module test_illegal_checker_dollar_actual;
  int y;

  typed_arg u(.n($), .y(y));   // illegal: $ for the typed formal n

  initial #1 $display("y=%0d", y);
endmodule

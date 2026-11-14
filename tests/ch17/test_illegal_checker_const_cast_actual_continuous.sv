/*
:name: test_illegal_checker_const_cast_actual_continuous
:description: A checker input whose actual argument contains a const cast cannot be used in a continuous assignment of the checker, while the same checker with a plain variable as the actual is legal (IEEE 1800-2023 Section 17.3)
:tags: ch17
:type: elaboration
:lrm: 1800-2023 17.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the instance u_cast passes const'(v) to the formal a, which the checker uses in a continuous assignment
:expected_stderr_regex: test_illegal_checker_const_cast_actual_continuous\.sv:(28|36):
*/
// IEEE 1800-2023 17.3: if an actual input argument of a checker instance
// contains a const cast, the corresponding formal shall not be used in a
// continuous assignment or in the procedural code of the checker. The
// checker cast_assign uses its formal a in a continuous assignment. The
// instance u_plain passes the module variable v, which is legal; u_cast
// passes const'(v), so that instance is not legal. A tool can report the
// error at the continuous assignment or at the instance. Without u_cast the
// design is legal.
// Icarus Verilog 13.0 does not support checkers, and the 5.054 release of
// the Verilator simulator accepts the design.

`timescale 1ns/1ns

checker cast_assign(input logic [3:0] a, output logic [3:0] y);
  assign y = a + 4'd1;   // illegal for u_cast
endchecker : cast_assign

module test_illegal_checker_const_cast_actual_continuous;
  logic [3:0] v = 4'd3;
  logic [3:0] y_plain, y_cast;

  cast_assign u_plain(v, y_plain);
  cast_assign u_cast(const'(v), y_cast);   // illegal: the actual has a const cast

  initial #1 $display("y_plain=%0d y_cast=%0d", y_plain, y_cast);
endmodule

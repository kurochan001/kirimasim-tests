/*
:name: test_illegal_checker_captured_actual
:description: A formal whose actual argument contains a const cast cannot be used in the procedural code of the checker (IEEE 1800-2023 Section 17.3)
:tags: ch17
:type: elaboration
:lrm: 1800-2023 17.3 17.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the actual of the formal a contains a const cast and the checker uses a in a procedural assignment
:expected_stderr_regex: test_illegal_checker_captured_actual\.sv:(25|32):
*/
// IEEE 1800-2023 17.3: if an actual input argument contains any subexpression
// that is a const cast, the corresponding formal argument shall not be used in
// a continuous assignment or in the procedural code within the checker. The
// actual of a is const'(v), and the always_comb procedure of the checker uses
// a, so the instance is not legal. The rest of the design is legal.
// Icarus Verilog 13.0 does not support checkers at all and Verilator 5.052
// does not support a checker declared in a module, so no release is named.

`timescale 1ns/1ns

checker captured_use(input logic [3:0] a, output logic [3:0] y);
  always_comb y = a + 4'd1;   // illegal use of a
endchecker : captured_use

module test_illegal_checker_captured_actual;
  logic [3:0] v = 4'd3;
  logic [3:0] y;

  captured_use u(.a(const'(v)), .y(y));   // the actual contains a const cast

  initial #1 $display("y=%0d", y);
endmodule

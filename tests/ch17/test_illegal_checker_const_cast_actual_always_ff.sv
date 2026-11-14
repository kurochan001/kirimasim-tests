/*
:name: test_illegal_checker_const_cast_actual_always_ff
:description: A checker input whose actual argument contains a const cast cannot be used in an always_ff procedure of the checker, while the same checker with a plain variable as the actual is legal (IEEE 1800-2023 Section 17.3)
:tags: ch17
:type: elaboration
:lrm: 1800-2023 17.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the instance u_cast passes v + const'(w) to the formal a, which the checker reads in its always_ff procedure
:expected_stderr_regex: test_illegal_checker_const_cast_actual_always_ff\.sv:(30|40):
*/
// IEEE 1800-2023 17.3: if an actual input argument of a checker instance
// contains any subexpression that is a const cast, the corresponding formal
// shall not be used in a continuous assignment or in the procedural code of
// the checker. The checker cast_ff reads its formal a in the nonblocking
// assignment of an always_ff procedure. The instance u_plain passes v + w,
// which is legal; u_cast passes v + const'(w), whose subexpression const'(w)
// is a const cast, so that instance is not legal. A tool can report the
// error at the assignment or at the instance. Without u_cast the design is
// legal.
// Icarus Verilog 13.0 does not support checkers, and the 5.054 release of
// the Verilator simulator accepts the design.

`timescale 1ns/1ns

checker cast_ff(input logic clk, input logic [3:0] a, output logic [3:0] y);
  logic [3:0] r = 4'd0;
  always_ff @(posedge clk) r <= a;   // illegal for u_cast
  assign y = r;
endchecker : cast_ff

module test_illegal_checker_const_cast_actual_always_ff;
  logic clk = 1'b0;
  logic [3:0] v = 4'd3, w = 4'd1;
  logic [3:0] y_plain, y_cast;

  cast_ff u_plain(clk, v + w, y_plain);
  cast_ff u_cast(clk, v + const'(w), y_cast);   // illegal: a subexpression is a const cast

  initial begin
    #1 clk = 1'b1;
    #1 $display("y_plain=%0d y_cast=%0d", y_plain, y_cast);
  end
endmodule

/*
:name: test_checker_input_expressions
:description: The actual argument of a checker input may be an expression, an operator expression or a net, and the checker sees each change of its values (IEEE 1800-2023 Section 17.3)
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.3 17.2 17.7.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_checker_input_expressions.expected
*/
// IEEE 1800-2023 §17.3: the actual arguments of a checker instance are
// connected like module ports, and for an input the rewriting algorithm
// substitutes the actual for each reference to the formal. So the actual may
// be an expression or a net, and every value it reads is a sensitivity of the
// always_comb procedure (17.5, 17.7.1). The three instances give the same
// checker the sum a + b, the net a ^ b, and the concatenation of the low bits
// of a and b. The sum stays within four bits, so the width of the expression
// is unambiguous. Each output is a module variable.

`timescale 1ns/1ns

checker chk_inc(input logic [3:0] x, output logic [4:0] y);
  always_comb y = x + 5'd1;
endchecker

module test_checker_input_expressions;
  logic [3:0] a = 4'h3, b = 4'h5;
  wire [3:0] w;
  logic [4:0] y_sum, y_wire, y_bits;

  assign w = a ^ b;

  chk_inc c_sum(.x(a + b), .y(y_sum));
  chk_inc c_wire(.x(w), .y(y_wire));
  chk_inc c_bits(.x({a[1:0], b[1:0]}), .y(y_bits));

  initial begin
    #1 $display("a=3 b=5: %0d %0d %0d", y_sum, y_wire, y_bits);
    a = 4'h9;
    #1 $display("a=9 b=5: %0d %0d %0d", y_sum, y_wire, y_bits);
    b = 4'h2;
    #1 $display("a=9 b=2: %0d %0d %0d", y_sum, y_wire, y_bits);
  end
endmodule

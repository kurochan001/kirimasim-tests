/*
:name: test_assignment_in_expression
:description: A parenthesized blocking assignment inside an expression returns the assigned value with the type of its target (IEEE 1800-2023 Section 11.3.6)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.3.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assignment_in_expression.expected
*/
// IEEE 1800-2023 §11.3.6: a blocking assignment in parentheses can be an
// operand of an expression. It converts the right-hand side to the type of the
// target, writes the target and returns that converted value, whose type is the
// type of the target.

module test_assignment_in_expression;
  logic [7:0] y;
  int x, a, b;

  initial begin
    a = 3;
    if ((b = a + 1) == 4) $display("if: b=%0d", b);
    x = (y = 8'hFF) + 1;          // an 8-bit 255, then added at 32 bits
    $display("x=%0d y=%0d", x, y);
    x = (y = 300);                // converted to 8 bits first
    $display("x=%0d y=%0d", x, y);
    x = 0;
    while ((a = a - 1) > 0) x += a;
    $display("loop: x=%0d a=%0d", x, a);
  end
endmodule

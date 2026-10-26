/*
:name: test_expr_unary_plus
:description: unary plus returns its operand with the operand's type and signedness (IEEE 1800-2023 11.4.3)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_expr_unary_plus.expected
*/
// IEEE 1800-2023 §11.4.3: the unary plus operator returns the value of its
// operand, whose type and signedness decide how the value is read. The test
// applies it to a signed byte, an unsigned 8-bit vector, a signed int, a real,
// a signed expression and the result of $signed, and prints the values. An
// implementation that returns the two's complement, loses the sign, or drops
// the fraction prints a different line.

module test_expr_unary_plus;
  byte sb = -8'sd3;
  logic [7:0] u = 8'h80;
  int i = -7;
  real r = 1.5;

  initial begin
    $display("byte=%0d", +sb);
    $display("logic=%0d", +u);
    $display("int=%0d", +i);
    $display("real=%0.1f", +r);
    $display("expr=%0d", +(4'sd3 * -1));
    $display("signed=%0d", +$signed(8'h80));
    $finish;
  end
endmodule

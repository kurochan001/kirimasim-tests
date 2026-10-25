/*
:name: test_real_literal_syntax_forms
:description: A real literal is written in fixed-point form or as a decimal significand, with or without a fraction, followed by e or E and an exponent with an optional sign, and both forms are real values (IEEE 1800-2023 Section 5.7)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.7 5.7.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_real_literal_syntax_forms.expected
*/
// IEEE 1800-2023 §5.7, Syntax 5-2: a real number is either a fixed-point
// number, digits, a point and digits, or an unsigned number with an
// optional point and fraction, then e or E, an optional + or - sign and the
// exponent digits; underscores may follow the first digit of each digit
// sequence. §5.7.2: the default type of both forms is real.
// Line "fixed" prints fixed-point literals, one with underscores. Line
// "exponent" prints literals with e and E, with no sign, + and -, and with
// and without a fraction. Line "real" divides exponent-form literals without
// a point by 3: as real values they give fractions, while integers would
// give 166 and 0.

module test_real_literal_syntax_forms;
  initial begin
    $display("fixed: %0.4f %0.4f %0.4f", 3.25, 1_000.5, 0.0625);
    $display("exponent: %0.4f %0.4f %0.4f %0.4f %0.4f %0.4f", 5e2, 5E+2, 25e-1, 1.5e3, 1.5E-3,
             2.5_0e1);
    $display("real: %0.4f %0.4f", 5e2 / 3, 1e0 / 3);
  end
endmodule

/*
:name: test_precedence_multiplicative_shift_levels
:description: * / % share one precedence level between ** and binary + -, and the four shift operators share one level between binary + - and the relational operators, each grouping from the left (IEEE 1800-2023 Section 11.3.2)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.3.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_precedence_multiplicative_shift_levels.expected
*/
// IEEE 1800-2023 §11.3.2, Table 11-2: * / % are one row, below ** and above
// binary + -; << >> <<< >>> are one row, below binary + - and above the
// relational operators. Operators of one row have the same precedence and
// associate left to right.
// Each line prints an expression without parentheses whose other groupings
// give other values: each pair of operators of a row is written in both
// orders, so the left one has to be applied first (12 / 4 * 3 is 9, not 1;
// 1 << 4 >> 2 is 4, not 2), and each operator of the row is combined with an
// operator of the rows above and below it on both sides (2 + 3 * 4 is 14, not
// 20; 1 << 1 + 2 is 8, not 4; 3 < 1 << 2 is 1, not 0). All operands are
// nonnegative unsized decimal numbers, so no value depends on signedness.

module test_precedence_multiplicative_shift_levels;
  initial begin
    $display("12 / 4 * 3 = %0d", 12 / 4 * 3);
    $display("3 * 4 / 6 = %0d", 3 * 4 / 6);
    $display("10 %% 4 * 3 = %0d", 10 % 4 * 3);
    $display("3 * 4 %% 5 = %0d", 3 * 4 % 5);
    $display("20 / 2 %% 3 = %0d", 20 / 2 % 3);
    $display("17 %% 10 / 2 = %0d", 17 % 10 / 2);
    $display("2 * 3 ** 2 = %0d", 2 * 3 ** 2);
    $display("2 ** 4 / 2 = %0d", 2 ** 4 / 2);
    $display("2 ** 3 %% 5 = %0d", 2 ** 3 % 5);
    $display("2 + 3 * 4 = %0d", 2 + 3 * 4);
    $display("3 * 4 - 2 = %0d", 3 * 4 - 2);
    $display("20 - 12 / 4 = %0d", 20 - 12 / 4);
    $display("12 / 4 + 2 = %0d", 12 / 4 + 2);
    $display("1 + 7 %% 4 = %0d", 1 + 7 % 4);
    $display("7 %% 4 - 1 = %0d", 7 % 4 - 1);
    $display("1 << 4 >> 2 = %0d", 1 << 4 >> 2);
    $display("16 >> 2 << 1 = %0d", 16 >> 2 << 1);
    $display("1 <<< 3 >>> 1 = %0d", 1 <<< 3 >>> 1);
    $display("32 >>> 1 <<< 2 = %0d", 32 >>> 1 <<< 2);
    $display("2 << 3 >>> 2 = %0d", 2 << 3 >>> 2);
    $display("64 >>> 2 >> 1 = %0d", 64 >>> 2 >> 1);
    $display("1 << 1 + 2 = %0d", 1 << 1 + 2);
    $display("1 + 1 << 2 = %0d", 1 + 1 << 2);
    $display("64 >> 3 - 1 = %0d", 64 >> 3 - 1);
    $display("9 - 1 >> 1 = %0d", 9 - 1 >> 1);
    $display("1 <<< 1 + 1 = %0d", 1 <<< 1 + 1);
    $display("16 >>> 1 + 1 = %0d", 16 >>> 1 + 1);
    $display("3 < 1 << 2 = %0d", 3 < 1 << 2);
    $display("1 << 2 < 3 = %0d", 1 << 2 < 3);
    $display("8 >> 1 >= 4 = %0d", 8 >> 1 >= 4);
    $display("4 <= 8 >>> 1 = %0d", 4 <= 8 >>> 1);
    $display("1 <<< 3 > 9 = %0d", 1 <<< 3 > 9);
  end
endmodule

/*
:name: test_precedence_relational_equality_levels
:description: the relational operators and inside share one precedence level below the arithmetic and shift operators, and the six equality operators, wildcard ones included, share the next level above binary &, each grouping from the left (IEEE 1800-2023 Section 11.3.2)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.3.2 11.4.4 11.4.5 11.4.6 11.4.13
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_precedence_relational_equality_levels.expected
*/
// IEEE 1800-2023 §11.3.2, Table 11-2: < <= > >= and inside are one row,
// below the shift row and so below all arithmetic operators (§11.4.4); the
// row below it holds == != === !== ==? !=? (§11.4.5, §11.4.6), and binary &
// follows. Operators of one row have the same precedence and associate left
// to right.
// Each line prints an expression without parentheses whose other grouping
// gives another value: each operator of a row is written before and after
// another operator of the same row (1 < 1 <= 1 is 1, grouping from the right
// would give 0), each relational operator is combined with an arithmetic
// operator on both sides (1 + 1 < 1 is 0, not 1), and each equality operator
// with a relational operator and with & on both sides (1 & 2 == 2 is 1, not
// 0; 1 == 3 & 1 is 0, not 1). inside is combined with < on its left, and with
// a shift, an addition and equality operators (1 == 2 inside {2} is 1, not
// 0). All operands are known, so === and ==? give the same truth values as
// ==, and the results are 1 or 0. dist, the other operator of the row, can
// only be written in a constraint and is not used here.
// Icarus Verilog 13.0 does not support inside expressions.

module test_precedence_relational_equality_levels;
  initial begin
    $display("1 < 1 <= 1 = %0d", 1 < 1 <= 1);
    $display("1 <= 2 < 2 = %0d", 1 <= 2 < 2);
    $display("1 <= 2 > 1 = %0d", 1 <= 2 > 1);
    $display("1 > 1 <= 1 = %0d", 1 > 1 <= 1);
    $display("1 > 1 >= 2 = %0d", 1 > 1 >= 2);
    $display("1 >= 1 > 1 = %0d", 1 >= 1 > 1);
    $display("1 >= 1 < 1 = %0d", 1 >= 1 < 1);
    $display("1 < 2 >= 1 = %0d", 1 < 2 >= 1);
    $display("1 < 1 + 2 = %0d", 1 < 1 + 2);
    $display("1 + 1 < 1 = %0d", 1 + 1 < 1);
    $display("1 <= 2 - 1 = %0d", 1 <= 2 - 1);
    $display("1 - 1 <= 1 = %0d", 1 - 1 <= 1);
    $display("2 > 1 * 2 = %0d", 2 > 1 * 2);
    $display("2 * 1 > 1 = %0d", 2 * 1 > 1);
    $display("1 >= 1 / 2 = %0d", 1 >= 1 / 2);
    $display("1 / 2 >= 1 = %0d", 1 / 2 >= 1);
    $display("1 %% 1 < 2 = %0d", 1 % 1 < 2);
    $display("1 == 2 != 2 = %0d", 1 == 2 != 2);
    $display("1 != 1 == 2 = %0d", 1 != 1 == 2);
    $display("1 != 1 === 2 = %0d", 1 != 1 === 2);
    $display("1 === 2 != 2 = %0d", 1 === 2 != 2);
    $display("1 === 2 !== 2 = %0d", 1 === 2 !== 2);
    $display("1 !== 1 === 2 = %0d", 1 !== 1 === 2);
    $display("1 !== 1 ==? 2 = %0d", 1 !== 1 ==? 2);
    $display("1 ==? 2 !== 2 = %0d", 1 ==? 2 !== 2);
    $display("1 ==? 2 !=? 2 = %0d", 1 ==? 2 !=? 2);
    $display("1 !=? 1 ==? 2 = %0d", 1 !=? 1 ==? 2);
    $display("1 !=? 1 == 2 = %0d", 1 !=? 1 == 2);
    $display("1 == 2 !=? 2 = %0d", 1 == 2 !=? 2);
    $display("1 ==? 2 == 2 = %0d", 1 ==? 2 == 2);
    $display("1 != 1 !=? 2 = %0d", 1 != 1 !=? 2);
    $display("1 == 2 < 1 = %0d", 1 == 2 < 1);
    $display("1 < 2 == 1 = %0d", 1 < 2 == 1);
    $display("1 != 1 <= 1 = %0d", 1 != 1 <= 1);
    $display("1 <= 2 != 1 = %0d", 1 <= 2 != 1);
    $display("1 === 2 > 1 = %0d", 1 === 2 > 1);
    $display("1 > 1 === 2 = %0d", 1 > 1 === 2);
    $display("1 !== 1 >= 2 = %0d", 1 !== 1 >= 2);
    $display("1 >= 1 !== 1 = %0d", 1 >= 1 !== 1);
    $display("1 ==? 2 < 1 = %0d", 1 ==? 2 < 1);
    $display("1 < 2 ==? 1 = %0d", 1 < 2 ==? 1);
    $display("1 !=? 1 > 1 = %0d", 1 !=? 1 > 1);
    $display("1 > 1 !=? 2 = %0d", 1 > 1 !=? 2);
    $display("1 & 2 == 2 = %0d", 1 & 2 == 2);
    $display("1 == 3 & 1 = %0d", 1 == 3 & 1);
    $display("1 & 2 != 2 = %0d", 1 & 2 != 2);
    $display("1 != 1 & 2 = %0d", 1 != 1 & 2);
    $display("1 & 2 === 2 = %0d", 1 & 2 === 2);
    $display("1 === 3 & 1 = %0d", 1 === 3 & 1);
    $display("1 & 2 !== 2 = %0d", 1 & 2 !== 2);
    $display("1 !== 1 & 2 = %0d", 1 !== 1 & 2);
    $display("1 & 2 ==? 2 = %0d", 1 & 2 ==? 2);
    $display("1 ==? 3 & 1 = %0d", 1 ==? 3 & 1);
    $display("1 & 2 !=? 2 = %0d", 1 & 2 !=? 2);
    $display("1 !=? 1 & 2 = %0d", 1 !=? 1 & 2);
    $display("2 < 3 inside {1} = %0d", 2 < 3 inside {1});
    $display("4 >> 1 inside {2} = %0d", 4 >> 1 inside {2});
    $display("2 + 1 inside {3} = %0d", 2 + 1 inside {3});
    $display("1 == 2 inside {2} = %0d", 1 == 2 inside {2});
    $display("0 != 2 inside {1} = %0d", 0 != 2 inside {1});
  end
endmodule

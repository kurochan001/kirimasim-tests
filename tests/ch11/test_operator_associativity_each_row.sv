/*
:name: test_operator_associativity_each_row
:description: operators of one row of the precedence table group from the left, except the conditional, implication and equivalence operators, which group from the right; each row where the grouping changes a value is shown (IEEE 1800-2023 Section 11.3.2)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.3.2
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_operator_associativity_each_row.expected
*/
// IEEE 1800-2023 §11.3.2, Table 11-2: operators on one row have the same
// precedence, and all of them associate from left to right, except ?:, ->
// and <->, which associate from right to left. The assignment operators have
// no associativity and the concatenation braces their own syntax: neither
// can share an operand with another of its row without parentheses or
// braces.
// Each printed expression has two operators of one row and no parentheses,
// and its other grouping gives another value. For **: 2 ** 3 ** 2 is
// (2 ** 3) ** 2 = 64, not 512. For * / %: 100 / 10 * 2 = 20 (not 5),
// 17 % 5 * 3 = 6 (not 2), 60 / 6 % 4 = 2 (not 30). For + -: 10 - 4 + 3 = 9
// (not 3), 10 - 4 - 3 = 3 (not 9). For shifts: 16 >> 2 << 1 = 8 (not 1),
// 1 << 4 >>> 2 = 4 (not 2). For the relational row, inside included:
// 3 < 2 < 1 = 1 (not 0), 3 > 2 > 1 = 0 (not 1), 1 < 2 inside {1} = 1 (not 0).
// For the equality row: 1 == 2 != 2 = 1 (not 0), 1 ==? 2 !== 2 = 1 (not 0).
// For ?:: 1 ? 2 : 0 ? 3 : 4 = 2 (from the left 3). For -> and <->:
// 0 -> 0 -> 0 = 1 (from the left 0), 0 -> 0 <-> 0 = 1 (from the left 0) and
// 0 <-> 0 -> 1 = 0 (from the left 1). The selects of the first row apply
// from the left, as m[1][0] and s.f[2] show. &, the ^ ~^ ^~ row, |, && and ||
// are associative, so both groupings give the same value; their line shows
// one example of each. The last line nests assignment operators in
// parentheses and concatenations in braces.
// Icarus Verilog 13.0 supports neither inside in this expression nor an
// assignment within an expression.

module test_operator_associativity_each_row;
  typedef struct packed {
    logic [3:0] f;
  } box_t;

  int m [0:1][0:1] = '{'{1, 2}, '{3, 4}};
  box_t s = '{f: 4'b0100};
  int x, y, z;
  logic [5:0] cat;

  initial begin
    $display("**: %0d", 2 ** 3 ** 2);
    $display("* / %%: %0d %0d %0d", 100 / 10 * 2, 17 % 5 * 3, 60 / 6 % 4);
    $display("+ -: %0d %0d", 10 - 4 + 3, 10 - 4 - 3);
    $display("shifts: %0d %0d", 16 >> 2 << 1, 1 << 4 >>> 2);
    $display("relational: %0d %0d %0d", 3 < 2 < 1, 3 > 2 > 1, 1 < 2 inside {1});
    $display("equality: %0d %0d", 1 == 2 != 2, 1 ==? 2 !== 2);
    $display("conditional: %0d", 1 ? 2 : 0 ? 3 : 4);
    $display("implication: %0d %0d %0d", 0 -> 0 -> 0, 0 -> 0 <-> 0, 0 <-> 0 -> 1);
    $display("selects: %0d %b", m[1][0], s.f[2]);
    $display("associative: %b %b %b %0d %0d", 4'b1100 & 4'b1010 & 4'b0110,
             4'b1100 ^ 4'b1010 ~^ 4'b0110, 4'b1000 | 4'b0100 | 4'b0001, 1 && 0 && 1,
             0 || 0 || 1);
    x = (y = (z = 5) + 1) * 2;
    cat = {{2'b10, 2'b01}, {2{1'b1}}};
    $display("nested: x=%0d y=%0d z=%0d cat=%b", x, y, z, cat);
  end
endmodule

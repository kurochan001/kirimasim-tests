/*
:name: test_precedence_logical_conditional_implication_levels
:description: && binds above ||, both below the relational and equality operators and above ?:, which groups from the right and binds above -> and <->, which share the lowest of these levels and group from the right (IEEE 1800-2023 Section 11.3.2)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.3.2 11.4.7 11.4.11
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_precedence_logical_conditional_implication_levels.expected
*/
// IEEE 1800-2023 §11.3.2, Table 11-2, and §11.4.7: && binds more tightly than
// ||, and both less tightly than the relational and equality operators. The
// conditional operator comes next and associates right (§11.4.11). -> and <->
// share the next row and associate right, so either can be the outer one.
// Each line prints an expression without parentheses whose other grouping
// gives another value: 0 && 0 || 1 is 1, not 0; 1 < 2 && 1 is 1, not 0;
// 1 || 0 -> 0 is (1 || 0) -> 0 = 0, not 1; 0 -> 0 -> 0 is 0 -> (0 -> 0) = 1,
// not 0. 0 -> 0 <-> 0 is 1 and 0 <-> 0 -> 1 is 0: the first would be 0 if ->
// bound more tightly, the second 1 if <-> did. 1 ? 0 : 1 ? 2 : 3 is 0, where
// grouping from the left would give 3, and a conditional is an operand of ->
// and <-> on either side (1 ? 0 : 1 -> 0 is 1, not 0). (a -> b) || c and
// a -> (b || c) are always equal, so that combination is not printed.

module test_precedence_logical_conditional_implication_levels;
  initial begin
    $display("0 && 0 || 1 = %0d", 0 && 0 || 1);
    $display("1 || 0 && 0 = %0d", 1 || 0 && 0);
    $display("1 < 2 && 1 = %0d", 1 < 2 && 1);
    $display("0 && 0 < 1 = %0d", 0 && 0 < 1);
    $display("1 < 0 || 1 = %0d", 1 < 0 || 1);
    $display("0 || 2 < 2 = %0d", 0 || 2 < 2);
    $display("0 == 0 && 0 = %0d", 0 == 0 && 0);
    $display("0 && 0 == 0 = %0d", 0 && 0 == 0);
    $display("0 == 0 || 1 = %0d", 0 == 0 || 1);
    $display("0 || 2 == 1 = %0d", 0 || 2 == 1);
    $display("1 != 0 && 0 = %0d", 1 != 0 && 0);
    $display("0 && 0 != 1 = %0d", 0 && 0 != 1);
    $display("1 != 0 || 1 = %0d", 1 != 0 || 1);
    $display("0 || 2 != 1 = %0d", 0 || 2 != 1);
    $display("0 >= 0 && 0 = %0d", 0 >= 0 && 0);
    $display("0 && 0 >= 0 = %0d", 0 && 0 >= 0);
    $display("0 >= 0 || 1 = %0d", 0 >= 0 || 1);
    $display("0 || 2 >= 2 = %0d", 0 || 2 >= 2);
    $display("0 && 0 -> 0 = %0d", 0 && 0 -> 0);
    $display("0 -> 0 && 0 = %0d", 0 -> 0 && 0);
    $display("1 || 0 -> 0 = %0d", 1 || 0 -> 0);
    $display("0 && 0 <-> 0 = %0d", 0 && 0 <-> 0);
    $display("0 <-> 0 && 0 = %0d", 0 <-> 0 && 0);
    $display("1 || 0 <-> 0 = %0d", 1 || 0 <-> 0);
    $display("0 <-> 0 || 1 = %0d", 0 <-> 0 || 1);
    $display("0 -> 0 -> 0 = %0d", 0 -> 0 -> 0);
    $display("0 -> 0 <-> 0 = %0d", 0 -> 0 <-> 0);
    $display("0 <-> 0 -> 1 = %0d", 0 <-> 0 -> 1);
    $display("1 ? 0 : 1 ? 2 : 3 = %0d", 1 ? 0 : 1 ? 2 : 3);
    $display("1 ? 2 : 0 ? 3 : 4 = %0d", 1 ? 2 : 0 ? 3 : 4);
    $display("1 ? 0 ? 7 : 8 : 9 = %0d", 1 ? 0 ? 7 : 8 : 9);
    $display("1 || 0 ? 5 : 7 = %0d", 1 || 0 ? 5 : 7);
    $display("1 ? 5 : 0 || 1 = %0d", 1 ? 5 : 0 || 1);
    $display("0 && 1 ? 5 : 7 = %0d", 0 && 1 ? 5 : 7);
    $display("1 ? 5 : 0 && 0 = %0d", 1 ? 5 : 0 && 0);
    $display("1 ? 0 : 1 -> 0 = %0d", 1 ? 0 : 1 -> 0);
    $display("0 -> 1 ? 0 : 1 = %0d", 0 -> 1 ? 0 : 1);
    $display("1 ? 0 : 1 <-> 0 = %0d", 1 ? 0 : 1 <-> 0);
    $display("0 <-> 0 ? 2 : 0 = %0d", 0 <-> 0 ? 2 : 0);
  end
endmodule

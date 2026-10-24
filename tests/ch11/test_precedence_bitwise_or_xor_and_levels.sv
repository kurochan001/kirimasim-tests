/*
:name: test_precedence_bitwise_or_xor_and_levels
:description: binary & binds below the equality operators and above the ^ ~^ ^~ row, which binds above binary |, which binds above && and || (IEEE 1800-2023 Section 11.3.2)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.3.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_precedence_bitwise_or_xor_and_levels.expected
*/
// IEEE 1800-2023 §11.3.2, Table 11-2: after the equality row come binary &,
// then the row of binary ^ ~^ ^~, then binary |, then && and ||, each row
// binding less tightly than the one before it.
// Each line prints an expression of 4-bit unsigned operands without
// parentheses, written with the two operators in both orders, whose other
// grouping gives another value: 4'd1 & 4'd1 ^ 4'd2 is (1 & 1) ^ 2 = 3, not
// 1 & (1 ^ 2) = 1; 4'd1 & 4'd1 ~^ 4'd1 is ~(1 ^ 1) = 15, not 1 & 15 = 1;
// 4'd1 | 4'd1 ~^ 4'd2 is 1 | ~(1 ^ 2) = 13, not ~((1 | 1) ^ 2) = 12;
// 4'd2 | 4'd1 && 4'd1 is (3 && 1) = 1, not 2 | 1 = 3. Within
// the rows of & and |, and between ^ and ~^, every grouping gives the same
// value, so only the order between the rows can be seen.

module test_precedence_bitwise_or_xor_and_levels;
  initial begin
    $display("4'd1 == 4'd3 & 4'd1 = %0d", 4'd1 == 4'd3 & 4'd1);
    $display("4'd1 & 4'd2 != 4'd2 = %0d", 4'd1 & 4'd2 != 4'd2);
    $display("4'd1 & 4'd1 ^ 4'd2 = %0d", 4'd1 & 4'd1 ^ 4'd2);
    $display("4'd1 ^ 4'd1 & 4'd2 = %0d", 4'd1 ^ 4'd1 & 4'd2);
    $display("4'd1 & 4'd1 ~^ 4'd1 = %0d", 4'd1 & 4'd1 ~^ 4'd1);
    $display("4'd1 ~^ 4'd1 & 4'd1 = %0d", 4'd1 ~^ 4'd1 & 4'd1);
    $display("4'd1 & 4'd1 ^~ 4'd1 = %0d", 4'd1 & 4'd1 ^~ 4'd1);
    $display("4'd1 ^~ 4'd1 & 4'd1 = %0d", 4'd1 ^~ 4'd1 & 4'd1);
    $display("4'd1 ^ 4'd1 | 4'd1 = %0d", 4'd1 ^ 4'd1 | 4'd1);
    $display("4'd1 | 4'd1 ^ 4'd1 = %0d", 4'd1 | 4'd1 ^ 4'd1);
    $display("4'd1 ~^ 4'd1 | 4'd2 = %0d", 4'd1 ~^ 4'd1 | 4'd2);
    $display("4'd1 | 4'd1 ~^ 4'd2 = %0d", 4'd1 | 4'd1 ~^ 4'd2);
    $display("4'd1 ^~ 4'd1 | 4'd2 = %0d", 4'd1 ^~ 4'd1 | 4'd2);
    $display("4'd1 | 4'd1 ^~ 4'd2 = %0d", 4'd1 | 4'd1 ^~ 4'd2);
    $display("4'd2 | 4'd1 && 4'd1 = %0d", 4'd2 | 4'd1 && 4'd1);
    $display("4'd1 && 4'd1 | 4'd2 = %0d", 4'd1 && 4'd1 | 4'd2);
    $display("4'd2 | 4'd1 || 4'd1 = %0d", 4'd2 | 4'd1 || 4'd1);
    $display("4'd1 || 4'd1 | 4'd2 = %0d", 4'd1 || 4'd1 | 4'd2);
  end
endmodule

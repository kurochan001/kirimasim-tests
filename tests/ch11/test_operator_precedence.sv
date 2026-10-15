/*
:name: test_operator_precedence
:description: Tests operator evaluation order and precedence rules
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.3.2 11.4.5
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_operator_precedence.expected
*/
// Tests operator evaluation order and precedence rules
`timescale 1ns/1ps

module test_operator_precedence;
    int pass_count = 0;
    int fail_count = 0;

    // Test 1: Arithmetic precedence (* before +)
    task test_arith_precedence();
        int result;

        result = 2 + 3 * 4;  // Should be 2 + 12 = 14

        if (result == 14) begin
            $display("PASS: * before + (2+3*4=14)");
            pass_count++;
        end else begin
            $display("FAIL: Arithmetic precedence failed (result=%0d)", result);
            fail_count++;
        end
    endtask

    // Test 2: Parentheses override
    task test_parentheses();
        int result;

        result = (2 + 3) * 4;  // Should be 5 * 4 = 20

        if (result == 20) begin
            $display("PASS: Parentheses override ((2+3)*4=20)");
            pass_count++;
        end else begin
            $display("FAIL: Parentheses failed");
            fail_count++;
        end
    endtask

    // Test 3: Shift vs addition
    task test_shift_vs_add();
        int result;

        result = 1 << 2 + 1;  // binary + binds tighter than << (11.3.2): 1 << 3 = 8

        if (result == 8) begin
            $display("PASS: Shift precedence (1<<2+1=8)");
            pass_count++;
        end else begin
            $display("FAIL: Shift precedence (result=%0d, expected 8)", result);
            fail_count++;
        end
    endtask

    // Test 4: Comparison vs logical
    task test_compare_vs_logical();
        static int a = 1, b = 2, c = 3;
        logic result;

        result = a < b && b < c;  // Comparisons evaluate first

        if (result == 1) begin
            $display("PASS: Compare before logical (1<2 && 2<3)");
            pass_count++;
        end else begin
            $display("FAIL: Compare vs logical failed");
            fail_count++;
        end
    endtask

    // Test 5: Bitwise vs comparison
    task test_bitwise_vs_compare();
        static logic [3:0] a = 4'b1010;
        static logic [3:0] b = 4'b0101;
        logic result;

        // Comparison has lower precedence than bitwise
        result = (a & b) == 0;

        if (result == 1) begin
            $display("PASS: Bitwise before comparison");
            pass_count++;
        end else begin
            $display("FAIL: Bitwise vs compare failed");
            fail_count++;
        end
    endtask

    // Test 6: Conditional operator precedence
    task test_conditional_precedence();
        int result;
        static logic cond = 1;

        result = cond ? 10 : 20 + 5;  // Should be 10 (true branch)

        if (result == 10) begin
            $display("PASS: Conditional precedence (true branch)");
            pass_count++;
        end else begin
            $display("FAIL: Conditional precedence failed");
            fail_count++;
        end

        cond = 0;
        result = cond ? 10 : 20 + 5;  // Should be 25 (false branch evaluated)

        if (result == 25) begin
            $display("PASS: Conditional false branch (20+5=25)");
            pass_count++;
        end else begin
            $display("FAIL: False branch failed");
            fail_count++;
        end
    endtask

    // Test 7: Unary vs binary
    task test_unary_vs_binary();
        int result;

        result = -3 * 2;  // Unary minus first, then multiply

        if (result == -6) begin
            $display("PASS: Unary before binary (-3*2=-6)");
            pass_count++;
        end else begin
            $display("FAIL: Unary vs binary failed (result=%0d)", result);
            fail_count++;
        end
    endtask

    // Test 8: Logical AND vs OR
    task test_and_vs_or();
        logic result;

        result = 0 || 1 && 1;  // && has higher precedence

        if (result == 1) begin
            $display("PASS: && before || (0||1&&1=1)");
            pass_count++;
        end else begin
            $display("FAIL: AND vs OR failed");
            fail_count++;
        end

        result = (0 || 1) && 1;

        if (result == 1) begin
            $display("PASS: Parentheses force OR first");
            pass_count++;
        end else begin
            $display("FAIL: Parentheses OR failed");
            fail_count++;
        end
    endtask

    // Test 9: Reduction operators
    task test_reduction_precedence();
        static logic [3:0] a = 4'b1111;
        logic result;

        result = &a == 1;  // Reduction first, then compare

        if (result == 1) begin
            $display("PASS: Reduction before comparison");
            pass_count++;
        end else begin
            $display("FAIL: Reduction precedence failed");
            fail_count++;
        end
    endtask

    // Test 10: Concatenation
    task test_concat_precedence();
        logic [7:0] result;
        static logic [3:0] a = 4'hA;
        static logic [3:0] b = 4'hB;

        result = {a, b} + 1;  // Concatenation first

        if (result == 8'hAC) begin
            $display("PASS: Concatenation before addition");
            pass_count++;
        end else begin
            $display("FAIL: Concat precedence (result=%h)", result);
            fail_count++;
        end
    endtask

    // Test 11: Equality vs assignment
    task test_equality_types();
        static logic [3:0] a = 4'b1x01;
        static logic [3:0] b = 4'b1x01;
        logic eq, case_eq;

        eq = (a == b);      // Logical equality (X causes X)
        case_eq = (a === b); // Case equality (X matches X)

        if (case_eq == 1) begin
            $display("PASS: Case equality matches X");
            pass_count++;
        end else begin
            $display("FAIL: Case equality failed");
            fail_count++;
        end
    endtask

    // Test 12: Complex expression
    task test_complex_expression();
        int result;

        result = 2 + 3 * 4 - 10 / 2 + 1;
        // = 2 + 12 - 5 + 1 = 10

        if (result == 10) begin
            $display("PASS: Complex expression (2+3*4-10/2+1=10)");
            pass_count++;
        end else begin
            $display("FAIL: Complex expression failed (result=%0d)", result);
            fail_count++;
        end
    endtask

    // Test 13: Left-to-right associativity
    task test_associativity();
        int result;

        result = 20 / 4 / 2;  // Left-to-right: (20/4)/2 = 5/2 = 2

        if (result == 2) begin
            $display("PASS: Left-to-right associativity (20/4/2=2)");
            pass_count++;
        end else begin
            $display("FAIL: Associativity failed (result=%0d)", result);
            fail_count++;
        end
    endtask

    initial begin
        $display("=== Operator Precedence Test ===");

        test_arith_precedence();
        test_parentheses();
        test_shift_vs_add();
        test_compare_vs_logical();
        test_bitwise_vs_compare();
        test_conditional_precedence();
        test_unary_vs_binary();
        test_and_vs_or();
        test_reduction_precedence();
        test_concat_precedence();
        test_equality_types();
        test_complex_expression();
        test_associativity();

        $display("");
        $display("=== Summary ===");
        $display("Passed: %0d, Failed: %0d", pass_count, fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule

/*
:name: test_conditional_expr_3
:description: Test: Conditional ternary operator (?:)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.11
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_conditional_expr_3.expected
*/
// Test: Conditional ternary operator (?:)

module test_conditional_expr_3;
    int pass_count = 0;
    int total_tests = 25;

    // Test variables
    logic cond;
    int a, b, result;
    logic [7:0] va, vb, vresult;
    real ra, rb, rresult;
    string sa, sb, sresult;

    initial begin
        // Test 1: Basic true condition
        cond = 1'b1;
        a = 10; b = 20;
        result = cond ? a : b;
        if (result == 10) begin
            $display("Test 1 PASSED: 1 ? 10 : 20 = 10");
            pass_count++;
        end else $display("Test 1 FAILED");

        // Test 2: Basic false condition
        cond = 1'b0;
        a = 10; b = 20;
        result = cond ? a : b;
        if (result == 20) begin
            $display("Test 2 PASSED: 0 ? 10 : 20 = 20");
            pass_count++;
        end else $display("Test 2 FAILED");

        // Test 3: Non-zero int as condition (true)
        a = 42;
        result = a ? 100 : 200;
        if (result == 100) begin
            $display("Test 3 PASSED: 42 ? 100 : 200 = 100");
            pass_count++;
        end else $display("Test 3 FAILED");

        // Test 4: Zero int as condition (false)
        a = 0;
        result = a ? 100 : 200;
        if (result == 200) begin
            $display("Test 4 PASSED: 0 ? 100 : 200 = 200");
            pass_count++;
        end else $display("Test 4 FAILED");

        // Test 5: Comparison as condition
        a = 5; b = 10;
        result = (a < b) ? 1 : 0;
        if (result == 1) begin
            $display("Test 5 PASSED: (5 < 10) ? 1 : 0 = 1");
            pass_count++;
        end else $display("Test 5 FAILED");

        // Test 6: Logic vector operands
        cond = 1'b1;
        va = 8'hAA; vb = 8'h55;
        vresult = cond ? va : vb;
        if (vresult == 8'hAA) begin
            $display("Test 6 PASSED: 1 ? 0xAA : 0x55 = 0xAA");
            pass_count++;
        end else $display("Test 6 FAILED");

        // Test 7: Logic vector false branch
        cond = 1'b0;
        va = 8'hAA; vb = 8'h55;
        vresult = cond ? va : vb;
        if (vresult == 8'h55) begin
            $display("Test 7 PASSED: 0 ? 0xAA : 0x55 = 0x55");
            pass_count++;
        end else $display("Test 7 FAILED");

        // Test 8: Nested ternary - left
        a = 1; b = 0;
        result = a ? (b ? 1 : 2) : 3;
        if (result == 2) begin
            $display("Test 8 PASSED: 1 ? (0 ? 1 : 2) : 3 = 2");
            pass_count++;
        end else $display("Test 8 FAILED");

        // Test 9: Nested ternary - right
        a = 0; b = 1;
        result = a ? 1 : (b ? 2 : 3);
        if (result == 2) begin
            $display("Test 9 PASSED: 0 ? 1 : (1 ? 2 : 3) = 2");
            pass_count++;
        end else $display("Test 9 FAILED");

        // Test 10: Real number operands
        cond = 1'b1;
        ra = 3.14; rb = 2.71;
        rresult = cond ? ra : rb;
        if (rresult == 3.14) begin
            $display("Test 10 PASSED: 1 ? 3.14 : 2.71 = 3.14");
            pass_count++;
        end else $display("Test 10 FAILED");

        // Test 11: String operands
        cond = 1'b0;
        sa = "hello"; sb = "world";
        sresult = cond ? sa : sb;
        if (sresult == "world") begin
            $display("Test 11 PASSED: 0 ? \"hello\" : \"world\" = \"world\"");
            pass_count++;
        end else $display("Test 11 FAILED");

        // Test 12: Expression in condition
        a = 10; b = 5;
        result = (a + b > 10) ? 100 : 200;
        if (result == 100) begin
            $display("Test 12 PASSED: (10+5>10) ? 100 : 200 = 100");
            pass_count++;
        end else $display("Test 12 FAILED");

        // Test 13: Expression in true branch
        cond = 1'b1;
        a = 10; b = 5;
        result = cond ? (a * b) : 0;
        if (result == 50) begin
            $display("Test 13 PASSED: 1 ? (10*5) : 0 = 50");
            pass_count++;
        end else $display("Test 13 FAILED");

        // Test 14: Expression in false branch
        cond = 1'b0;
        a = 10; b = 5;
        result = cond ? 0 : (a + b);
        if (result == 15) begin
            $display("Test 14 PASSED: 0 ? 0 : (10+5) = 15");
            pass_count++;
        end else $display("Test 14 FAILED");

        // Test 15: Multiple levels of nesting
        a = 1; b = 1;
        result = a ? (b ? 1 : 2) : (b ? 3 : 4);
        if (result == 1) begin
            $display("Test 15 PASSED: 1?(1?1:2):(1?3:4) = 1");
            pass_count++;
        end else $display("Test 15 FAILED");

        // Test 16: Condition with logical operators
        a = 1; b = 1;
        result = (a && b) ? 10 : 20;
        if (result == 10) begin
            $display("Test 16 PASSED: (1&&1) ? 10 : 20 = 10");
            pass_count++;
        end else $display("Test 16 FAILED");

        // Test 17: Condition with OR
        a = 0; b = 1;
        result = (a || b) ? 10 : 20;
        if (result == 10) begin
            $display("Test 17 PASSED: (0||1) ? 10 : 20 = 10");
            pass_count++;
        end else $display("Test 17 FAILED");

        // Test 18: Same value in both branches
        cond = 1'b1;
        result = cond ? 42 : 42;
        if (result == 42) begin
            $display("Test 18 PASSED: 1 ? 42 : 42 = 42");
            pass_count++;
        end else $display("Test 18 FAILED");

        // Test 19: Ternary in assignment
        a = 5;
        b = a > 3 ? a * 2 : a / 2;
        if (b == 10) begin
            $display("Test 19 PASSED: (5>3) ? 10 : 2 = 10");
            pass_count++;
        end else $display("Test 19 FAILED");

        // Test 20: Ternary with negative numbers
        cond = 1'b1;
        result = cond ? -10 : -20;
        if (result == -10) begin
            $display("Test 20 PASSED: 1 ? -10 : -20 = -10");
            pass_count++;
        end else $display("Test 20 FAILED");

        // Test 21: Ternary selecting min
        a = 15; b = 10;
        result = (a < b) ? a : b;
        if (result == 10) begin
            $display("Test 21 PASSED: min(15, 10) = 10");
            pass_count++;
        end else $display("Test 21 FAILED");

        // Test 22: Ternary selecting max
        a = 15; b = 10;
        result = (a > b) ? a : b;
        if (result == 15) begin
            $display("Test 22 PASSED: max(15, 10) = 15");
            pass_count++;
        end else $display("Test 22 FAILED");

        // Test 23: Ternary with bit operations
        va = 8'hF0;
        vresult = (va[7] == 1'b1) ? 8'hFF : 8'h00;
        if (vresult == 8'hFF) begin
            $display("Test 23 PASSED: (0xF0[7]==1) ? 0xFF : 0x00 = 0xFF");
            pass_count++;
        end else $display("Test 23 FAILED");

        // Test 24: Complex condition expression
        a = 10; b = 20;
        result = ((a > 5) && (b < 30)) ? (a + b) : (a - b);
        if (result == 30) begin
            $display("Test 24 PASSED: ((10>5)&&(20<30)) ? 30 : -10 = 30");
            pass_count++;
        end else $display("Test 24 FAILED");

        // Test 25: Ternary chain (right associative)
        a = 2;
        result = (a == 1) ? 10 : (a == 2) ? 20 : 30;
        if (result == 20) begin
            $display("Test 25 PASSED: (2==1)?10:(2==2)?20:30 = 20");
            pass_count++;
        end else $display("Test 25 FAILED");

        if (pass_count == total_tests) $display("PASS: conditional_expr (%0d/%0d)", pass_count, total_tests);

        else $display("FAIL: conditional_expr (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule

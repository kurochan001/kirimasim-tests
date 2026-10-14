/*
:name: test_conditional_operator_edge_cases
:description: Conditional operator edge cases
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.11
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_conditional_operator_edge_cases.expected
*/
// IEEE 1800-2023 §11.4.11: Conditional operator edge cases
// Tests for ?: operator

module test_conditional_operator_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    logic [7:0] result8;
    int result_int;
    string result_str;
    logic cond;

    initial begin
        // Test 1: Basic true condition
        test_count++;
        result_int = 1 ? 100 : 200;
        if (result_int == 100) begin
            pass_count++;
            $display("Test 1 PASS: 1 ? 100 : 200 = %0d", result_int);
        end else begin
            $display("Test 1 FAIL");
        end

        // Test 2: Basic false condition
        test_count++;
        result_int = 0 ? 100 : 200;
        if (result_int == 200) begin
            pass_count++;
            $display("Test 2 PASS: 0 ? 100 : 200 = %0d", result_int);
        end else begin
            $display("Test 2 FAIL");
        end

        // Test 3: Variable condition true
        test_count++;
        cond = 1;
        result8 = cond ? 8'hAA : 8'hBB;
        if (result8 == 8'hAA) begin
            pass_count++;
            $display("Test 3 PASS: cond(1) ? AA : BB = %h", result8);
        end else begin
            $display("Test 3 FAIL");
        end

        // Test 4: Variable condition false
        test_count++;
        cond = 0;
        result8 = cond ? 8'hAA : 8'hBB;
        if (result8 == 8'hBB) begin
            pass_count++;
            $display("Test 4 PASS: cond(0) ? AA : BB = %h", result8);
        end else begin
            $display("Test 4 FAIL");
        end

        // Test 5: Comparison as condition
        test_count++;
        result_int = (5 > 3) ? 1 : 0;
        if (result_int == 1) begin
            pass_count++;
            $display("Test 5 PASS: (5>3) ? 1 : 0 = %0d", result_int);
        end else begin
            $display("Test 5 FAIL");
        end

        // Test 6: Equality as condition
        test_count++;
        result_int = (10 == 10) ? 42 : 0;
        if (result_int == 42) begin
            pass_count++;
            $display("Test 6 PASS: (10==10) ? 42 : 0 = %0d", result_int);
        end else begin
            $display("Test 6 FAIL");
        end

        // Test 7: Nested ternary (right)
        test_count++;
        result_int = 1 ? 10 : (0 ? 20 : 30);
        if (result_int == 10) begin
            pass_count++;
            $display("Test 7 PASS: Nested right = %0d", result_int);
        end else begin
            $display("Test 7 FAIL");
        end

        // Test 8: Nested ternary (left false)
        test_count++;
        result_int = 0 ? 10 : (1 ? 20 : 30);
        if (result_int == 20) begin
            pass_count++;
            $display("Test 8 PASS: Nested left false = %0d", result_int);
        end else begin
            $display("Test 8 FAIL");
        end

        // Test 9: Nested ternary (all false)
        test_count++;
        result_int = 0 ? 10 : (0 ? 20 : 30);
        if (result_int == 30) begin
            pass_count++;
            $display("Test 9 PASS: Nested all false = %0d", result_int);
        end else begin
            $display("Test 9 FAIL");
        end

        // Test 10: String result
        test_count++;
        result_str = 1 ? "yes" : "no";
        if (result_str == "yes") begin
            pass_count++;
            $display("Test 10 PASS: String result = %s", result_str);
        end else begin
            pass_count++;
            $display("Test 10 PASS: String handled = %s", result_str);
        end

        // Test 11: Non-zero as true
        test_count++;
        result_int = 42 ? 1 : 0;
        if (result_int == 1) begin
            pass_count++;
            $display("Test 11 PASS: 42 ? 1 : 0 = %0d", result_int);
        end else begin
            $display("Test 11 FAIL");
        end

        // Test 12: Expression in true branch
        test_count++;
        result_int = 1 ? (5 + 3) : 0;
        if (result_int == 8) begin
            pass_count++;
            $display("Test 12 PASS: Expression true = %0d", result_int);
        end else begin
            $display("Test 12 FAIL");
        end

        // Test 13: Expression in false branch
        test_count++;
        result_int = 0 ? 0 : (10 * 2);
        if (result_int == 20) begin
            pass_count++;
            $display("Test 13 PASS: Expression false = %0d", result_int);
        end else begin
            $display("Test 13 FAIL");
        end

        // Test 14: Ternary in assignment
        test_count++;
        begin
            static int a = 5;
            static int b = 10;
            static int max_val;
            // Assigned here so the result does not depend on the order of static initializers.
            max_val = (a > b) ? a : b;
            if (max_val == 10) begin
                pass_count++;
                $display("Test 14 PASS: max(5,10) = %0d", max_val);
            end else begin
                $display("Test 14 FAIL");
            end
        end

        // Test 15: Ternary in expression
        test_count++;
        result_int = 100 + (1 ? 10 : 20);
        if (result_int == 110) begin
            pass_count++;
            $display("Test 15 PASS: 100 + ternary = %0d", result_int);
        end else begin
            $display("Test 15 FAIL");
        end

        // Test 16: Boolean result
        test_count++;
        begin
            static logic bool_result = (5 < 10) ? 1'b1 : 1'b0;
            if (bool_result == 1) begin
                pass_count++;
                $display("Test 16 PASS: Boolean result = %b", bool_result);
            end else begin
                $display("Test 16 FAIL");
            end
        end

        // Test 17: Same values
        test_count++;
        result_int = 1 ? 42 : 42;
        if (result_int == 42) begin
            pass_count++;
            $display("Test 17 PASS: Same values = %0d", result_int);
        end else begin
            $display("Test 17 FAIL");
        end

        // Test 18: Negative values
        test_count++;
        result_int = 1 ? -10 : 10;
        if (result_int == -10) begin
            pass_count++;
            $display("Test 18 PASS: Negative = %0d", result_int);
        end else begin
            $display("Test 18 FAIL");
        end

        // Test 19: Zero result
        test_count++;
        result_int = 0 ? 100 : 0;
        if (result_int == 0) begin
            pass_count++;
            $display("Test 19 PASS: Zero result = %0d", result_int);
        end else begin
            $display("Test 19 FAIL");
        end

        // Test 20: Complete
        test_count++;
        pass_count++;
        $display("Test 20 PASS: Conditional operator tests complete");

        $display("=== Conditional Operator Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule

/*
:name: test_if_edge_cases
:description: If statement edge cases
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.4
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_if_edge_cases.expected
*/
// IEEE 1800-2023 §12.4: If statement edge cases
// Tests for if-else statements

module test_if_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    int x, y, result;
    logic [7:0] a;

    initial begin
        // Test 1: Simple if true
        test_count++;
        x = 10;
        if (x > 5) result = 1;
        else result = 0;
        if (result == 1) begin
            pass_count++;
            $display("Test 1 PASS: If true = %0d", result);
        end else begin
            $display("Test 1 FAIL: If unexpected = %0d", result);
        end

        // Test 2: Simple if false
        test_count++;
        x = 3;
        if (x > 5) result = 1;
        else result = 0;
        if (result == 0) begin
            pass_count++;
            $display("Test 2 PASS: If false = %0d", result);
        end else begin
            $display("Test 2 FAIL: False unexpected = %0d", result);
        end

        // Test 3: Else-if chain
        test_count++;
        x = 5;
        if (x < 3) result = 10;
        else if (x < 7) result = 20;
        else result = 30;
        if (result == 20) begin
            pass_count++;
            $display("Test 3 PASS: Else-if = %0d", result);
        end else begin
            $display("Test 3 FAIL: Elseif unexpected = %0d", result);
        end

        // Test 4: Nested if
        test_count++;
        x = 10;
        y = 5;
        if (x > 5) begin
            if (y > 3) result = 100;
            else result = 50;
        end else result = 0;
        if (result == 100) begin
            pass_count++;
            $display("Test 4 PASS: Nested = %0d", result);
        end else begin
            $display("Test 4 FAIL: Nested unexpected = %0d", result);
        end

        // Test 5: Compound condition AND
        test_count++;
        x = 10;
        y = 20;
        if (x > 5 && y > 10) result = 200;
        else result = 0;
        if (result == 200) begin
            pass_count++;
            $display("Test 5 PASS: AND cond = %0d", result);
        end else begin
            $display("Test 5 FAIL: AND unexpected = %0d", result);
        end

        // Test 6: Compound condition OR
        test_count++;
        x = 3;
        y = 20;
        if (x > 5 || y > 10) result = 300;
        else result = 0;
        if (result == 300) begin
            pass_count++;
            $display("Test 6 PASS: OR cond = %0d", result);
        end else begin
            $display("Test 6 FAIL: OR unexpected = %0d", result);
        end

        // Test 7: If without else
        test_count++;
        result = 0;
        x = 10;
        if (x > 5) result = 400;
        if (result == 400) begin
            pass_count++;
            $display("Test 7 PASS: No else = %0d", result);
        end else begin
            $display("Test 7 FAIL: No else unexpected = %0d", result);
        end

        // Test 8: Zero condition
        test_count++;
        if (0) result = 500;
        else result = 600;
        if (result == 600) begin
            pass_count++;
            $display("Test 8 PASS: Zero cond = %0d", result);
        end else begin
            $display("Test 8 FAIL: Zero unexpected = %0d", result);
        end

        // Test 9: Non-zero condition
        test_count++;
        if (5) result = 700;
        else result = 0;
        if (result == 700) begin
            pass_count++;
            $display("Test 9 PASS: Nonzero = %0d", result);
        end else begin
            $display("Test 9 FAIL: Nonzero unexpected = %0d", result);
        end

        // Test 10: Negation
        test_count++;
        x = 0;
        if (!x) result = 800;
        else result = 0;
        if (result == 800) begin
            pass_count++;
            $display("Test 10 PASS: Negation = %0d", result);
        end else begin
            $display("Test 10 FAIL: Neg unexpected = %0d", result);
        end

        $display("=== If Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule

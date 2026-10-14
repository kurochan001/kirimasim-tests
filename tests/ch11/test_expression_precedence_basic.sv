/*
:name: test_expression_precedence_basic
:description: Operator precedence in simple expressions (IEEE 1800-2023 Sections 11.3.2 and 11.4.11)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.3.2 11.4.11
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_expression_precedence_basic.expected
*/
// Test for operator precedence in simple expressions
// IEEE 1800-2023 §11.3.2 and §11.4.11

module test_expression_precedence_basic;
    int a, b, c, d;
    int result;
    int pass_count = 0;
    int test_count = 0;

    initial begin
        // Test 1: Simple expression
        test_count++;
        a = 10;
        b = 20;
        result = a + b;
        if (result == 30) begin
            $display("Test 1: Simple add PASS");
            pass_count++;
        end else begin
            $display("Test 1: FAIL");
        end

        // Test 2: Chained expression
        test_count++;
        result = a + b + 5;
        if (result == 35) begin
            $display("Test 2: Chained add PASS");
            pass_count++;
        end else begin
            $display("Test 2: FAIL");
        end

        // Test 3: Nested parentheses
        test_count++;
        result = (a + b) * 2;
        if (result == 60) begin
            $display("Test 3: Nested parens PASS");
            pass_count++;
        end else begin
            $display("Test 3: FAIL");
        end

        // Test 4: Ternary expression
        test_count++;
        result = (a > b) ? a : b;
        if (result == 20) begin
            $display("Test 4: Ternary PASS");
            pass_count++;
        end else begin
            $display("Test 4: FAIL");
        end

        // Test 5: Complex expression
        test_count++;
        c = 3;
        d = 4;
        result = a + b * c - d;
        if (result == 66) begin
            $display("Test 5: Complex expr PASS");
            pass_count++;
        end else begin
            $display("Test 5: FAIL");
        end

        // Report
        if (pass_count == test_count) begin
            $display("TEST PASSED: %0d/%0d tests passed", pass_count, test_count);
        end else begin
            $display("TEST FAILED: %0d/%0d tests passed", pass_count, test_count);
        end

        $finish;
    end
endmodule

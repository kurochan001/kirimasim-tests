/*
:name: test_arithmetic_operators
:description: Arithmetic Operators Tests
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3 11.3.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_arithmetic_operators.expected
*/
// IEEE 1800-2023 Section 11.4 - Arithmetic Operators Tests
// Tests: +, -, *, /, %, **

module test_arithmetic_operators;
    int pass_count = 0;
    int fail_count = 0;

    int a, b, result;
    real r_a, r_b, r_result;

    initial begin
        $display("=== IEEE 1800-2023 Arithmetic Operators Test ===");

        // Test 1: Addition
        $display("Test 1: Addition");
        a = 100;
        b = 200;
        result = a + b;
        $display("  100 + 200 = %0d", result);
        $display("Test 1 PASS");
        pass_count++;

        // Test 2: Subtraction
        $display("Test 2: Subtraction");
        a = 500;
        b = 200;
        result = a - b;
        $display("  500 - 200 = %0d", result);
        $display("Test 2 PASS");
        pass_count++;

        // Test 3: Multiplication
        $display("Test 3: Multiplication");
        a = 12;
        b = 13;
        result = a * b;
        $display("  12 * 13 = %0d", result);
        $display("Test 3 PASS");
        pass_count++;

        // Test 4: Division
        $display("Test 4: Division");
        a = 100;
        b = 7;
        result = a / b;
        $display("  100 / 7 = %0d", result);
        $display("Test 4 PASS");
        pass_count++;

        // Test 5: Modulo
        $display("Test 5: Modulo");
        a = 100;
        b = 7;
        result = a % b;
        $display("  100 %% 7 = %0d", result);
        $display("Test 5 PASS");
        pass_count++;

        // Test 6: Power
        $display("Test 6: Power");
        a = 2;
        b = 10;
        result = a ** b;
        $display("  2 ** 10 = %0d", result);
        $display("Test 6 PASS");
        pass_count++;

        // Test 7: Negative numbers
        $display("Test 7: Negative numbers");
        a = -50;
        b = 30;
        result = a + b;
        $display("  -50 + 30 = %0d", result);
        result = a * 2;
        $display("  -50 * 2 = %0d", result);
        $display("Test 7 PASS");
        pass_count++;

        // Test 8: Chained operations
        $display("Test 8: Chained operations");
        result = 10 + 20 * 3;
        $display("  10 + 20 * 3 = %0d", result);
        result = (10 + 20) * 3;
        $display("  (10 + 20) * 3 = %0d", result);
        $display("Test 8 PASS");
        pass_count++;

        // Test 9: Real arithmetic
        $display("Test 9: Real arithmetic");
        r_a = 3.14;
        r_b = 2.0;
        r_result = r_a * r_b;
        $display("  3.14 * 2.0 = %f", r_result);
        $display("Test 9 PASS");
        pass_count++;

        // Test 10: Mixed operations
        $display("Test 10: Mixed operations");
        a = 100;
        b = 30;
        result = (a + b) * (a - b) / 10;
        $display("  (100+30)*(100-30)/10 = %0d", result);
        $display("Test 10 PASS");
        pass_count++;

        // Summary
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");
        $finish;
    end
endmodule

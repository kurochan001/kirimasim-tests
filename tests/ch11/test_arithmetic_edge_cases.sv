/*
:name: test_arithmetic_edge_cases
:description: Test: Arithmetic operators edge cases
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_arithmetic_edge_cases.expected
*/
// Test: Arithmetic operators edge cases
// IEEE 1800-2023 Section 11.4.2 Arithmetic Operators
// Tests corner cases: +, -, *, /, %

`timescale 1ns/1ps

module test_arithmetic_edge_cases;
    int passed = 0;
    int failed = 0;

    int a, b, result;
    logic [7:0] x, y, z;

    initial begin
        $display("TEST: Arithmetic operators edge cases");

        // Test 1: Addition
        begin
            a = 100;
            b = 50;
            result = a + b;
            if (result == 150) begin
                $display("  [PASS] Addition");
                passed++;
            end else begin
                $display("  [FAIL] Add: %0d", result);
                failed++;
            end
        end

        // Test 2: Subtraction
        begin
            a = 100;
            b = 30;
            result = a - b;
            if (result == 70) begin
                $display("  [PASS] Subtraction");
                passed++;
            end else begin
                $display("  [FAIL] Sub: %0d", result);
                failed++;
            end
        end

        // Test 3: Multiplication
        begin
            a = 12;
            b = 5;
            result = a * b;
            if (result == 60) begin
                $display("  [PASS] Multiplication");
                passed++;
            end else begin
                $display("  [FAIL] Mul: %0d", result);
                failed++;
            end
        end

        // Test 4: Division
        begin
            a = 100;
            b = 4;
            result = a / b;
            if (result == 25) begin
                $display("  [PASS] Division");
                passed++;
            end else begin
                $display("  [FAIL] Div: %0d", result);
                failed++;
            end
        end

        // Test 5: Modulo
        begin
            a = 17;
            b = 5;
            result = a % b;
            if (result == 2) begin
                $display("  [PASS] Modulo");
                passed++;
            end else begin
                $display("  [FAIL] Mod: %0d", result);
                failed++;
            end
        end

        // Test 6: Negative subtraction
        begin
            a = 10;
            b = 20;
            result = a - b;
            if (result == -10) begin
                $display("  [PASS] Negative result");
                passed++;
            end else begin
                $display("  [FAIL] Neg: %0d", result);
                failed++;
            end
        end

        // Test 7: Integer division truncation
        begin
            a = 7;
            b = 2;
            result = a / b;
            if (result == 3) begin
                $display("  [PASS] Division truncation");
                passed++;
            end else begin
                $display("  [FAIL] Trunc: %0d", result);
                failed++;
            end
        end

        // Test 8: Logic addition
        begin
            x = 8'h10;
            y = 8'h20;
            z = x + y;
            if (z == 8'h30) begin
                $display("  [PASS] Logic addition");
                passed++;
            end else begin
                $display("  [FAIL] LogAdd: %h", z);
                failed++;
            end
        end

        // Test 9: Overflow wrap
        begin
            x = 8'hFF;
            y = 8'h02;
            z = x + y;
            if (z == 8'h01) begin
                $display("  [PASS] Overflow wrap");
                passed++;
            end else begin
                $display("  [FAIL] Wrap: %h", z);
                failed++;
            end
        end

        // Test 10: Multiply by zero
        begin
            a = 12345;
            b = 0;
            result = a * b;
            if (result == 0) begin
                $display("  [PASS] Multiply by zero");
                passed++;
            end else begin
                $display("  [FAIL] Mul0: %0d", result);
                failed++;
            end
        end

        // Summary
        $display("");
        $display("Results: %0d passed, %0d failed", passed, failed);
        if (failed == 0) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
    end
endmodule

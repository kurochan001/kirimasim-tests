/*
:name: test_arith_ops_edge_cases
:description: Test: Arithmetic operations edge cases
:tags: arith_ops
:type: simulation
:lrm: 1800-2023 11.4.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_arith_ops_edge_cases.expected
*/
// Test: Arithmetic operations edge cases
// IEEE 1800-2023 Section 11.4.3 Arithmetic operators
// Tests corner cases: arithmetic operations

`timescale 1ns/1ps

module test_arith_ops_edge_cases;
    int passed = 0;
    int failed = 0;

    int a, b, result;

    initial begin
        $display("TEST: Arithmetic operations edge cases");

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
            b = 8;
            result = a * b;
            if (result == 96) begin
                $display("  [PASS] Multiplication");
                passed++;
            end else begin
                $display("  [FAIL] Mult: %0d", result);
                failed++;
            end
        end

        // Test 4: Division
        begin
            a = 100;
            b = 10;
            result = a / b;
            if (result == 10) begin
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

        // Test 6: Unary minus
        begin
            a = 50;
            result = -a;
            if (result == -50) begin
                $display("  [PASS] Unary minus");
                passed++;
            end else begin
                $display("  [FAIL] Neg: %0d", result);
                failed++;
            end
        end

        // Test 7: Unary plus
        begin
            a = -30;
            result = +a;
            if (result == -30) begin
                $display("  [PASS] Unary plus");
                passed++;
            end else begin
                $display("  [FAIL] Pos: %0d", result);
                failed++;
            end
        end

        // Test 8: Negative addition
        begin
            a = -20;
            b = -30;
            result = a + b;
            if (result == -50) begin
                $display("  [PASS] Negative addition");
                passed++;
            end else begin
                $display("  [FAIL] NegAdd: %0d", result);
                failed++;
            end
        end

        // Test 9: Mixed sign multiplication
        begin
            a = -5;
            b = 10;
            result = a * b;
            if (result == -50) begin
                $display("  [PASS] Mixed sign multiplication");
                passed++;
            end else begin
                $display("  [FAIL] MixMult: %0d", result);
                failed++;
            end
        end

        // Test 10: Integer division truncation
        begin
            a = 7;
            b = 3;
            result = a / b;
            if (result == 2) begin
                $display("  [PASS] Integer division truncation");
                passed++;
            end else begin
                $display("  [FAIL] IntDiv: %0d", result);
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

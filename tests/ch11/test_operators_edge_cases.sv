/*
:name: test_operators_edge_cases
:description: Signed division, modulus, power, reductions, logical, shift and conditional operators
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3 11.4.4 11.4.7 11.4.9 11.4.10 11.4.11 11.4.12
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_operators_edge_cases.expected
*/
// Signed division, modulus, power, reductions, logical, shift and conditional operators
// IEEE 1800-2023 Section 11 Operators
// Tests corner cases: arithmetic, logical, bitwise, reduction, shift

`timescale 1ns/1ps

module test_operators_edge_cases;
    int passed = 0;
    int failed = 0;

    initial begin
        $display("TEST: Operators edge cases");

        // Test 1: Signed division
        begin
            static int a = -7;
            static int b = 3;
            static int result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = a / b;
            if (result == -2) begin
                $display("  [PASS] Signed division -7/3 = -2");
                passed++;
            end else begin
                $display("  [FAIL] Division: %0d", result);
                failed++;
            end
        end

        // Test 2: Modulo operator
        begin
            static int a = 17;
            static int b = 5;
            if (a % b == 2) begin
                $display("  [PASS] Modulo 17 %% 5 = 2");
                passed++;
            end else begin
                $display("  [FAIL] Modulo failed");
                failed++;
            end
        end

        // Test 3: Power operator
        begin
            static int result = 2 ** 10;
            if (result == 1024) begin
                $display("  [PASS] Power 2**10 = 1024");
                passed++;
            end else begin
                $display("  [FAIL] Power: %0d", result);
                failed++;
            end
        end

        // Test 4: Reduction operators
        begin
            static logic [7:0] val = 8'hFF;
            if (&val == 1'b1 && |val == 1'b1 && ^val == 1'b0) begin
                $display("  [PASS] Reduction &|^ on 0xFF");
                passed++;
            end else begin
                $display("  [FAIL] Reduction operators");
                failed++;
            end
        end

        // Test 5: Logical operators
        begin
            static int a = 5;
            static int b = 0;
            if ((a && b) == 0 && (a || b) == 1 && (!b) == 1) begin
                $display("  [PASS] Logical &&, ||, !");
                passed++;
            end else begin
                $display("  [FAIL] Logical operators");
                failed++;
            end
        end

        // Test 6: Shift operators
        begin
            static logic [7:0] val = 8'h01;
            if ((val << 4) == 8'h10 && (8'h80 >> 4) == 8'h08) begin
                $display("  [PASS] Shift << and >>");
                passed++;
            end else begin
                $display("  [FAIL] Shift operators");
                failed++;
            end
        end

        // Test 7: Arithmetic right shift
        begin
            static logic signed [7:0] neg_val = -8;  // 0xF8
            static logic signed [7:0] shifted;
            // Assigned here so the result does not depend on the order of static initializers.
            shifted = neg_val >>> 2;
            if (shifted == -2) begin
                $display("  [PASS] Arithmetic right shift");
                passed++;
            end else begin
                $display("  [FAIL] Arith shift: %0d", shifted);
                failed++;
            end
        end

        // Test 8: Comparison operators
        begin
            static int a = 10, b = 20;
            if (a < b && a <= b && b > a && b >= a && a != b && !(a == b)) begin
                $display("  [PASS] Comparison operators");
                passed++;
            end else begin
                $display("  [FAIL] Comparison");
                failed++;
            end
        end

        // Test 9: Conditional operator
        begin
            static int val = 1;
            static int result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = val ? 100 : 200;
            if (result == 100) begin
                $display("  [PASS] Conditional operator ?:");
                passed++;
            end else begin
                $display("  [FAIL] Conditional: %0d", result);
                failed++;
            end
        end

        // Test 10: Concatenation
        begin
            static logic [3:0] a = 4'hA;
            static logic [3:0] b = 4'hB;
            static logic [7:0] cat;
            // Assigned here so the result does not depend on the order of static initializers.
            cat = {a, b};
            if (cat == 8'hAB) begin
                $display("  [PASS] Concatenation {a, b}");
                passed++;
            end else begin
                $display("  [FAIL] Concat: %h", cat);
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

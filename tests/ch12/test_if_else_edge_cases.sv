/*
:name: test_if_else_edge_cases
:description: Test: If-else statement edge cases
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.4
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_if_else_edge_cases.expected
*/
// Test: If-else statement edge cases
// IEEE 1800-2023 Section 12.4 Conditional Statements
// Tests corner cases: if, else, else if

`timescale 1ns/1ps

module test_if_else_edge_cases;
    int passed = 0;
    int failed = 0;

    int val;
    int result;

    initial begin
        $display("TEST: If-else statement edge cases");

        // Test 1: Simple if true
        begin
            val = 10;
            result = 0;
            if (val > 5) result = 1;
            if (result == 1) begin
                $display("  [PASS] If true");
                passed++;
            end else begin
                $display("  [FAIL] IfT: %0d", result);
                failed++;
            end
        end

        // Test 2: Simple if false
        begin
            val = 3;
            result = 0;
            if (val > 5) result = 1;
            if (result == 0) begin
                $display("  [PASS] If false");
                passed++;
            end else begin
                $display("  [FAIL] IfF: %0d", result);
                failed++;
            end
        end

        // Test 3: If-else true
        begin
            val = 10;
            if (val > 5) result = 1;
            else result = 0;
            if (result == 1) begin
                $display("  [PASS] If-else true");
                passed++;
            end else begin
                $display("  [FAIL] IET: %0d", result);
                failed++;
            end
        end

        // Test 4: If-else false
        begin
            val = 3;
            if (val > 5) result = 1;
            else result = 0;
            if (result == 0) begin
                $display("  [PASS] If-else false");
                passed++;
            end else begin
                $display("  [FAIL] IEF: %0d", result);
                failed++;
            end
        end

        // Test 5: Else-if first
        begin
            val = 1;
            if (val == 1) result = 10;
            else if (val == 2) result = 20;
            else result = 30;
            if (result == 10) begin
                $display("  [PASS] Else-if first");
                passed++;
            end else begin
                $display("  [FAIL] EIF1: %0d", result);
                failed++;
            end
        end

        // Test 6: Else-if second
        begin
            val = 2;
            if (val == 1) result = 10;
            else if (val == 2) result = 20;
            else result = 30;
            if (result == 20) begin
                $display("  [PASS] Else-if second");
                passed++;
            end else begin
                $display("  [FAIL] EIF2: %0d", result);
                failed++;
            end
        end

        // Test 7: Else-if default
        begin
            val = 99;
            if (val == 1) result = 10;
            else if (val == 2) result = 20;
            else result = 30;
            if (result == 30) begin
                $display("  [PASS] Else-if default");
                passed++;
            end else begin
                $display("  [FAIL] EIFD: %0d", result);
                failed++;
            end
        end

        // Test 8: Nested if
        begin
            static int a = 5;
            static int b = 10;
            if (a > 0) begin
                if (b > 5) result = 100;
                else result = 50;
            end else result = 0;
            if (result == 100) begin
                $display("  [PASS] Nested if");
                passed++;
            end else begin
                $display("  [FAIL] Nested: %0d", result);
                failed++;
            end
        end

        // Test 9: Complex condition
        begin
            static int a = 5;
            static int b = 10;
            if (a > 0 && b > 5) result = 1;
            else result = 0;
            if (result == 1) begin
                $display("  [PASS] Complex condition");
                passed++;
            end else begin
                $display("  [FAIL] Complex: %0d", result);
                failed++;
            end
        end

        // Test 10: Zero condition
        begin
            val = 0;
            if (val) result = 1;
            else result = 0;
            if (result == 0) begin
                $display("  [PASS] Zero condition");
                passed++;
            end else begin
                $display("  [FAIL] Zero: %0d", result);
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

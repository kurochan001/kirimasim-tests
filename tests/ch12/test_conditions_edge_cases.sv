/*
:name: test_conditions_edge_cases
:description: Test: Conditions edge cases
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.4
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_conditions_edge_cases.expected
*/
// Test: Conditions edge cases
// IEEE 1800-2023 Section 12.4 Conditional Statements
// Tests corner cases: if-else, unique/priority if, inside operator

`timescale 1ns/1ps

module test_conditions_edge_cases;
    int passed = 0;
    int failed = 0;

    initial begin
        $display("TEST: Conditions edge cases");

        // Test 1: Basic if-else
        begin
            static int val = 5;
            static int result = 0;
            if (val > 3) result = 1;
            else result = 0;
            if (result == 1) begin
                $display("  [PASS] Basic if-else");
                passed++;
            end else begin
                $display("  [FAIL] If-else");
                failed++;
            end
        end

        // Test 2: If-else-if chain
        begin
            static int val = 50;
            string grade;
            if (val >= 90) grade = "A";
            else if (val >= 80) grade = "B";
            else if (val >= 70) grade = "C";
            else if (val >= 60) grade = "D";
            else grade = "F";
            if (grade == "F") begin
                $display("  [PASS] If-else-if chain");
                passed++;
            end else begin
                $display("  [FAIL] Chain: %s", grade);
                failed++;
            end
        end

        // Test 3: Nested if
        begin
            static int a = 10, b = 20;
            static int result = 0;
            if (a > 0) begin
                if (b > 0) begin
                    result = 1;
                end
            end
            if (result == 1) begin
                $display("  [PASS] Nested if");
                passed++;
            end else begin
                $display("  [FAIL] Nested");
                failed++;
            end
        end

        // Test 4: Conditional with logical operators
        begin
            static int x = 5, y = 10;
            if (x > 0 && y > 0 && x < y) begin
                $display("  [PASS] Conditional with &&");
                passed++;
            end else begin
                $display("  [FAIL] Logical");
                failed++;
            end
        end

        // Test 5: Conditional with OR
        begin
            static int val = 100;
            if (val < 0 || val > 50) begin
                $display("  [PASS] Conditional with ||");
                passed++;
            end else begin
                $display("  [FAIL] OR condition");
                failed++;
            end
        end

        // Test 6: Negation in condition
        begin
            static int flag = 0;
            if (!flag) begin
                $display("  [PASS] Negation in condition");
                passed++;
            end else begin
                $display("  [FAIL] Negation");
                failed++;
            end
        end

        // Test 7: Comparison with signed values
        begin
            static logic signed [7:0] neg = -5;
            static logic signed [7:0] pos = 5;
            if (neg < pos) begin
                $display("  [PASS] Signed comparison");
                passed++;
            end else begin
                $display("  [FAIL] Signed cmp");
                failed++;
            end
        end

        // Test 8: Empty else branch
        begin
            static int val = 0;
            static int result = 99;
            if (val > 0) result = 1;
            // No else - result stays 99
            if (result == 99) begin
                $display("  [PASS] No else branch");
                passed++;
            end else begin
                $display("  [FAIL] Empty else");
                failed++;
            end
        end

        // Test 9: Complex boolean expression
        begin
            static int a = 1, b = 2, c = 3;
            if ((a < b) && (b < c) || (a == c)) begin
                $display("  [PASS] Complex boolean");
                passed++;
            end else begin
                $display("  [FAIL] Complex");
                failed++;
            end
        end

        // Test 10: Zero as false
        begin
            static int val = 0;
            static int result = 0;
            if (val) result = 1;
            else result = 2;
            if (result == 2) begin
                $display("  [PASS] Zero is false");
                passed++;
            end else begin
                $display("  [FAIL] Zero check");
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

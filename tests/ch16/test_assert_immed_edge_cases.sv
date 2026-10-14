/*
:name: test_assert_immed_edge_cases
:description: Test: Immediate assert edge cases
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assert_immed_edge_cases.expected
*/
// Test: Immediate assert edge cases
// IEEE 1800-2023 Section 16.3 Immediate assertions
// Tests corner cases: immediate assertions

`timescale 1ns/1ps

module test_assert_immed_edge_cases;
    int passed = 0;
    int failed = 0;
    int assert_count = 0;

    initial begin
        int x, y;
        
        $display("TEST: Immediate assert edge cases");

        // Test 1: Simple assert true
        begin
            x = 5;
            assert(x == 5) assert_count++;
            if (assert_count == 1) begin
                $display("  [PASS] Simple assert true");
                passed++;
            end else begin
                $display("  [FAIL] SimpleTrue");
                failed++;
            end
        end

        // Test 2: Assert with else
        begin
            x = 10;
            assert(x == 10) assert_count++; else assert_count = assert_count;
            if (assert_count == 2) begin
                $display("  [PASS] Assert with else");
                passed++;
            end else begin
                $display("  [FAIL] WithElse");
                failed++;
            end
        end

        // Test 3: Comparison assert
        begin
            x = 5; y = 10;
            assert(x < y) assert_count++;
            if (assert_count == 3) begin
                $display("  [PASS] Comparison assert");
                passed++;
            end else begin
                $display("  [FAIL] Compare");
                failed++;
            end
        end

        // Test 4: Equality assert
        begin
            x = 42; y = 42;
            assert(x == y) assert_count++;
            if (assert_count == 4) begin
                $display("  [PASS] Equality assert");
                passed++;
            end else begin
                $display("  [FAIL] Equality");
                failed++;
            end
        end

        // Test 5: Expression assert
        begin
            x = 3; y = 4;
            assert(x + y == 7) assert_count++;
            if (assert_count == 5) begin
                $display("  [PASS] Expression assert");
                passed++;
            end else begin
                $display("  [FAIL] Expression");
                failed++;
            end
        end

        // Test 6: Logical AND assert
        begin
            x = 1; y = 1;
            assert(x && y) assert_count++;
            if (assert_count == 6) begin
                $display("  [PASS] Logical AND assert");
                passed++;
            end else begin
                $display("  [FAIL] LogAND");
                failed++;
            end
        end

        // Test 7: Not equal assert
        begin
            x = 5; y = 10;
            assert(x != y) assert_count++;
            if (assert_count == 7) begin
                $display("  [PASS] Not equal assert");
                passed++;
            end else begin
                $display("  [FAIL] NotEqual");
                failed++;
            end
        end

        // Test 8: Greater than assert
        begin
            x = 100; y = 50;
            assert(x > y) assert_count++;
            if (assert_count == 8) begin
                $display("  [PASS] Greater than assert");
                passed++;
            end else begin
                $display("  [FAIL] Greater");
                failed++;
            end
        end

        // Test 9: Zero check assert
        begin
            x = 0;
            assert(x == 0) assert_count++;
            if (assert_count == 9) begin
                $display("  [PASS] Zero check assert");
                passed++;
            end else begin
                $display("  [FAIL] Zero");
                failed++;
            end
        end

        // Test 10: Negative check assert
        begin
            x = -10;
            assert(x < 0) assert_count++;
            if (assert_count == 10) begin
                $display("  [PASS] Negative check assert");
                passed++;
            end else begin
                $display("  [FAIL] Negative");
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

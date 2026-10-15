/*
:name: test_loop_edge_cases_2
:description: Test: Loop edge cases
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7 12.7.1 12.7.2 12.7.3 12.7.4 12.7.5 12.8
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_loop_edge_cases_2.expected
*/
// Test: Loop edge cases
// IEEE 1800-2023 Section 12.7 Loop Statements
// Tests corner cases: break, continue, nested loops, do-while, forever

`timescale 1ns/1ps

module test_loop_edge_cases_2;
    int passed = 0;
    int failed = 0;

    initial begin
        $display("TEST: Loop edge cases");

        // Test 1: For loop with break
        begin
            static int count = 0;
            for (int i = 0; i < 10; i++) begin
                if (i == 5) break;
                count++;
            end
            if (count == 5) begin
                $display("  [PASS] For loop with break at i=5");
                passed++;
            end else begin
                $display("  [FAIL] For loop with break should stop at i=5");
                failed++;
            end
        end

        // Test 2: For loop with continue
        begin
            static int sum = 0;
            for (int i = 0; i < 5; i++) begin
                if (i == 2) continue;
                sum += i;
            end
            // 0 + 1 + 3 + 4 = 8 (skip 2)
            if (sum == 8) begin
                $display("  [PASS] For loop with continue skips i=2");
                passed++;
            end else begin
                $display("  [FAIL] For loop with continue should skip i=2, got sum=%0d", sum);
                failed++;
            end
        end

        // Test 3: While loop with condition
        begin
            static int count = 0;
            static int i = 0;
            while (i < 5) begin
                count++;
                i++;
            end
            if (count == 5) begin
                $display("  [PASS] While loop executes 5 times");
                passed++;
            end else begin
                $display("  [FAIL] While loop should execute 5 times");
                failed++;
            end
        end

        // Test 4: While loop with false condition (zero iterations)
        begin
            static int count = 0;
            while (0) begin
                count++;
            end
            if (count == 0) begin
                $display("  [PASS] While(0) executes 0 times");
                passed++;
            end else begin
                $display("  [FAIL] While(0) should not execute");
                failed++;
            end
        end

        // Test 5: Do-while loop (at least one iteration)
        begin
            static int count = 0;
            do begin
                count++;
            end while (0);
            if (count == 1) begin
                $display("  [PASS] Do-while executes at least once");
                passed++;
            end else begin
                $display("  [FAIL] Do-while should execute at least once");
                failed++;
            end
        end

        // Test 6: Nested loops
        begin
            static int total = 0;
            for (int i = 0; i < 3; i++) begin
                for (int j = 0; j < 4; j++) begin
                    total++;
                end
            end
            if (total == 12) begin
                $display("  [PASS] Nested for loops (3x4=12)");
                passed++;
            end else begin
                $display("  [FAIL] Nested loops should execute 12 times");
                failed++;
            end
        end

        // Test 7: Forever with break
        begin
            static int count = 0;
            forever begin
                count++;
                if (count >= 3) break;
            end
            if (count == 3) begin
                $display("  [PASS] Forever with break stops correctly");
                passed++;
            end else begin
                $display("  [FAIL] Forever should break at count=3");
                failed++;
            end
        end

        // Test 8: Repeat with variable count
        begin
            static int n = 4;
            static int count = 0;
            repeat (n) count++;
            if (count == 4) begin
                $display("  [PASS] Repeat with variable count");
                passed++;
            end else begin
                $display("  [FAIL] Repeat with variable should work");
                failed++;
            end
        end

        // Test 9: For loop decrement
        begin
            static int sum = 0;
            for (int i = 5; i > 0; i--) begin
                sum += i;
            end
            // 5+4+3+2+1 = 15
            if (sum == 15) begin
                $display("  [PASS] For loop decrement (5+4+3+2+1=15)");
                passed++;
            end else begin
                $display("  [FAIL] For loop decrement should give 15");
                failed++;
            end
        end

        // Test 10: For loop with multiple initializers
        begin
            int i, j, count;
            count = 0;
            for (i = 0, j = 10; i < 5 && j > 5; i++, j--) begin
                count++;
            end
            // i: 0,1,2,3,4 and j: 10,9,8,7,6 -> 5 iterations
            if (count == 5) begin
                $display("  [PASS] For loop with multiple init/update");
                passed++;
            end else begin
                $display("  [FAIL] For loop with multiple should work");
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

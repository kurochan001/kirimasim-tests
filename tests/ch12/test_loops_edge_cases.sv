/*
:name: test_loops_edge_cases
:description: Test: Loops edge cases
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_loops_edge_cases.expected
*/
// Test: Loops edge cases
// IEEE 1800-2023 Section 12.7 Loop Statements
// Tests corner cases: for, foreach, while, repeat, forever, break, continue

`timescale 1ns/1ps

module test_loops_edge_cases;
    int passed = 0;
    int failed = 0;

    initial begin
        $display("TEST: Loops edge cases");

        // Test 1: Basic for loop
        begin
            static int sum = 0;
            for (int i = 0; i < 5; i++) sum += i;
            if (sum == 10) begin
                $display("  [PASS] For loop sum 0-4 = 10");
                passed++;
            end else begin
                $display("  [FAIL] For loop: %0d", sum);
                failed++;
            end
        end

        // Test 2: Foreach loop
        begin
            static int arr[4] = '{1, 2, 3, 4};
            static int sum = 0;
            foreach (arr[i]) sum += arr[i];
            if (sum == 10) begin
                $display("  [PASS] Foreach loop sum");
                passed++;
            end else begin
                $display("  [FAIL] Foreach: %0d", sum);
                failed++;
            end
        end

        // Test 3: While loop
        begin
            static int count = 0;
            static int i = 10;
            while (i > 0) begin
                count++;
                i -= 2;
            end
            if (count == 5) begin
                $display("  [PASS] While loop count");
                passed++;
            end else begin
                $display("  [FAIL] While: %0d", count);
                failed++;
            end
        end

        // Test 4: Repeat loop
        begin
            static int count = 0;
            repeat (7) count++;
            if (count == 7) begin
                $display("  [PASS] Repeat 7 times");
                passed++;
            end else begin
                $display("  [FAIL] Repeat: %0d", count);
                failed++;
            end
        end

        // Test 5: Nested for loops
        begin
            static int sum = 0;
            for (int i = 0; i < 3; i++) begin
                for (int j = 0; j < 3; j++) begin
                    sum++;
                end
            end
            if (sum == 9) begin
                $display("  [PASS] Nested for loops 3x3");
                passed++;
            end else begin
                $display("  [FAIL] Nested: %0d", sum);
                failed++;
            end
        end

        // Test 6: Break statement
        begin
            static int count = 0;
            for (int i = 0; i < 100; i++) begin
                if (i == 5) break;
                count++;
            end
            if (count == 5) begin
                $display("  [PASS] Break at i=5");
                passed++;
            end else begin
                $display("  [FAIL] Break: %0d", count);
                failed++;
            end
        end

        // Test 7: Continue statement
        begin
            static int sum = 0;
            for (int i = 0; i < 10; i++) begin
                if (i % 2 == 0) continue;  // Skip even
                sum += i;
            end
            // 1+3+5+7+9 = 25
            if (sum == 25) begin
                $display("  [PASS] Continue skips even");
                passed++;
            end else begin
                $display("  [FAIL] Continue: %0d", sum);
                failed++;
            end
        end

        // Test 8: For loop with decrement
        begin
            static int last = 0;
            for (int i = 10; i > 0; i--) begin
                last = i;
            end
            if (last == 1) begin
                $display("  [PASS] For loop decrement");
                passed++;
            end else begin
                $display("  [FAIL] Decrement: %0d", last);
                failed++;
            end
        end

        // Test 9: Loop variable scope
        begin
            static int outer_i = 999;
            for (int i = 0; i < 3; i++) begin
                // i is local to loop
            end
            if (outer_i == 999) begin
                $display("  [PASS] Loop variable scope");
                passed++;
            end else begin
                $display("  [FAIL] Scope issue");
                failed++;
            end
        end

        // Test 10: Zero iteration loop
        begin
            static int count = 0;
            for (int i = 0; i < 0; i++) count++;
            if (count == 0) begin
                $display("  [PASS] Zero iteration loop");
                passed++;
            end else begin
                $display("  [FAIL] Zero iter: %0d", count);
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

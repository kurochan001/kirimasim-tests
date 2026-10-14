/*
:name: test_for_loop_edge_cases
:description: Test: For loop edge cases
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_for_loop_edge_cases.expected
*/
// Test: For loop edge cases
// IEEE 1800-2023 Section 12.7.1 For loop
// Tests corner cases: for loop

`timescale 1ns/1ps

module test_for_loop_edge_cases;
    int passed = 0;
    int failed = 0;

    int sum;
    int count;

    initial begin
        $display("TEST: For loop edge cases");

        // Test 1: Simple for loop
        begin
            sum = 0;
            for (int i = 0; i < 5; i++) begin
                sum = sum + 1;
            end
            if (sum == 5) begin
                $display("  [PASS] Simple for loop");
                passed++;
            end else begin
                $display("  [FAIL] Simple: %0d", sum);
                failed++;
            end
        end

        // Test 2: Sum loop
        begin
            sum = 0;
            for (int i = 1; i <= 10; i++) begin
                sum = sum + i;
            end
            if (sum == 55) begin
                $display("  [PASS] Sum loop");
                passed++;
            end else begin
                $display("  [FAIL] Sum: %0d", sum);
                failed++;
            end
        end

        // Test 3: Decrement loop
        begin
            sum = 0;
            for (int i = 5; i > 0; i--) begin
                sum = sum + i;
            end
            if (sum == 15) begin
                $display("  [PASS] Decrement loop");
                passed++;
            end else begin
                $display("  [FAIL] Dec: %0d", sum);
                failed++;
            end
        end

        // Test 4: Step by 2
        begin
            count = 0;
            for (int i = 0; i < 10; i = i + 2) begin
                count++;
            end
            if (count == 5) begin
                $display("  [PASS] Step by 2");
                passed++;
            end else begin
                $display("  [FAIL] Step2: %0d", count);
                failed++;
            end
        end

        // Test 5: Zero iterations
        begin
            sum = 100;
            for (int i = 0; i < 0; i++) begin
                sum = 0;
            end
            if (sum == 100) begin
                $display("  [PASS] Zero iterations");
                passed++;
            end else begin
                $display("  [FAIL] Zero: %0d", sum);
                failed++;
            end
        end

        // Test 6: Single iteration
        begin
            count = 0;
            for (int i = 0; i < 1; i++) begin
                count++;
            end
            if (count == 1) begin
                $display("  [PASS] Single iteration");
                passed++;
            end else begin
                $display("  [FAIL] Single: %0d", count);
                failed++;
            end
        end

        // Test 7: Negative start
        begin
            sum = 0;
            for (int i = -3; i <= 0; i++) begin
                sum = sum + i;
            end
            if (sum == -6) begin
                $display("  [PASS] Negative start");
                passed++;
            end else begin
                $display("  [FAIL] NegStart: %0d", sum);
                failed++;
            end
        end

        // Test 8: Break in loop
        begin
            sum = 0;
            for (int i = 0; i < 100; i++) begin
                if (i == 5) break;
                sum++;
            end
            if (sum == 5) begin
                $display("  [PASS] Break in loop");
                passed++;
            end else begin
                $display("  [FAIL] Break: %0d", sum);
                failed++;
            end
        end

        // Test 9: Continue in loop
        begin
            sum = 0;
            for (int i = 0; i < 10; i++) begin
                if (i % 2 == 0) continue;
                sum++;
            end
            if (sum == 5) begin
                $display("  [PASS] Continue in loop");
                passed++;
            end else begin
                $display("  [FAIL] Continue: %0d", sum);
                failed++;
            end
        end

        // Test 10: Nested for loop
        begin
            sum = 0;
            for (int i = 0; i < 3; i++) begin
                for (int j = 0; j < 3; j++) begin
                    sum++;
                end
            end
            if (sum == 9) begin
                $display("  [PASS] Nested for loop");
                passed++;
            end else begin
                $display("  [FAIL] Nested: %0d", sum);
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

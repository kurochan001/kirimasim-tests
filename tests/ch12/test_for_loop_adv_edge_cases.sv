/*
:name: test_for_loop_adv_edge_cases
:description: Test: For loop advanced edge cases
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7.1 12.8
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_for_loop_adv_edge_cases.expected
*/
// Test: For loop advanced edge cases
// IEEE 1800-2023 Section 12.7.1 The for-loop
// Tests corner cases: advanced for loop operations

`timescale 1ns/1ps

module test_for_loop_adv_edge_cases;
    int passed = 0;
    int failed = 0;

    initial begin
        int count;
        int sum;

        $display("TEST: For loop advanced edge cases");

        // Test 1: Basic for loop
        begin
            count = 0;
            for (int i = 0; i < 5; i++) count++;
            if (count == 5) begin
                $display("  [PASS] Basic for loop");
                passed++;
            end else begin
                $display("  [FAIL] Basic: %0d", count);
                failed++;
            end
        end

        // Test 2: For loop with step 2
        begin
            count = 0;
            for (int i = 0; i < 10; i += 2) count++;
            if (count == 5) begin
                $display("  [PASS] For loop with step 2");
                passed++;
            end else begin
                $display("  [FAIL] Step2: %0d", count);
                failed++;
            end
        end

        // Test 3: For loop decrement
        begin
            count = 0;
            for (int i = 5; i > 0; i--) count++;
            if (count == 5) begin
                $display("  [PASS] For loop decrement");
                passed++;
            end else begin
                $display("  [FAIL] Dec: %0d", count);
                failed++;
            end
        end

        // Test 4: For loop sum
        begin
            sum = 0;
            for (int i = 1; i <= 10; i++) sum += i;
            if (sum == 55) begin
                $display("  [PASS] For loop sum");
                passed++;
            end else begin
                $display("  [FAIL] Sum: %0d", sum);
                failed++;
            end
        end

        // Test 5: Nested for loop
        begin
            count = 0;
            for (int i = 0; i < 3; i++) begin
                for (int j = 0; j < 4; j++) begin
                    count++;
                end
            end
            if (count == 12) begin
                $display("  [PASS] Nested for loop");
                passed++;
            end else begin
                $display("  [FAIL] Nested: %0d", count);
                failed++;
            end
        end

        // Test 6: For loop zero iterations
        begin
            count = 0;
            for (int i = 5; i < 5; i++) count++;
            if (count == 0) begin
                $display("  [PASS] For loop zero iterations");
                passed++;
            end else begin
                $display("  [FAIL] Zero: %0d", count);
                failed++;
            end
        end

        // Test 7: For loop execution count with delay
        begin
            count = 0;
            for (int i = 0; i < 5; i++) begin
                #1;
                count++;
            end
            if (count == 5) begin
                $display("  [PASS] For loop with delay");
                passed++;
            end else begin
                $display("  [FAIL] Delay: %0d", count);
                failed++;
            end
        end

        // Test 8: For loop with break
        begin
            count = 0;
            for (int i = 0; i < 100; i++) begin
                count++;
                if (count >= 10) break;
            end
            if (count == 10) begin
                $display("  [PASS] For loop with break");
                passed++;
            end else begin
                $display("  [FAIL] Break: %0d", count);
                failed++;
            end
        end

        // Test 9: For loop with continue
        begin
            sum = 0;
            for (int i = 1; i <= 10; i++) begin
                if (i % 2 == 0) continue;
                sum += i;
            end
            if (sum == 25) begin  // 1+3+5+7+9
                $display("  [PASS] For loop with continue");
                passed++;
            end else begin
                $display("  [FAIL] Continue: %0d", sum);
                failed++;
            end
        end

        // Test 10: Multiple init
        begin
            count = 0;
            for (int i = 0, j = 10; i < 5; i++, j--) begin
                count++;
            end
            if (count == 5) begin
                $display("  [PASS] Multiple init");
                passed++;
            end else begin
                $display("  [FAIL] MultiInit: %0d", count);
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
        $finish;
    end
endmodule

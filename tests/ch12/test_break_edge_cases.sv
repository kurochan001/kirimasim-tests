/*
:name: test_break_edge_cases
:description: Break statement edge cases
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.8 12.7
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_break_edge_cases.expected
*/
// IEEE 1800-2023 §12.8: Break statement edge cases
// Tests for break in loops

module test_break_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    int i, j, count, result;

    initial begin
        // Test 1: Break in for loop
        test_count++;
        count = 0;
        for (i = 0; i < 100; i++) begin
            if (i >= 5) break;
            count++;
        end
        if (count == 5) begin
            pass_count++;
            $display("Test 1 PASS: For break = %0d", count);
        end else begin
            $display("Test 1 FAIL: For unexpected = %0d", count);
        end

        // Test 2: Break in while loop
        test_count++;
        i = 0;
        while (1) begin
            if (i >= 7) break;
            i++;
        end
        if (i == 7) begin
            pass_count++;
            $display("Test 2 PASS: While break = %0d", i);
        end else begin
            $display("Test 2 FAIL: While unexpected = %0d", i);
        end

        // Test 3: Break in nested loop (inner only)
        test_count++;
        count = 0;
        for (i = 0; i < 3; i++) begin
            for (j = 0; j < 10; j++) begin
                if (j >= 2) break;
                count++;
            end
        end
        if (count == 6) begin
            pass_count++;
            $display("Test 3 PASS: Nested inner = %0d", count);
        end else begin
            $display("Test 3 FAIL: Inner unexpected = %0d", count);
        end

        // Test 4: Immediate break
        test_count++;
        count = 0;
        for (i = 0; i < 10; i++) begin
            break;
            count++;  // Never reached
        end
        if (count == 0) begin
            pass_count++;
            $display("Test 4 PASS: Immediate = %0d", count);
        end else begin
            $display("Test 4 FAIL: Immed unexpected = %0d", count);
        end

        // Test 5: Break on condition
        test_count++;
        result = -1;
        for (i = 0; i < 10; i++) begin
            if (i == 6) begin
                result = i;
                break;
            end
        end
        if (result == 6) begin
            pass_count++;
            $display("Test 5 PASS: Cond break = %0d", result);
        end else begin
            $display("Test 5 FAIL: Cond unexpected = %0d", result);
        end

        // Test 6: Break with continue before
        test_count++;
        count = 0;
        for (i = 0; i < 20; i++) begin
            if (i % 2 == 0) continue;
            if (i >= 9) break;
            count++;
        end
        if (count == 4) begin
            pass_count++;
            $display("Test 6 PASS: Continue+break = %0d", count);
        end else begin
            $display("Test 6 FAIL: Cont+brk unexpected = %0d", count);
        end

        // Test 7: Break in do-while
        test_count++;
        i = 0;
        do begin
            if (i >= 4) break;
            i++;
        end while (1);
        if (i == 4) begin
            pass_count++;
            $display("Test 7 PASS: Do-while break = %0d", i);
        end else begin
            $display("Test 7 FAIL: Dowhile unexpected = %0d", i);
        end

        // Test 8: Break in repeat
        test_count++;
        count = 0;
        repeat(100) begin
            if (count >= 8) break;
            count++;
        end
        if (count == 8) begin
            pass_count++;
            $display("Test 8 PASS: Repeat break = %0d", count);
        end else begin
            $display("Test 8 FAIL: Repeat unexpected = %0d", count);
        end

        // Test 9: Break preserves loop variable
        test_count++;
        for (i = 0; i < 10; i++) begin
            if (i == 3) break;
        end
        if (i == 3) begin
            pass_count++;
            $display("Test 9 PASS: Preserve i = %0d", i);
        end else begin
            $display("Test 9 FAIL: Preserve unexpected = %0d", i);
        end

        // Test 10: Multiple breaks (first wins)
        test_count++;
        count = 0;
        for (i = 0; i < 10; i++) begin
            if (i == 2) break;
            if (i == 5) break;
            count++;
        end
        if (count == 2) begin
            pass_count++;
            $display("Test 10 PASS: First break = %0d", count);
        end else begin
            $display("Test 10 FAIL: First unexpected = %0d", count);
        end

        $display("=== Break Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule

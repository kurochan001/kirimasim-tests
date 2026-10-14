/*
:name: test_disable_advanced
:description: disable statement advanced tests
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.6.2 12.8
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_disable_advanced.expected
*/
// IEEE 1800-2023 §12.8: disable statement advanced tests
// Tests for disable with named blocks, nested loops, and tasks

module test_disable_advanced;
    int pass_count = 0;
    int test_count = 0;

    int global_counter;

    task automatic count_task(input int limit, output int result);
        result = 0;
        begin : task_block
            for (int i = 0; i < limit; i++) begin
                result++;
                if (i == 5) disable task_block;
            end
        end
    endtask

    initial begin
        // Test 1: disable named begin-end block
        test_count++;
        begin
            static int i = 0;
            begin : outer_block
                for (i = 0; i < 100; i++) begin
                    if (i == 10) disable outer_block;
                end
            end
            if (i == 10) begin
                pass_count++;
                $display("Test 1 PASS: disable named block at i=%0d", i);
            end else begin
                $display("Test 1 FAIL: expected i=10, got %0d", i);
            end
        end

        // Test 2: disable nested block
        test_count++;
        begin
            static int outer_i = 0;
            static int inner_j = 0;
            begin : outer
                for (outer_i = 0; outer_i < 5; outer_i++) begin : inner
                    for (inner_j = 0; inner_j < 5; inner_j++) begin
                        if (outer_i == 2 && inner_j == 3) disable outer;
                    end
                end
            end
            if (outer_i == 2 && inner_j == 3) begin
                pass_count++;
                $display("Test 2 PASS: disable nested block at [%0d][%0d]", outer_i, inner_j);
            end else begin
                $display("Test 2 FAIL: expected [2][3], got [%0d][%0d]", outer_i, inner_j);
            end
        end

        // Test 3: disable in task
        test_count++;
        begin
            int result;
            count_task(100, result);
            if (result == 6) begin  // 0,1,2,3,4,5 then disable
                pass_count++;
                $display("Test 3 PASS: disable in task, result=%0d", result);
            end else begin
                $display("Test 3 FAIL: expected 6, got %0d", result);
            end
        end

        // Test 4: disable inner loop only
        test_count++;
        begin
            static int sum = 0;
            for (int i = 0; i < 3; i++) begin : outer_loop
                begin : inner_loop
                    for (int j = 0; j < 10; j++) begin
                        sum++;
                        if (j == 2) disable inner_loop;
                    end
                end
            end
            // Each outer iteration adds 3 (j=0,1,2), total 3*3=9
            if (sum == 9) begin
                pass_count++;
                $display("Test 4 PASS: disable inner loop only, sum=%0d", sum);
            end else begin
                $display("Test 4 FAIL: expected 9, got %0d", sum);
            end
        end

        // Test 5: disable with while loop
        test_count++;
        begin
            static int count = 0;
            begin : while_block
                while (1) begin
                    count++;
                    if (count >= 7) disable while_block;
                end
            end
            if (count == 7) begin
                pass_count++;
                $display("Test 5 PASS: disable while loop at count=%0d", count);
            end else begin
                $display("Test 5 FAIL: expected 7, got %0d", count);
            end
        end

        // Test 6: disable with do-while loop (using break instead)
        test_count++;
        begin
            static int count = 0;
            do begin
                count++;
                if (count >= 5) break;
            end while (count < 100);
            if (count == 5) begin
                pass_count++;
                $display("Test 6 PASS: do-while break at count=%0d", count);
            end else begin
                $display("Test 6 FAIL: expected 5, got %0d", count);
            end
        end

        // Test 7: disable with repeat loop
        test_count++;
        begin
            static int count = 0;
            begin : repeat_block
                repeat (100) begin
                    count++;
                    if (count >= 8) disable repeat_block;
                end
            end
            if (count == 8) begin
                pass_count++;
                $display("Test 7 PASS: disable repeat at count=%0d", count);
            end else begin
                $display("Test 7 FAIL: expected 8, got %0d", count);
            end
        end

        // Test 8: Multiple nested disables
        test_count++;
        begin
            static int level = 0;
            begin : level1
                level = 1;
                begin : level2
                    level = 2;
                    begin : level3
                        level = 3;
                        disable level2;  // Skip to end of level2
                        level = 4;  // Should not execute
                    end
                    level = 5;  // Should not execute
                end
                level = level + 10;  // Should execute, level = 3 + 10 = 13
            end
            if (level == 13) begin
                pass_count++;
                $display("Test 8 PASS: multiple nested disable, level=%0d", level);
            end else begin
                $display("Test 8 FAIL: expected 13, got %0d", level);
            end
        end

        $display("=== Disable Advanced Test Results ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule

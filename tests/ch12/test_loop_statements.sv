/*
:name: test_loop_statements
:description: Test for loop statements
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_loop_statements.expected
*/
// Test for loop statements
// IEEE 1800-2023 §12.7

module test_loop_statements;
    int i, j, k;
    int sum;
    int arr[5] = '{1, 2, 3, 4, 5};
    int dyn_arr[$];
    int pass_count = 0;
    int test_count = 0;

    initial begin
        // Test 1: for loop
        test_count++;
        sum = 0;
        for (i = 0; i < 5; i++) begin
            sum += arr[i];
        end
        if (sum == 15) begin
            $display("Test 1: for loop sum = %0d PASS", sum);
            pass_count++;
        end else begin
            $display("Test 1: for loop sum = %0d FAIL", sum);
        end

        // Test 2: while loop
        test_count++;
        sum = 0;
        i = 0;
        while (i < 5) begin
            sum += arr[i];
            i++;
        end
        if (sum == 15) begin
            $display("Test 2: while loop sum = %0d PASS", sum);
            pass_count++;
        end else begin
            $display("Test 2: while loop sum = %0d FAIL", sum);
        end

        // Test 3: do-while loop
        test_count++;
        sum = 0;
        i = 0;
        do begin
            sum += arr[i];
            i++;
        end while (i < 5);
        if (sum == 15) begin
            $display("Test 3: do-while loop sum = %0d PASS", sum);
            pass_count++;
        end else begin
            $display("Test 3: do-while loop sum = %0d FAIL", sum);
        end

        // Test 4: repeat loop
        test_count++;
        sum = 0;
        repeat (5) begin
            sum += 1;
        end
        if (sum == 5) begin
            $display("Test 4: repeat loop sum = %0d PASS", sum);
            pass_count++;
        end else begin
            $display("Test 4: repeat loop sum = %0d FAIL", sum);
        end

        // Test 5: forever with break
        test_count++;
        sum = 0;
        forever begin
            sum++;
            if (sum >= 10) break;
        end
        if (sum == 10) begin
            $display("Test 5: forever with break = %0d PASS", sum);
            pass_count++;
        end else begin
            $display("Test 5: forever with break = %0d FAIL", sum);
        end

        // Test 6: foreach loop
        test_count++;
        sum = 0;
        foreach (arr[idx]) begin
            sum += arr[idx];
        end
        if (sum == 15) begin
            $display("Test 6: foreach loop sum = %0d PASS", sum);
            pass_count++;
        end else begin
            $display("Test 6: foreach loop sum = %0d FAIL", sum);
        end

        // Test 7: nested loops
        test_count++;
        sum = 0;
        for (i = 0; i < 3; i++) begin
            for (j = 0; j < 3; j++) begin
                sum++;
            end
        end
        if (sum == 9) begin
            $display("Test 7: nested loops sum = %0d PASS", sum);
            pass_count++;
        end else begin
            $display("Test 7: nested loops sum = %0d FAIL", sum);
        end

        // Test 8: continue in loop
        test_count++;
        sum = 0;
        for (i = 0; i < 10; i++) begin
            if (i % 2 == 0) continue;  // Skip even
            sum++;
        end
        if (sum == 5) begin
            $display("Test 8: continue - odd count = %0d PASS", sum);
            pass_count++;
        end else begin
            $display("Test 8: continue = %0d FAIL", sum);
        end

        // Report
        if (pass_count == test_count) begin
            $display("TEST PASSED: %0d/%0d tests passed", pass_count, test_count);
        end else begin
            $display("TEST FAILED: %0d/%0d tests passed", pass_count, test_count);
        end

        $finish;
    end
endmodule

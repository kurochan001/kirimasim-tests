/*
:name: test_task_edge_cases
:description: Task edge cases
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.3 13.5
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_task_edge_cases.expected
*/
// IEEE 1800-2023 §13.3: Task edge cases
// Tests for task declarations and calls

module test_task_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    int result;
    logic [7:0] data;

    task automatic add_task(input int a, input int b, output int sum);
        sum = a + b;
    endtask

    task automatic void_task(input int x);
        result = x * 2;
    endtask

    task automatic ref_task(ref int val);
        val = val + 10;
    endtask

    task automatic delay_task(input int delay_val, output int done);
        #delay_val;
        done = 1;
    endtask

    initial begin
        result = 0;
        data = 8'h00;

        // Test 1: Basic task call
        test_count++;
        begin
            int sum;
            add_task(10, 20, sum);
            if (sum == 30) begin
                pass_count++;
                $display("Test 1 PASS: add_task = %0d", sum);
            end else begin
                $display("Test 1 FAIL: Task unexpected = %0d", sum);
            end
        end

        // Test 2: Void task
        test_count++;
        result = 0;
        void_task(25);
        if (result == 50) begin
            pass_count++;
            $display("Test 2 PASS: void_task result = %0d", result);
        end else begin
            $display("Test 2 FAIL: Void unexpected = %0d", result);
        end

        // Test 3: Reference task
        test_count++;
        result = 5;
        ref_task(result);
        if (result == 15) begin
            pass_count++;
            $display("Test 3 PASS: ref_task = %0d", result);
        end else begin
            $display("Test 3 FAIL: Ref unexpected = %0d", result);
        end

        // Test 4: Task with a delay: the call returns after the delay
        test_count++;
        begin
            int done;
            time t0;
            done = 0;
            t0 = $time;
            delay_task(5, done);
            if (done == 1 && $time == t0 + 5) begin
                pass_count++;
                $display("Test 4 PASS: Delay task returned after #5");
            end else begin
                $display("Test 4 FAIL: done=%0d time=%0t", done, $time);
            end
        end

        // Test 5: Multiple calls
        test_count++;
        begin
            int s1, s2, s3;
            add_task(1, 2, s1);
            add_task(3, 4, s2);
            add_task(5, 6, s3);
            if (s1 == 3 && s2 == 7 && s3 == 11) begin
                pass_count++;
                $display("Test 5 PASS: Multi calls = %0d,%0d,%0d", s1, s2, s3);
            end else begin
                $display("Test 5 FAIL: Multi unexpected");
            end
        end

        // Test 6: Zero arguments
        test_count++;
        begin
            int sum;
            add_task(0, 0, sum);
            if (sum == 0) begin
                pass_count++;
                $display("Test 6 PASS: Zero args = %0d", sum);
            end else begin
                $display("Test 6 FAIL: Zero unexpected = %0d", sum);
            end
        end

        // Test 7: Negative arguments
        test_count++;
        begin
            int sum;
            add_task(-10, 5, sum);
            if (sum == -5) begin
                pass_count++;
                $display("Test 7 PASS: Negative = %0d", sum);
            end else begin
                $display("Test 7 FAIL: Neg unexpected = %0d", sum);
            end
        end

        // Test 8: Large values
        test_count++;
        begin
            int sum;
            add_task(1000000, 2000000, sum);
            if (sum == 3000000) begin
                pass_count++;
                $display("Test 8 PASS: Large = %0d", sum);
            end else begin
                $display("Test 8 FAIL: Large unexpected = %0d", sum);
            end
        end

        // Test 9: Sequential ref calls
        test_count++;
        result = 0;
        ref_task(result);
        ref_task(result);
        ref_task(result);
        if (result == 30) begin
            pass_count++;
            $display("Test 9 PASS: Sequential ref = %0d", result);
        end else begin
            $display("Test 9 FAIL: Seq ref unexpected = %0d", result);
        end

        // Test 10: Task in loop
        test_count++;
        begin
            static int total = 0;
            for (int i = 0; i < 5; i++) begin
                int s;
                add_task(i, i, s);
                total += s;
            end
            if (total == 20) begin
                pass_count++;
                $display("Test 10 PASS: Loop task = %0d", total);
            end else begin
                $display("Test 10 FAIL: Loop unexpected = %0d", total);
            end
        end

        $display("=== Task Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule

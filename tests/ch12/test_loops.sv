/*
:name: test_loops
:description: Loops (§12.7)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7 12.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_loops.expected
*/
// IEEE 1800-2023 Loops (§12.7)
// Tests for, while, do-while, foreach, repeat

module test_loops;
    initial begin
        int sum, i;
        static int arr[5] = '{10, 20, 30, 40, 50};
        static int pass_count = 0;
        static int fail_count = 0;

        // Test 1: for loop
        sum = 0;
        for (i = 0; i < 5; i++) sum += i;
        if (sum == 10) begin
            $display("PASS: for loop sum = %0d", sum);
            pass_count++;
        end else begin
            $display("FAIL: for loop sum = %0d, expected 10", sum);
            fail_count++;
        end

        // Test 2: while loop
        sum = 0;
        i = 0;
        while (i < 5) begin
            sum += i;
            i++;
        end
        if (sum == 10) begin
            $display("PASS: while loop sum = %0d", sum);
            pass_count++;
        end else begin
            $display("FAIL: while loop sum = %0d, expected 10", sum);
            fail_count++;
        end

        // Test 3: do-while loop
        sum = 0;
        i = 0;
        do begin
            sum += i;
            i++;
        end while (i < 5);
        if (sum == 10) begin
            $display("PASS: do-while loop sum = %0d", sum);
            pass_count++;
        end else begin
            $display("FAIL: do-while loop sum = %0d, expected 10", sum);
            fail_count++;
        end

        // Test 4: foreach loop
        sum = 0;
        foreach (arr[j]) sum += arr[j];
        if (sum == 150) begin
            $display("PASS: foreach loop sum = %0d", sum);
            pass_count++;
        end else begin
            $display("FAIL: foreach loop sum = %0d, expected 150", sum);
            fail_count++;
        end

        // Test 5: repeat loop
        sum = 0;
        repeat (5) sum += 10;
        if (sum == 50) begin
            $display("PASS: repeat loop sum = %0d", sum);
            pass_count++;
        end else begin
            $display("FAIL: repeat loop sum = %0d, expected 50", sum);
            fail_count++;
        end

        // Test 6: break statement
        sum = 0;
        for (i = 0; i < 100; i++) begin
            if (i == 5) break;
            sum += i;
        end
        if (sum == 10) begin
            $display("PASS: break works, sum = %0d", sum);
            pass_count++;
        end else begin
            $display("FAIL: break sum = %0d, expected 10", sum);
            fail_count++;
        end

        // Test 7: continue statement
        sum = 0;
        for (i = 0; i < 5; i++) begin
            if (i == 2) continue;
            sum += i;
        end
        if (sum == 8) begin  // 0+1+3+4 = 8
            $display("PASS: continue works, sum = %0d", sum);
            pass_count++;
        end else begin
            $display("FAIL: continue sum = %0d, expected 8", sum);
            fail_count++;
        end

        $display("");
        $display("=== Loops Test Results ===");
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule

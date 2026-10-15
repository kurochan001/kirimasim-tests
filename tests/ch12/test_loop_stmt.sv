/*
:name: test_loop_stmt
:description: Test for loop statements
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_loop_stmt.expected
*/
// Test for loop statements
// IEEE 1800-2023 §12.7

module test_loop_stmt;
    int arr[5];
    int sum;
    int i;
    int pass_count = 0;
    int test_count = 0;

    initial begin
        // Test 1: For loop
        test_count++;
        sum = 0;
        for (i = 0; i < 5; i++) begin
            arr[i] = i;
            sum = sum + i;
        end
        if (sum == 10) begin
            $display("Test 1: For loop PASS");
            pass_count++;
        end else begin
            $display("Test 1: FAIL");
        end

        // Test 2: While loop
        test_count++;
        sum = 0;
        i = 0;
        while (i < 5) begin
            sum = sum + arr[i];
            i = i + 1;
        end
        if (sum == 10) begin
            $display("Test 2: While loop PASS");
            pass_count++;
        end else begin
            $display("Test 2: FAIL");
        end

        // Test 3: Repeat loop
        test_count++;
        sum = 0;
        repeat (5) begin
            sum = sum + 2;
        end
        if (sum == 10) begin
            $display("Test 3: Repeat loop PASS");
            pass_count++;
        end else begin
            $display("Test 3: FAIL");
        end

        // Test 4: Foreach loop
        test_count++;
        sum = 0;
        foreach (arr[j]) begin
            sum = sum + arr[j];
        end
        if (sum == 10) begin
            $display("Test 4: Foreach loop PASS");
            pass_count++;
        end else begin
            $display("Test 4: FAIL");
        end

        // Test 5: Do-while loop
        test_count++;
        sum = 0;
        i = 0;
        do begin
            sum = sum + 1;
            i = i + 1;
        end while (i < 5);
        if (sum == 5) begin
            $display("Test 5: Do-while loop PASS");
            pass_count++;
        end else begin
            $display("Test 5: FAIL");
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

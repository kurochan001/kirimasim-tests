/*
:name: test_loop_edge_cases
:description: Loop statement edge cases
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7 9.6.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_loop_edge_cases.expected
*/
// IEEE 1800-2023 §12.7: Loop statement edge cases
// Tests for for, while, do-while, foreach, forever

module test_loop_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    int counter;
    int arr[5];

    initial begin
        // Test 1: Basic for loop
        test_count++;
        counter = 0;
        for (int i = 0; i < 5; i++) counter++;
        if (counter == 5) begin
            pass_count++;
            $display("Test 1 PASS: for loop counter = %0d", counter);
        end else begin
            $display("Test 1 FAIL: for unexpected = %0d", counter);
        end

        // Test 2: While loop
        test_count++;
        counter = 0;
        while (counter < 10) counter++;
        if (counter == 10) begin
            pass_count++;
            $display("Test 2 PASS: while counter = %0d", counter);
        end else begin
            $display("Test 2 FAIL: while unexpected = %0d", counter);
        end

        // Test 3: Do-while loop
        test_count++;
        counter = 0;
        do begin
            counter++;
        end while (counter < 5);
        if (counter == 5) begin
            pass_count++;
            $display("Test 3 PASS: do-while = %0d", counter);
        end else begin
            $display("Test 3 FAIL: do-while unexpected = %0d", counter);
        end

        // Test 4: Foreach array
        test_count++;
        for (int i = 0; i < 5; i++) arr[i] = i * 2;
        counter = 0;
        foreach (arr[i]) counter += arr[i];
        if (counter == 20) begin  // 0+2+4+6+8
            pass_count++;
            $display("Test 4 PASS: foreach sum = %0d", counter);
        end else begin
            $display("Test 4 FAIL: foreach unexpected = %0d", counter);
        end

        // Test 5: Nested for
        test_count++;
        counter = 0;
        for (int i = 0; i < 3; i++) begin
            for (int j = 0; j < 4; j++) begin
                counter++;
            end
        end
        if (counter == 12) begin
            pass_count++;
            $display("Test 5 PASS: nested 3x4 = %0d", counter);
        end else begin
            $display("Test 5 FAIL: nested unexpected = %0d", counter);
        end

        // Test 6: For with break (via disable)
        test_count++;
        counter = 0;
        begin : for_block
            for (int i = 0; i < 100; i++) begin
                counter++;
                if (counter == 7) disable for_block;
            end
        end
        if (counter == 7) begin
            pass_count++;
            $display("Test 6 PASS: for break = %0d", counter);
        end else begin
            $display("Test 6 FAIL: break unexpected = %0d", counter);
        end

        // Test 7: While with break
        test_count++;
        counter = 0;
        begin : while_block
            while (1) begin
                counter++;
                if (counter >= 8) disable while_block;
            end
        end
        if (counter == 8) begin
            pass_count++;
            $display("Test 7 PASS: while break = %0d", counter);
        end else begin
            $display("Test 7 FAIL: while break unexpected = %0d", counter);
        end

        // Test 8: For decrement
        test_count++;
        counter = 0;
        for (int i = 10; i > 0; i--) counter++;
        if (counter == 10) begin
            pass_count++;
            $display("Test 8 PASS: decrement for = %0d", counter);
        end else begin
            $display("Test 8 FAIL: decr unexpected = %0d", counter);
        end

        // Test 9: For with step
        test_count++;
        counter = 0;
        for (int i = 0; i < 10; i += 2) counter++;
        if (counter == 5) begin
            pass_count++;
            $display("Test 9 PASS: step 2 = %0d", counter);
        end else begin
            $display("Test 9 FAIL: step unexpected = %0d", counter);
        end

        // Test 10: Empty for body
        test_count++;
        counter = 0;
        for (int i = 0; i < 5; i++) begin
            // Empty body
        end
        pass_count++;
        $display("Test 10 PASS: Empty body completed");

        // Test 11: Zero iterations
        test_count++;
        counter = 100;
        for (int i = 0; i < 0; i++) counter = 0;
        if (counter == 100) begin
            pass_count++;
            $display("Test 11 PASS: Zero iters = %0d", counter);
        end else begin
            $display("Test 11 FAIL: Zero unexpected = %0d", counter);
        end

        // Test 12: Forever with break
        test_count++;
        counter = 0;
        begin : forever_block
            forever begin
                counter++;
                if (counter >= 3) disable forever_block;
            end
        end
        if (counter == 3) begin
            pass_count++;
            $display("Test 12 PASS: forever = %0d", counter);
        end else begin
            $display("Test 12 FAIL: forever unexpected = %0d", counter);
        end

        $display("=== Loop Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule

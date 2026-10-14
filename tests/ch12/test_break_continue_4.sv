/*
:name: test_break_continue_4
:description: Test: break/continue in loops
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.8
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_break_continue_4.expected
*/
// Test: break/continue in loops

module test_break_continue;
    int pass_count = 0;
    int total_tests = 10;

    // Test variables
    int i, j;
    int sum;
    int count;

    initial begin
        // Test 1: Simple break in for loop
        sum = 0;
        for (i = 0; i < 10; i++) begin
            if (i == 5) break;
            sum += i;
        end
        if (sum == 10) pass_count++;  // 0+1+2+3+4 = 10

        // Test 2: Simple continue in for loop
        sum = 0;
        for (i = 0; i < 10; i++) begin
            if (i % 2 == 1) continue;
            sum += i;
        end
        if (sum == 20) pass_count++;  // 0+2+4+6+8 = 20

        // Test 3: Break in while loop
        sum = 0;
        i = 0;
        while (i < 100) begin
            if (i >= 5) break;
            sum += i;
            i++;
        end
        if (sum == 10) pass_count++;

        // Test 4: Continue in while loop
        sum = 0;
        i = 0;
        while (i < 10) begin
            i++;
            if (i % 2 == 1) continue;
            sum += i;
        end
        if (sum == 30) pass_count++;  // 2+4+6+8+10 = 30

        // Test 5: Break in nested loop (inner only)
        sum = 0;
        for (i = 0; i < 5; i++) begin
            for (j = 0; j < 10; j++) begin
                if (j == 3) break;
                sum++;
            end
        end
        if (sum == 15) pass_count++;  // 5 outer * 3 inner = 15

        // Test 6: Continue in nested loop
        sum = 0;
        for (i = 0; i < 5; i++) begin
            for (j = 0; j < 5; j++) begin
                if (j == 2) continue;
                sum++;
            end
        end
        if (sum == 20) pass_count++;  // 5 outer * 4 inner (skip j=2) = 20

        // Test 7: Multiple breaks and continues
        sum = 0;
        for (i = 0; i < 20; i++) begin
            if (i % 3 == 0) continue;  // Skip 0, 3, 6, 9, 12, 15, 18
            if (i >= 15) break;        // Stop at 15
            sum += i;
        end
        // Sum: 1+2 + 4+5 + 7+8 + 10+11 + 13+14 = 75
        if (sum == 75) pass_count++;

        // Test 8: Break in do-while
        sum = 0;
        i = 0;
        do begin
            if (i == 5) break;
            sum += i;
            i++;
        end while (i < 100);
        if (sum == 10) pass_count++;

        // Test 9: Continue in do-while
        sum = 0;
        i = 0;
        do begin
            i++;
            if (i % 2 == 1) continue;
            sum += i;
        end while (i < 10);
        if (sum == 30) pass_count++;  // 2+4+6+8+10 = 30

        // Test 10: Break in forever loop
        count = 0;
        forever begin
            count++;
            if (count >= 10) break;
        end
        if (count == 10) pass_count++;

        $display("PASS: break_continue (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule

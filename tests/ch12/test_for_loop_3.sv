/*
:name: test_for_loop_3
:description: Test: for loop corner cases
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_for_loop_3.expected
*/
// Test: for loop corner cases

module test_for_loop_3;
    int pass_count = 0;
    int total_tests = 10;

    // Test variables
    int i, j, k;
    int sum;
    int arr[10];
    logic [7:0] data[4];

    initial begin
        // Test 1: Simple for loop
        sum = 0;
        for (i = 0; i < 5; i++) begin
            sum += i;
        end
        if (sum == 10) pass_count++;  // 0+1+2+3+4 = 10

        // Test 2: For loop with decrement
        sum = 0;
        for (i = 5; i > 0; i--) begin
            sum += i;
        end
        if (sum == 15) pass_count++;  // 5+4+3+2+1 = 15

        // Test 3: For loop with step > 1
        sum = 0;
        for (i = 0; i < 10; i += 2) begin
            sum += i;
        end
        if (sum == 20) pass_count++;  // 0+2+4+6+8 = 20

        // Test 4: Nested for loops
        sum = 0;
        for (i = 0; i < 3; i++) begin
            for (j = 0; j < 3; j++) begin
                sum++;
            end
        end
        if (sum == 9) pass_count++;

        // Test 5: Triple nested for loops
        sum = 0;
        for (i = 0; i < 2; i++) begin
            for (j = 0; j < 2; j++) begin
                for (k = 0; k < 2; k++) begin
                    sum++;
                end
            end
        end
        if (sum == 8) pass_count++;

        // Test 6: For loop with array access
        for (i = 0; i < 10; i++) begin
            arr[i] = i * 2;
        end
        sum = 0;
        for (i = 0; i < 10; i++) begin
            sum += arr[i];
        end
        if (sum == 90) pass_count++;  // 0+2+4+6+8+10+12+14+16+18 = 90

        // Test 7: For loop with multiple initializers
        sum = 0;
        for (i = 0, j = 10; i < j; i++, j--) begin
            sum += i + j;
        end
        if (sum == 50) pass_count++;  // (0+10)+(1+9)+(2+8)+(3+7)+(4+6) = 50

        // Test 8: For loop with complex condition
        sum = 0;
        for (i = 0; i < 10 && sum < 20; i++) begin
            sum += i;
        end
        // 0+1+...+6 = 21 stops the loop after i = 6
        if (sum == 21 && i == 7) pass_count++;

        // Test 9: For loop with logic array
        for (i = 0; i < 4; i++) begin
            data[i] = 8'hA0 + i;
        end
        if (data[0] == 8'hA0 && data[3] == 8'hA3) pass_count++;

        // Test 10: For loop zero iterations
        sum = 0;
        for (i = 10; i < 5; i++) begin
            sum = 100;  // Should never execute
        end
        if (sum == 0) pass_count++;

        if (pass_count == total_tests) $display("PASS: for_loop (%0d/%0d)", pass_count, total_tests);

        else $display("FAIL: for_loop (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule

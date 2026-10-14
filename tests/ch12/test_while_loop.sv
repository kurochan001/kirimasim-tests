/*
:name: test_while_loop
:description: Test: while loop corner cases
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7.4 12.8
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_while_loop.expected
*/
// Test: while loop corner cases

module test_while_loop;
    int pass_count = 0;
    int total_tests = 8;

    // Test variables
    int i, j;
    int sum;
    int count;
    logic [7:0] data;

    initial begin
        // Test 1: Simple while loop
        sum = 0;
        i = 0;
        while (i < 5) begin
            sum += i;
            i++;
        end
        if (sum == 10) pass_count++;  // 0+1+2+3+4 = 10

        // Test 2: While loop with compound condition
        sum = 0;
        i = 0;
        while (i < 10 && sum < 15) begin
            sum += i;
            i++;
        end
        if (sum == 15 && i == 6) pass_count++;  // stops when sum reaches 0+1+...+5

        // Test 3: Nested while loops
        sum = 0;
        i = 0;
        while (i < 3) begin
            j = 0;
            while (j < 3) begin
                sum++;
                j++;
            end
            i++;
        end
        if (sum == 9) pass_count++;

        // Test 4: While loop zero iterations
        sum = 0;
        i = 10;
        while (i < 5) begin
            sum = 100;  // Should never execute
        end
        if (sum == 0) pass_count++;

        // Test 5: While loop with bit manipulation
        data = 8'hFF;
        count = 0;
        while (data != 0) begin
            count++;
            data = data >> 1;
        end
        if (count == 8) pass_count++;

        // Test 6: While loop with decrement
        sum = 0;
        i = 5;
        while (i > 0) begin
            sum += i;
            i--;
        end
        if (sum == 15) pass_count++;  // 5+4+3+2+1 = 15

        // Test 7: While loop with complex body
        sum = 0;
        i = 0;
        while (i < 10) begin
            if (i % 2 == 0) begin
                sum += i;
            end else begin
                sum -= 1;
            end
            i++;
        end
        // sum = 0 - 1 + 2 - 1 + 4 - 1 + 6 - 1 + 8 - 1 = 15
        if (sum == 15) pass_count++;

        sum = 0;
        i = 0;
        while (1) begin
            sum += i;
            i++;
            if (i >= 5) break;
        end
        if (sum == 10 && i == 5) pass_count++;

        $display("PASS: while_loop (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule

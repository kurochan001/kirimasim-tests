/*
:name: test_repeat_loop_3
:description: repeat loops with constant, zero, computed and nested counts
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_repeat_loop_3.expected
*/
// repeat loops with constant, zero, computed and nested counts

module test_repeat_loop;
    int pass_count = 0;
    int total_tests = 8;

    // Test variables
    int i;
    int sum;
    int count;
    logic [7:0] data;

    initial begin
        // Test 1: Simple repeat loop
        sum = 0;
        repeat (5) begin
            sum++;
        end
        if (sum == 5) pass_count++;

        // Test 2: Repeat with counter variable
        sum = 0;
        i = 0;
        repeat (10) begin
            sum += i;
            i++;
        end
        if (sum == 45) pass_count++;  // 0+1+2+...+9 = 45

        // Test 3: Repeat zero times
        sum = 0;
        repeat (0) begin
            sum = 100;  // Should never execute
        end
        if (sum == 0) pass_count++;

        // Test 4: Repeat with expression
        count = 3;
        sum = 0;
        repeat (count * 2) begin
            sum++;
        end
        if (sum == 6) pass_count++;

        // Test 5: Nested repeat loops
        sum = 0;
        repeat (3) begin
            repeat (4) begin
                sum++;
            end
        end
        if (sum == 12) pass_count++;

        // Test 6: Repeat with data manipulation
        data = 8'h01;
        repeat (4) begin
            data = data << 1;
        end
        if (data == 8'h10) pass_count++;

        // Test 7: Repeat with conditional inside
        sum = 0;
        i = 0;
        repeat (10) begin
            if (i % 2 == 0) begin
                sum += i;
            end
            i++;
        end
        // sum = 0 + 2 + 4 + 6 + 8 = 20
        if (sum == 20) pass_count++;

        // Test 8: Repeat with complex body
        sum = 0;
        count = 0;
        repeat (5) begin
            sum += count;
            count += 2;
        end
        // sum = 0 + 2 + 4 + 6 + 8 = 20
        if (sum == 20) pass_count++;

        $display("PASS: repeat_loop (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule

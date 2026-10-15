/*
:name: test_do_while_2
:description: do-while loops, including a body that runs once and nested loops
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7.5
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_do_while_2.expected
*/
// do-while loops, including a body that runs once and nested loops

module test_do_while;
    int pass_count = 0;
    int total_tests = 8;

    // Test variables
    int i, j;
    int sum;
    int count;
    logic [7:0] data;

    initial begin
        // Test 1: Simple do-while loop
        sum = 0;
        i = 0;
        do begin
            sum += i;
            i++;
        end while (i < 5);
        if (sum == 10) pass_count++;  // 0+1+2+3+4 = 10

        // Test 2: do-while executes at least once (false condition)
        sum = 0;
        i = 10;
        do begin
            sum = 100;
            i++;
        end while (i < 5);  // Condition false from start
        if (sum == 100) pass_count++;  // Should execute once

        // Test 3: do-while with compound condition
        sum = 0;
        i = 0;
        do begin
            sum += i;
            i++;
        end while (i < 10 && sum < 15);
        if (sum == 15 && i == 6) pass_count++;  // stops after adding 5

        // Test 4: Nested do-while loops
        sum = 0;
        i = 0;
        do begin
            j = 0;
            do begin
                sum++;
                j++;
            end while (j < 3);
            i++;
        end while (i < 3);
        if (sum == 9) pass_count++;

        // Test 5: do-while with bit manipulation
        data = 8'hFF;
        count = 0;
        do begin
            count++;
            data = data >> 1;
        end while (data != 0);
        if (count == 8) pass_count++;

        // Test 6: do-while with decrement
        sum = 0;
        i = 5;
        do begin
            sum += i;
            i--;
        end while (i > 0);
        if (sum == 15) pass_count++;  // 5+4+3+2+1 = 15

        // Test 7: do-while with complex body
        sum = 0;
        i = 0;
        do begin
            if (i % 2 == 0) begin
                sum += i;
            end else begin
                sum -= 1;
            end
            i++;
        end while (i < 10);
        // sum = 0 - 1 + 2 - 1 + 4 - 1 + 6 - 1 + 8 - 1 = 15
        if (sum == 15) pass_count++;

        // Test 8: do-while single iteration
        count = 0;
        do begin
            count++;
        end while (0);  // Always false
        if (count == 1) pass_count++;

        $display("PASS: do_while (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
